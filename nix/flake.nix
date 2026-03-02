{
  description = "Emacs centric configurations for a complete networked system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";

    scripts.url = "github:ret2pop/scripts";
    wallpapers.url = "github:ret2pop/wallpapers";
    sounds.url = "github:ret2pop/sounds";
    deep-research.url = "github:ret2pop/ollama-deep-researcher";
    impermanence.url = "github:nix-community/impermanence";

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-dns = {
      url = "github:Janik-Haag/nixos-dns";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nur
    , disko
    , lanzaboote
    , sops-nix
    , nix-topology
    , nixos-dns
    , deep-research
    , impermanence
    , nixpak
    , git-hooks
    , ...
    }
      @attrs:
    let
      vars = import ./flakevars.nix;
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
      armPkgs = import nixpkgs { inherit system; };

      generate = nixos-dns.utils.generate nixpkgs.legacyPackages."${system}";

      dnsConfig = {
        inherit (self) nixosConfigurations;
        extraConfig = import ./dns/default.nix;
      };

      # function that generates all systems from hostnames
      mkConfigs = map (hostname:
        let
          isRpi = (builtins.match "rpi-.*" hostname) != null;
          hostSystem = if isRpi then "aarch64-linux" else system;
        in
        {
          name = "${hostname}";
          value = nixpkgs.lib.nixosSystem {
            system = hostSystem;
            specialArgs = attrs;
            modules =
              if (hostname == "installer") then [
                (./. + "/systems/${hostname}/default.nix")
                { networking.hostName = "${hostname}"; }
                nix-topology.nixosModules.default
              ] else
                (if isRpi then [
                  (./. + "/systems/${hostname}/default.nix")
                  disko.nixosModules.disko
                  home-manager.nixosModules.home-manager
                  sops-nix.nixosModules.sops
                  lanzaboote.nixosModules.lanzaboote
                ] else
                  ([
                    {
                      environment.systemPackages = with nixpkgs.lib; [
                        deep-research.packages."${system}".deep-research
                      ];
                    }
                    impermanence.nixosModules.impermanence
                    nix-topology.nixosModules.default
                    lanzaboote.nixosModules.lanzaboote
                    disko.nixosModules.disko
                    home-manager.nixosModules.home-manager
                    sops-nix.nixosModules.sops
                    nixos-dns.nixosModules.dns
                    {
                      nixpkgs.overlays = [ nur.overlays.default ];
                      home-manager.extraSpecialArgs = attrs // {
                        systemHostName = "${hostname}";
                      };
                      networking.hostName = "${hostname}";
                    }
                    (./. + "/systems/${hostname}/default.nix")
                  ]));
          };
        });

      mkDiskoFiles = map (hostname: {
        name = "${hostname}";
        value = self.nixosConfigurations."${hostname}".config.monorepo.vars.diskoSpec;
      });

      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # 1. Formatting
          nixpkgs-fmt.enable = false;

          # 2. Linting
          statix.enable = true;
          deadnix.enable = true;

          # 3. Custom VM Boot Check (The "Integration" part)
          # This runs the build-vm derivation to ensure it compiles
          vm-build-check = {
            enable = true;
            name = "vps-vm-build";
            description = "Ensure VPS configuration is buildable as a VM";
            entry = "nix build .#nixosConfigurations.vps.config.system.build.vm --no-link";
            pass_filenames = false;
          };
        };
      };
    in
    {
      checks."${system}" = {
        inherit pre-commit-check;
      };

      nixosConfigurations = builtins.listToAttrs (mkConfigs vars.hostnames);

      evalDisko = builtins.listToAttrs (mkDiskoFiles (builtins.filter (x: x != "installer") vars.hostnames));

      topology."${system}" = import nix-topology {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-topology.overlays.default ];
        };
        modules = [
          ./topology/default.nix
          { nixosConfigurations = self.nixosConfigurations; }
        ];
      };

      devShell."${system}" = with pkgs; mkShell {
        inherit (pre-commit-check) shellHook;
        buildInputs = [
          fira-code
          python3
          poetry
          statix
          deadnix
        ];
      };

      packages."${system}" = {
        zoneFiles = generate.zoneFiles dnsConfig;
        octodns = generate.octodnsConfig {
          inherit dnsConfig;

          config = {
            providers = {
              cloudflare = {
                class = "octodns_cloudflare.CloudflareProvider";
                token = "env/CLOUDFLARE_TOKEN";
              };
              config = {
                check_origin = false;
              };
            };
          };
          zones = {
            "${vars.remoteHost}." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
            "${vars.orgHost}." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          };
        };
      };
    };
}
