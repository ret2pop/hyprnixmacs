{ lib, config, ... }:
{
  services.matterbridge = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    configPath = "${config.sops.templates.matterbridge.path}";
  };
}
