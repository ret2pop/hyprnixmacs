{ config, lib, ... }:
{
  services.postfix = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    config = {
    };
  };
}
