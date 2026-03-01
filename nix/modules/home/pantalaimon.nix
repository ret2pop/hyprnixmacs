{ lib, config, ... }:
{
  services.pantalaimon = {
    enable = lib.mkDefault config.monorepo.profiles.enable;
    settings = {
      Default = {
        LogLevel = "Debug";
        SSL = true;
      };

      local-matrix = {
        Homeserver = "https://matrix.nullring.xyz";
        ListenAddress = "127.0.0.1";
        ListenPort = 8008;
      };
    };

  };
}
