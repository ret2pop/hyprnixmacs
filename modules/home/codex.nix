# [[file:../../../config/nix.org::*Codex][Codex:1]]
{ config, ... }:
{
  programs.codex = {
    enable = config.monorepo.profiles.agent.enable;
    settings = {
      model = "hf.co/mradermacher/Qwythos-9B-v2-GGUF:Q5_K_M";
      model_provider = "ollama";
      model_providers = {
        ollama = {
          name = "Ollama";
          baseURL = "http://localhost:11434/v1";
          envKey = "OLLAMA_API_KEY";
        };
      };
      mcp_servers = {};
    };
  };
}
# Codex:1 ends here
