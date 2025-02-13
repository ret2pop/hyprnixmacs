{ config, lib, ... }:
{
  services.gitDaemon = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    exportAll = true;
    basePath = "/srv/git";
  };
}
