# [[file:../../config/nix.org::*CGit Interface][CGit Interface:1]]
{ lib, config, ... }:
let
  serverName = "git.${config.monorepo.vars.orgHost}";
in
{
  services.cgit."my-projects" = {
    enable = lib.mkDefault config.services.gitDaemon.enable;
    scanPath = "${config.users.users.git.home}"; 
    settings = {
      root-title = "Nullring Git Server";
      root-desc = "Projects and cool things";
      enable-commit-graph = 1;
      enable-log-filecount = 1;
      enable-log-linecount = 1;
      enable-index-owner = 0;
      clone-prefix = "https://${serverName}";
      enable-tree-linenumbers = 1;
      strict-export = "git-daemon-export-ok";
    };
    gitHttpBackend = {
      enable = true;
      checkExportOkFiles = true;
    };
    nginx = {
      virtualHost = "${serverName}";
    };
  };

  networking.domains.subDomains."${serverName}" = lib.mkIf config.services.cgit."my-projects".enable {};
  services.nginx.virtualHosts."${serverName}" = lib.mkIf config.services.cgit."my-projects".enable {
    forceSSL = true;
    enableACME = true;
  };
}
# CGit Interface:1 ends here
