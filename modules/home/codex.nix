# [[file:../../../config/nix.org::*Codex][Codex:1]]
{ config, ... }:
{
  programs.codex = {
    enable = config.monorepo.profiles.agent.enable;
    settings = {
      model_catalog_json = "~/.codex/model-catalog.local.json";
      projects."/home/preston/monorepo".trust_level = "trusted";
      model = "qwythos-9b";
      model_provider = "custom_ollama";
      model_providers = {
        custom_ollama = {
          name = "Ollama";
          base_url = "http://localhost:11434/v1";
          wire_api = "responses";
          env_key = "OLLAMA_API_KEY";
        };
      };
    };
  };
  home.file.".codex/model-catalog.local.json" = {
    source = ../../data/model-catalog.local.json;
  };
}
# Codex:1 ends here
