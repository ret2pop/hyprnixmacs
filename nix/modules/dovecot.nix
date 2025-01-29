{ config, lib, ... }:
{
  services.dovecot2 = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    enableImap = true;
    enablePop3 = true;
  };
}
