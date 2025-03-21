{ lib, config, ... }:
{
  services.murmur = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    logFile = "/var/log/murmur.log";
    openFirewall = true;
    hostName = "0.0.0.0";
    welcometext = "Wecome to the Null Murmur instance!";
    registerName = "nullring";
    registerHostname = "nullring.xyz";
    sslCert = "/var/lib/acme/nullring.xyz/fullchain.pem";
    sslKey = "/var/lib/acme/nullring.xyz/sslKey.pem";
  };
}
