# [[file:../../config/nix.org::*QTile][QTile:1]]
{ lib, config, ... }:
{
    services.xserver.windowManager.qtile = {
    enable = lib.mkDefault config.monorepo.profiles.desktop.enable;

    extraPackages = python3Packages: with python3Packages; [
      qtile-extras
    ];
  };
}
# QTile:1 ends here
