{ config, sops-nix, ... }:
{
  home-manager = {
    sharedModules = [
      sops-nix.homeManagerModules.sops
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${config.monorepo.vars.userName}" = import ./default.nix;
  };
}
