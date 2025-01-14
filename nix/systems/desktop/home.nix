{ sops-nix, ... }:
let
  vars = import ./vars.nix;
in
{
  home-manager = {
    sharedModules = [
      sops-nix.homeManagerModules.sops
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${vars.userName}" = ./user.nix;
  };
}
