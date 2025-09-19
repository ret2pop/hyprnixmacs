{ lib, config, pkgs, ... }:
{
  imports = [
    ../home-common.nix
  ];
  config.monorepo.profiles.workstation.enable = false;
}
