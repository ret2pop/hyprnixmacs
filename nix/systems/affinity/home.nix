{ lib, config, pkgs, ... }:
{
  imports = [
    ../home-common.nix
  ];
  config.monorepo = {
    profiles.cuda.enable = true;
  };
}
