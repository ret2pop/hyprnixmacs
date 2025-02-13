{ config, lib, ... }:
{
  services.matrix-conduit = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    # random comment
    settings.global = {
      server_name = "matrix.ret2pop.net";
      address = "0.0.0.0";
      port = 6167;
    };
  };
}
