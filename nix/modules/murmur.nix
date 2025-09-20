{ lib, config, ... }:
{
  services.murmur = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    openFirewall = true;
    hostName = "0.0.0.0";
    welcometext = "Wecome to the Null Murmur instance!";
    registerName = "nullring";
    registerHostname = "${config.monorepo.vars.orgHost}";
    sslCert = "/var/lib/acme/${config.monorepo.vars.orgHost}/fullchain.pem";
    sslKey = "/var/lib/acme/${config.monorepo.vars.orgHost}/sslKey.pem";
  };
}
