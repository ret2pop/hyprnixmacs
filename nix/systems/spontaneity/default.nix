{ config, lib, ... }:
{
  imports = [
    ../../modules/default.nix
    ../../modules/vda-simple.nix
    ../home.nix
  ];

  config.monorepo = {
    profiles = {
      server.enable = true;
      ttyonly.enable = true;
      grub.enable = true;
    };
    vars.hostName = "spontaneity";
  };
}
