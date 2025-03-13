{ lib, config, ... }:
{
  services.murmur = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    logFile = "/var/log/murmur.log";
    openFirewall = true;
    hostName = "talk.nullring.xyz";
    welcometext = "Wecome to the Null Murmur instance!";
    registerName = "nullring";
    registerHostname = "talk.nullring.xyz";
  };
}
