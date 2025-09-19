{ config, lib, ... }:
{
  services.ollama = {
    enable = lib.mkDefault (!config.monorepo.profiles.server.enable);
    acceleration = if (config.monorepo.profiles.workstation.enable) then "cuda" else null;
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
