{ config, lib, ... }:
{
  imports = [
    ../../modules/default.nix
  ];
  config.monorepo = {
    profiles = {
      server.enable = true;
      cuda.enable = true;
    };
    vars.hostName = "affinity";
  };
}
