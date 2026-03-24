# [[file:../../config/nix.org::*Ollama][Ollama:1]]
  { config, lib, pkgs, ... }:
  {
    # services.open-webui.enable = lib.mkDefault (!config.monorepo.profiles.server.enable);
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
