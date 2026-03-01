{ lib, config, pkgs, ... }:
{
  imports = [
    ../home-common.nix
  ];
  config.monorepo.profiles.enable = false;
}
