{ lib, config, ... }:
{
  services.ircdHybrid = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    extraIPs = [ "0.0.0.0" ];
    extraPort = "6697";
    adminEmail = "ret2pop@gmail.com";
    description = "NullRing IRC instance";
    serverName = "nullring.xyz";
    certificate = "/var/lib/acme/nullring.xyz/cert.pem";
  };
}
