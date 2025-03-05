{ config, lib, ... }:
{
  services.matrix-conduit = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    settings.global = {
      server_name = "matrix.${config.monorepo.vars.remoteHost}";
      trusted_servers = [
        "matrix.org"
        "nixos.org"
      ];
      address = "0.0.0.0";
      port = 6167;
      allow_registration = true;
    };
  };
}
