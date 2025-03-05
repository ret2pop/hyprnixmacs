{ config, lib, ... }:
{
  services.ollama = {
    enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
    acceleration = "cuda";
    host = "0.0.0.0";
    openFirewall = true;
  };

  services.nextjs-ollama-llm-ui = {
    enable = lib.mkDefault config.services.ollama.enable;
    port = 3000;
  };
}
