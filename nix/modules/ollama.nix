{ config, lib, ... }:
{
  services.ollama = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    acceleration = "cuda";
    host = "0.0.0.0";
  };
}
