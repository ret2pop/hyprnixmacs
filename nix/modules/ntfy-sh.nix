{ lib, config, ... }:
{
  services.ntfy-sh = {
#    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    enable = false;
    settings = {
      base-url = "https://ntfy.${config.monorepo.vars.remoteHost}";
      listen-http = "127.0.0.1:2586";
      envrionmentFile = "/run/secrets/ntfy";
    };
  };
}
