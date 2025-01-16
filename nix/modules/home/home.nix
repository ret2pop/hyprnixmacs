{ config, sops-nix, ... }:
{
  imports = [
    ../default.nix
  ];

  home-manager = {
    sharedModules = [
      sops-nix.homeManagerModules.sops
    ];
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${config.monorepo.vars.userName}" = import ./user.nix;
  };
}
