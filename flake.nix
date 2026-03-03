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

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
      self,
      nixpkgs,
      home-manager,
      nur,
      disko,
      lanzaboote,
      sops-nix,
      nix-topology,
      nixos-dns,
      deep-research,
      impermanence,
      git-hooks,
      ...
  }
    @attrs:
      let
        vars = import ./flakevars.nix;
        system = "x86_64-linux";

        pkgs = import nixpkgs { inherit system; };
        generate = nixos-dns.utils.generate nixpkgs.legacyPackages."${system}";

        dnsConfig = {
          inherit (self) nixosConfigurations;
          extraConfig = import ./dns/default.nix;
        };

        rpiCheck = hostname: (builtins.match "rpi-.*" hostname) != null;
        noRpi = builtins.filter (hostname: (! rpiCheck hostname));
        noInstaller = builtins.filter (hostname: (hostname != "installer"));
        filterHosts = noInstaller (noRpi vars.hostnames);

        mkHostModules = hostname:
          if (hostname == "installer") then ([
            (./. + "/systems/${hostname}/default.nix")
            { networking.hostName = "${hostname}"; }
            nix-topology.nixosModules.default
          ]) else (if (rpiCheck hostname) then [
            (./. + "/systems/${hostname}/default.nix")
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
          ] else [
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
          ]);

        # function that generates all systems from hostnames
        mkConfigs = map (hostname:
          let
            hostSystem = if (rpiCheck hostname) then "aarch64-linux" else system;
          in
            {
              name = "${hostname}";
              value = nixpkgs.lib.nixosSystem {
                system = hostSystem;
                specialArgs = attrs // { isIntegrationTest = false; };
                modules = mkHostModules hostname;
              };
            });

        mkDiskoFiles = map (hostname: {
          name = "${hostname}";
          value = self.nixosConfigurations."${hostname}".config.monorepo.vars.diskoSpec;
        });

        mkBuildChecks = map (hostname: {
          name = "${hostname}-build-check";
          value = {
            enable = true;
            name = "${hostname}-vm-build";
            description = "Ensure ${hostname} can build";
            stages = [ "post-merge" ];
            entry = "${pkgs.writeShellScript "${hostname}-check" ''
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "main" ]; then
  exit 0
fi
echo "Merge to main detected. Building VM for ${hostname}..."
nix build .#nixosConfigurations.${hostname}.config.system.build.vm --no-link
''}";
            pass_filenames = false;
            always_run = true;
          };
        });

        hostToServices = (hostname:
          let
            super = self.nixosConfigurations."${hostname}".config;
          in
            [
              {
                serviceName = "nginx";
                enabled = super.services.nginx.enable;
              }
              {
                serviceName = "sshd";
                enabled = super.services.openssh.enable;
              }
              # {
              #   serviceName = "conduit";
              #   enabled = super.services.matrix-conduit.enable;
              # }
              {
                serviceName = "git-daemon";
                enabled = super.services.gitDaemon.enable;
              }
              {
                serviceName = "tor";
                enabled = super.services.tor.enable;
              }
            ]);

        _mkServiceTestScripts = hostname: services: builtins.concatStringsSep "\n" (builtins.map (service:
          (if service.enabled then ''
${hostname}.succeed("systemctl is-active ${service.serviceName}")
'' else "")) services);

        mkServiceTestScripts = hostname: _mkServiceTestScripts hostname (hostToServices hostname);

        mkIntegrationTests = builtins.map (hostname: 
          let
            lib = nixpkgs.lib;
            hostPkgs = self.nixosConfigurations."${hostname}".pkgs;
            hardwareConfig = ./systems/${hostname}/hardware-configuration.nix;
          in
            {
              name = "integration-test-${hostname}";
              value = hostPkgs.testers.runNixOSTest {
                name = "services-test-${hostname}";
                nodes = {
                  "${hostname}" = { ... }: {
                    _module.args = attrs // { isIntegrationTest = true; };
                    imports = mkHostModules hostname ++ [
                      "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"
                      {
                        nixpkgs.pkgs = lib.mkVMOverride hostPkgs;
                        nixpkgs.config = lib.mkForce {};
                        systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
                        systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
                        nixpkgs.overlays = lib.mkForce [];
                      }
                    ];
                    disabledModules = [ 
                      ./modules/nixpkgs-options.nix
                    ]
                    ++ lib.optional (builtins.pathExists hardwareConfig) hardwareConfig;
                  };
                };
                testScript = ''
${hostname}.start()
${hostname}.wait_for_unit("default.target")
${hostname}.succeed('printf "smoke"')
${mkServiceTestScripts hostname}
'';
              };
            }
        );

        integrationTests = builtins.listToAttrs (mkIntegrationTests filterHosts);
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = builtins.listToAttrs (mkBuildChecks filterHosts) // {
            statix.enable = false;
            deadnix.enable = true;
            prevent-direct-main-commits = {
              enable = true;
              name = "Prevent direct commits to main";
              description = "Blocks commits to main unless they are merge commits";
              pass_filenames = false;
              entry = "${pkgs.writeShellScript "block-main-commits" ''
BRANCH=$(git branch --show-current)
GIT_DIR=$(git rev-parse --git-dir)
if [ "$BRANCH" = "main" ] && [ ! -f "$GIT_DIR/MERGE_HEAD" ]; then
  echo "Direct commits to 'main' are blocked."
  echo "Please commit to a feature branch and merge it into main."
  exit 1
fi
              ''}";
            };
          };
        };
      in
        {
          checks."${system}" = integrationTests // {
            inherit pre-commit-check;
          };

          nixosConfigurations = builtins.listToAttrs (mkConfigs vars.hostnames);
          evalDisko = builtins.listToAttrs (mkDiskoFiles (noInstaller vars.hostnames));

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
            buildInputs = [
              fira-code
              python3
              poetry
              statix
              deadnix
            ];
            inherit (pre-commit-check) shellHook;
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
