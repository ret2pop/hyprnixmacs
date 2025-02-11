{
  description = "Emacs centric configurations for a complete networked system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    scripts.url = "github:ret2pop/scripts";
    wallpapers.url = "github:ret2pop/wallpapers";
    sounds.url = "github:ret2pop/sounds";
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
	    url = "github:nix-community/home-manager/release-24.11";
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
  };

  outputs = { self, nixpkgs, home-manager, nur, disko, lanzaboote, sops-nix, nix-topology, ... }@attrs:
    let
      system = "x86_64-linux";
      mkConfigs = map (hostname: {
        name = "${hostname}";
        value = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = attrs;
          modules = if (hostname == "installer") then [
            (./. + "/systems/${hostname}/default.nix")
            { networking.hostName = "${hostname}"; }
            nix-topology.nixosModules.default
          ] else [
            nix-topology.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
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
    };
}
