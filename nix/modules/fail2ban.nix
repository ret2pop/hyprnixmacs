{ lib, config, ... }:
{
  services.fail2ban = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    # Ban IP after 5 failures for 1 hour
    maxretry = 5;
    bantime = "1h";
    banaction = "iptables-allports";
    banaction-allports = "iptables-allports";
  };
}
