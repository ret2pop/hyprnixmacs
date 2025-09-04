{
  description = "Emacs centric configurations for a complete networked system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    scripts.url = "github:ret2pop/scripts";
    wallpapers.url = "github:ret2pop/wallpapers";
    sounds.url = "github:ret2pop/sounds";
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deep-research = {
      url = "github:ret2pop/ollama-deep-researcher";
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
  };

  outputs = { self, nixpkgs, home-manager, nur, disko, lanzaboote, sops-nix, nix-topology, nixos-dns, deep-research, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      generate = nixos-dns.utils.generate nixpkgs.legacyPackages."${system}";
      dnsConfig = {
        inherit (self) nixosConfigurations;
        extraConfig = import ./dns/default.nix;
      };
      mkConfigs = map (hostname: {
        name = "${hostname}";
        value = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = attrs;
          modules = if (hostname == "installer") then [
            (./. + "/systems/${hostname}/default.nix")
            { networking.hostName = "${hostname}"; }
            nix-topology.nixosModules.default
          ] else [
            {
              environment.systemPackages = with nixpkgs.lib; [
                deep-research.packages.${system}.deep-research
              ];
            }
            nix-topology.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            nixos-dns.nixosModules.dns
            {
              nixpkgs.overlays = [ nur.overlays.default ];
              home-manager.extraSpecialArgs = attrs;
              networking.hostName = "${hostname}";
            }
            (./. + "/systems/${hostname}/default.nix")
          ];
        };
      });
    in {
      nixosConfigurations = builtins.listToAttrs (mkConfigs [
        "affinity"
        "continuity"
        "installer"
        "spontaneity"
      ]);

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
        ];
        shellHook = ''
poetry shell
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
            "ret2pop.net." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
            "nullring.xyz." = nixos-dns.utils.octodns.generateZoneAttrs [ "cloudflare" ];
          };
        };
      };
    };
}
