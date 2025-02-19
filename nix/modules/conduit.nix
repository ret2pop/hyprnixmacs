{ config, lib, ... }:
{
  services.matrix-conduit = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    # random comment
    settings.global = {
      server_name = "matrix.${config.monorepo.vars.remoteHost}";
      address = "0.0.0.0";
      port = 6167;
    };
  };
}
