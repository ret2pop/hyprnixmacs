{ config, lib, ... }:
{
  enable = lib.mkDefault config.monorepo.profiles.tor.enable;
  openFirewall = true;
  client = {
    enable = lib.mkDefault config.monorepo.profiles.tor.enable;
    socksListenAddress = {
      IsolateDestAddr = true;
      addr = "127.0.0.1";
      port = 9050;
    };
    dns.enable = true;
  };
  torsocks = {
    enable = lib.mkDefault config.monorepo.profiles.tor.enable;
    server = "127.0.0.1:9050";
  };
}
