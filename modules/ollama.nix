# [[file:../../config/nix.org::*Ollama][Ollama:1]]
{ config, lib, pkgs, ... }:
{
  services.open-webui = {
    enable = lib.mkDefault config.services.ollama.enable;
    port = 11111;
    host = "127.0.0.1";
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
    };
  };

  services.ollama = {
    enable = lib.mkDefault config.monorepo.profiles.desktop.enable;
    package = if (config.monorepo.profiles.cuda.enable) then pkgs.ollama-cuda else pkgs.ollama-vulkan;
    loadModels = if (config.monorepo.profiles.cuda.enable) then [
    ] else [
    ];
    host = "0.0.0.0";
    openFirewall = true;
  };
}
# Ollama:1 ends here
