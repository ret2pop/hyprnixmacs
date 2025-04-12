{ config, lib, ... }:
{
  services.ollama = {
    enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
    acceleration = "cuda";
    host = "0.0.0.0";
    openFirewall = true;
  };
}
