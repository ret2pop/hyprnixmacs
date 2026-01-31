{ config, lib, pkgs, ... }:
{
  # services.open-webui.enable = lib.mkDefault (!config.monorepo.profiles.server.enable);
  services.ollama = {
    enable = lib.mkDefault (!config.monorepo.profiles.server.enable);
    package = if (config.monorepo.profiles.workstation.enable) then pkgs.ollama-cuda else pkgs.ollama-vulkan;
    loadModels = if (config.monorepo.profiles.workstation.enable) then [
      "qwen3:30b"
      "qwen3-coder:latest"
      "qwen2.5-coder:latest"
      "gemma3:12b-it-qat"
    ] else [
      "qwen3:0.6b"
      "qwen2.5-coder:0.5b"
    ];
    host = "0.0.0.0";
    openFirewall = true;
  };
}
