{ lib, ... }:
{
  services.pantalaimon = {
    enable = lib.mkDefault false;
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
