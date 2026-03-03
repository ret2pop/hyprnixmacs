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
                specialArgs = attrs;
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
            entry = ''
BRANCH=$(git branch --show-current)
GIT_DIR=$(git rev-parse --git-dir)
if [ "$BRANCH" != "main" ] || [ ! -f "$GIT_DIR/MERGE_HEAD" ]; then
  exit 0
fi
echo "Merge to main detected. Building VM for ${hostname}..."
nix build .#nixosConfigurations.${hostname}.config.system.build.vm --no-link
'';
            pass_filenames = false;
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
              {
                serviceName = "conduit";
                enabled = super.services.matrix-conduit.enable;
              }
              {
                serviceName = "git-daemon";
                enabled = super.services.gitDaemon.enable;
              }
              {
                serviceName = "tor";
                enabled = super.services.tor.enable;
              }
            ]);

        mkServiceTestScripts = builtins.concatStringsSep "\n" (builtins.map (service:
          (if service.enabled then ''
test_machine.succeed("systemctl is-active ${service.serviceName}")
'' else "")));

        mkIntegrationTests = builtins.map (hostname: 
          {
            name = "integration-test-${hostname}";
            value = pkgs.testers.runNixOSTest {
              name = "services-test-${hostname}";
              node.specialArgs = attrs;
              nodes = {
                test_machine = {
                  imports = mkHostModules hostname;
                };
              };
              testScript =
                ''
test_machine.start()
test_machine.wait_for_unit("default.target")
test_machine.succeed('printf "smoke"')

'' + mkServiceTestScripts (hostToServices hostname);
            };
          }
        );

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

        integrationTests = builtins.listToAttrs (mkIntegrationTests filterHosts);
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
