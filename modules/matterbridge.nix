# [[file:../../config/nix.org::*Matterbridge][Matterbridge:1]]
{ lib, config, ... }:
{
  services.matterbridge = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    configPath = "${config.sops.templates.matterbridge.path}";
  };
}
# Matterbridge:1 ends here
