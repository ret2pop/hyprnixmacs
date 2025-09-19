{ lib, config, ... }:
{
  services.pantalaimon = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    settings = {
      Default = {
        LogLevel = "Debug";
        SSL = true;
      };
      local-matrix = {
        Homeserver = "https://matrix.${config.monorepo.vars.orgHost}";
        ListenAddress = "127.0.0.1";
        ListenPort = "8008";
      };
    };
  };
}
