{ config, lib, ... }:
{
  imports = [
    ../../modules/default.nix
  ];
  config.monorepo = {
    profiles = {
      home.enable = false;
      server.enable = true;
    };
    vars.hostName = "spontaneity";
  };
}
