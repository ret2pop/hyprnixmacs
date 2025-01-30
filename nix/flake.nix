{
  description = "Emacs centric configurations for a complete networked system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

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

    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    scripts.url = "github:ret2pop/scripts";
    wallpapers.url = "github:ret2pop/wallpapers";
    sounds.url = "github:ret2pop/sounds";
  };

  outputs = { nixpkgs, home-manager, nur, disko, lanzaboote, sops-nix, ... }@attrs: {
    nixosConfigurations = {
	installer = nixpkgs.lib.nixosSystem {
	  system = "x86_64-linux";
	  modules = [
	    (
	      { pkgs, modulesPath, ... }:
	      {
		imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
	      }
	    )
	    ./systems/installer/default.nix
	  ];
	};

	continuity = nixpkgs.lib.nixosSystem {
	  system = "x86_64-linux";
	  specialArgs = attrs;
	  modules = [
	    lanzaboote.nixosModules.lanzaboote
	    disko.nixosModules.disko
	    home-manager.nixosModules.home-manager
	    sops-nix.nixosModules.sops
	    { nixpkgs.overlays = [ nur.overlays.default ]; }
	    { home-manager.extraSpecialArgs = attrs; }

	    ./modules/sda-simple.nix
	    ./systems/continuity/default.nix
	  ];
	};

	affinity = nixpkgs.lib.nixosSystem {
	  system = "x86_64-linux";
	  specialArgs = attrs;
	  modules = [
	    lanzaboote.nixosModules.lanzaboote
	    disko.nixosModules.disko
	    home-manager.nixosModules.home-manager
	    sops-nix.nixosModules.sops
	    { nixpkgs.overlays = [ nur.overlays.default ]; }
	    { home-manager.extraSpecialArgs = attrs; }
	    ./modules/nvme-simple.nix
	    ./systems/affinity/default.nix
	  ];
	};

	spontaneity = nixpkgs.lib.nixosSystem {
	  system = "x86_64-linux";
	  specialArgs = attrs;
	  modules = [];
	};
    };
  };
}
