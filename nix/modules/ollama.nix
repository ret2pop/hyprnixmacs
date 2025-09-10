{ config, lib, ... }:
{
  services.ollama = {
    enable = lib.mkDefault (!config.monorepo.profiles.ttyonly.enable);
    acceleration = if (config.monorepo.profiles.workstation.enable) then "cuda" else null;
    loadModels = [
      "qwen3:30b"
      "qwen3-coder:latest"
      "qwen2.5-coder:latest"
      "qwen2.5-coder:3b"
      "gemma3:12b-it-qat"
    ];
    host = "0.0.0.0";
    openFirewall = true;
  };
}
