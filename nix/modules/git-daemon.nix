{ config, lib, ... }:
{
  services.gitDaemon = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    exportAll = true;
    listenAddress = "0.0.0.0";
    basePath = "/srv/git";
  };
}
