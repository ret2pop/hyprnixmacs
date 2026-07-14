# [[file:../config/nix.org::*Flake.nix][Flake.nix:1]]
{
  description = "Emacs centric configurations for a complete networked system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";

    scripts.url = "github:ret2pop/scripts";
    wallpapers.url = "github:ret2pop/wallpapers";
    sounds.url = "github:ret2pop/sounds";
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
    catppuccin-qutebrowser = {
      url = "github:catppuccin/qutebrowser";
      flake = false;
    };
    lean4-mode-src = {
      url = "github:leanprover-community/lean4-mode";
      flake = false;
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
      impermanence,
      git-hooks,
      ...
  }
    @attrs:
      let
        vars = import ./flakevars.nix;
        generate = nixos-dns.utils.generate nixpkgs.legacyPackages."${system}";

        rpiCheck = hostname: (builtins.match "rpi-.*" hostname) != null;
        noRpi = builtins.filter (hostname: (! rpiCheck hostname));
        noInstaller = builtins.filter (hostname: (hostname != "installer"));
        filterHosts = noInstaller (noRpi vars.hostnames);
        system = "x86_64-linux";
        getSystem = hostname: if rpiCheck hostname
                              then "aarch64-linux"
                              else "x86_64-linux";

        pkgs = import nixpkgs { inherit system; };

        dnsConfig = {
          inherit (self) nixosConfigurations;
          extraConfig = import ./dns/default.nix;
        };

        commonModules = hostname: [
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
        ];

        mkHostModules = hostname:
          if (hostname == "installer") then [
            (./. + "/systems/${hostname}/default.nix")
            { networking.hostName = "${hostname}"; }
            nix-topology.nixosModules.default
          ] else (if (rpiCheck hostname)
                  then (commonModules hostname) ++ [
                    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
                  ]
                  else (commonModules hostname));

        # function that generates all systems from hostnames
        mkConfigs = map (hostname: {
          name = "${hostname}";
          value = nixpkgs.lib.nixosSystem {
            system = getSystem hostname;
            specialArgs = attrs // {
              system = (getSystem hostname);
              isIntegrationTest = false;
              testHostname = null;
              monorepoSelf = null;
              targetDevice = null;
            };
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
            stages = [ "pre-merge-commit" ];
            entry = "${pkgs.writeShellScript "${hostname}-check" ''
  #!/usr/bin/env bash
  set -e
  set -o pipefail
  trap "echo -e '\nHook interrupted by user. Aborting merge!'; exit 1" INT TERM
  echo "Running Nix integration tests..."

  BRANCH=$(git branch --show-current)
  if [ "$BRANCH" != "main" ]; then
    exit 0
  fi
  echo "Merge to main detected. Building VM for ${hostname}..."
  if nix build .#nixosConfigurations.${hostname}.config.system.build.vm --no-link; then
      echo "Build succeeded."
      exit 0
  else
      echo "Build failed! Aborting."
      exit 1
  fi
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
              # Test a minimal number of core services because they need to work without WAN
              # in the VM
              {
                serviceName = "nginx";
                enabled = super.services.nginx.enable;
              }
              {
                serviceName = "sshd";
                enabled = super.services.openssh.enable;
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
                    _module.args = attrs // {
                      isIntegrationTest = true;
                      system = getSystem hostname;
                      monorepoSelf = null;
                      targetDevice = null;
                      testHostname = null;
                    };
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

        integrationTests = builtins.listToAttrs (mkIntegrationTests (noInstaller vars.hostnames));
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
              entry = "${pkgs.writeShellScript "block-main-commits" (builtins.readFile ./hooks/prevent-direct-main-commits.sh)}";
            };

            label-commit = {
              enable = true;
              name = "Label Commit";
              always_run = true;
              description = "Label commits with same text as generation boot label, and separate flake lock into separate commit";
              stages = [ "post-commit" ];
              pass_filenames = false;
              entry = "${pkgs.writeShellScript "label-commit" (builtins.readFile ./hooks/label-commit.sh)}";
            };
          };
        };
        mkInstallerTests = builtins.map (hostname:
          let
            lib = nixpkgs.lib;
            targetSystem = self.nixosConfigurations."${hostname}";
            targetDevice = targetSystem.config.monorepo.vars.device;
            
            # Use strict regex matching to identify VM drives and SD cards
            isVirtual = (builtins.match "/dev/vd[a-z]+" targetDevice) != null;
            isSdCard  = (builtins.match "/dev/mmcblk[0-9]+" targetDevice) != null;
            shouldSkip = isVirtual || isSdCard;
            
          in {
            name = "installer-e2e-${hostname}";
            value = if shouldSkip then
              
              # THE BYPASS: Evaluate in milliseconds, entirely skipping QEMU.
              targetSystem.pkgs.runCommand "installer-e2e-${hostname}-skipped" {} ''
                echo "Skipping ${hostname}: Target device (${targetDevice}) is a virtual drive or SD card."
                echo "This system is intended for nixos-anywhere or direct SD flashing."
                mkdir $out
              ''
                
                    else
                      
                      # THE REAL TEST: Only evaluate the heavy lifting if it is a bare-metal NVMe/SATA host.
                      let
                        # 1. Parse the lockfile directly as pure JSON data
                        lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);
                        
                        # 2. Extract only the nodes that actually contain locked source trees
                        lockedNodes = builtins.filter (node: node ? locked) (builtins.attrValues lockfile.nodes);
                        
                        # 3. Native Schema Resolution
                        allFlakeSources = builtins.map (node: 
                          (builtins.fetchTree (builtins.removeAttrs node.locked ["dir"])).outPath
                        ) lockedNodes;

                        # 4. Bundle them securely into a native Nix derivation
                        flakeSourcesClosure = targetSystem.pkgs.stdenvNoCC.mkDerivation {
                          name = "flake-sources-closure";
                          dontUnpack = true;
                          srcs = allFlakeSources;
                          installPhase = ''
                    mkdir -p $out
                    echo "$srcs" > $out/dependencies.txt
                  '';
                        };
                      in
                        targetSystem.pkgs.testers.runNixOSTest {
                          name = "installer-e2e-${hostname}";
                          nodes.installer = { ... }: {
                            
                            _module.args = {
                              inherit (attrs) disko self;
                              testHostname = hostname;
                              monorepoSelf = null;
                              inherit targetDevice;
                            };
                            
                            imports = [
                              (./. + "/systems/installer/default.nix")
                              "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"
                              {
                                networking.hostName = "installer";
                                nixpkgs.pkgs = lib.mkVMOverride targetSystem.pkgs;
                                nixpkgs.config = lib.mkForce {};
                                nixpkgs.overlays = lib.mkForce [];
                              }
                            ];
                            
                            system.extraDependencies = [
                              targetSystem.config.system.build.toplevel
                              flakeSourcesClosure
                            ];

                            virtualisation = {
                              emptyDiskImages = [ 20480 ];
                              memorySize = 8192;
                              cores = 4;
                            };

                            nix.settings = {
                              substituters = lib.mkForce [ ];
                              experimental-features = [ "nix-command" "flakes" ];
                            };
                            
                            systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
                            systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
                          };

                          testScript = ''
                    installer.start()
                    installer.wait_for_unit("multi-user.target")

                    # 1. Execute the native bash script
                    installer.succeed("sudo -i -u nixos nix_installer >&2")
                    # 2. Assert Drive and Configuration Logic
                    installer.succeed("lsblk /dev/vdb | grep -q 'part'")
                    installer.succeed("mountpoint -q /mnt")
                    installer.succeed("sync")
                  '';
                        };
          }
        );

        installerTests = builtins.listToAttrs (mkInstallerTests filterHosts);
      in
        {
          lib = {
            inherit mkHostModules;
          };

          checks."${system}" = integrationTests // installerTests // {
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
              statix
              deadnix
              (python3.withPackages (ps: with ps; [
                octodns
                octodns-providers.cloudflare
                octodns-providers.bind
              ]))
            ];
            shellHook = ''
  ${pre-commit-check.shellHook}
  git config branch.main.mergeoptions "--no-ff"

  CURRENT_HOST="$(hostname)"

  TARGET_USER_RAW=$(nix eval .#nixosConfigurations."$CURRENT_HOST".config.home-manager.users --apply "u: builtins.head (builtins.attrNames u)" --raw 2>/dev/null)

  TARGET_USER=$(echo "$TARGET_USER_RAW" | xargs)
  SOPS_BASE=$(nix eval .#nixosConfigurations."$CURRENT_HOST".config.home-manager.users."$TARGET_USER".sops.defaultSymlinkPath --raw 2>/dev/null)

  if [ -n "$SOPS_BASE" ] && [ -f "$SOPS_BASE/cloudflare-dns" ]; then
    export CLOUDFLARE_TOKEN="$(cat "$SOPS_BASE/cloudflare-dns" | tr -d '\n')"
    echo "Authenticated via sops-nix for host: $CURRENT_HOST"
  else
    echo "Could not resolve sops path for $CURRENT_HOST or secret is missing. Set CLOUDFLARE_TOKEN manually."
  fi

  alias update-dns="octodns-sync --config-file ${self.packages."${system}".octodns} --doit --force"
  alias fake-update-dns="octodns-sync --config-file ${self.packages."${system}".octodns} --force "
  alias gprune='git branch --merged | grep -v -E "^\*|main|master|dev" | xargs -r git branch -d'
  '';
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
# Flake.nix:1 ends here
