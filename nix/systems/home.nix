{ config, sops-nix, ... }:
{
  home-manager = {
    sharedModules = [
      sops-nix.homeManagerModules.sops
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${config.monorepo.vars.userName}" = import (./. + "/${config.monorepo.vars.hostName}/home.nix");
  };
}
