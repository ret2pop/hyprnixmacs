{ lib, config, ... }:
{
  services.cgit."my-projects" = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    scanPath = "${config.users.users.git.home}"; 
    settings = {
      root-title = "Nullring Git Server";
      root-desc = "Projects and cool things";
      enable-commit-graph = 1;
      enable-log-filecount = 1;
      enable-log-linecount = 1;
      enable-index-owner = 0;
      clone-prefix = "https://git.${config.monorepo.vars.orgHost}";
      enable-tree-linenumbers = 1;
      strict-export = "git-daemon-export-ok";
    };
    gitHttpBackend = {
      enable = true;
      checkExportOkFiles = true;
    };
    nginx = {
      virtualHost = "git.${config.monorepo.vars.orgHost}";
    };
  };
}
