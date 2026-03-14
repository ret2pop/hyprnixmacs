# [[file:../../config/nix.org::*Git Server][Git Server:1]]
{ config, lib, ... }:
{
  services.gitDaemon = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    exportAll = true;
    basePath = "${config.users.users.git.home}";
  };
  networking.firewall.allowedTCPPorts = lib.mkIf config.services.gitDaemon.enable [
    9418
  ];
}
# Git Server:1 ends here
