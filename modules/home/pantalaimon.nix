# [[file:../../../config/nix.org::*pantalaimon][pantalaimon:1]]
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
# pantalaimon:1 ends here
