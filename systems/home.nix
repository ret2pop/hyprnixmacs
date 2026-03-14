# [[file:../../config/nix.org::*Home][Home:1]]
{ config, sops-nix, ... }:
{
  home-manager = {
    backupFileExtension = "backup";
    sharedModules = [
      sops-nix.homeManagerModules.sops
    ];
    extraSpecialArgs = {
      super = config;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${config.monorepo.vars.userName}" = (import (./. + "/${config.networking.hostName}/home.nix"));
  };
}
# Home:1 ends here
