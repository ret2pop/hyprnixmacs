{ lib, config, pkgs, ... }:
{
  imports = [
    ../../modules/home/default.nix
  ];
  config.monorepo = {
    profiles.cuda.enable = true;
  };
}
