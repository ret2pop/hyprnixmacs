{ config, lib, ... }:
{
  imports = [
    ../../modules/default.nix
    ../../modules/vda-simple.nix
  ];
  config.monorepo = {
    profiles = {
      server.enable = true;
      home.enable = false;
    };
    vars.hostName = "spontaneity";
  };
}
