{ lib, config, ... }:
{
  services.matterbridge = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    configPath = "/etc/matterbridge.toml";
  };
}
