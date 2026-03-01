{ lib, config, ... }:
{
  services.pantalaimon-headless = {
    instances = {
      "nullring" = {
        ssl = true;
        homeserver = "https://matrix.nullring.xyz";
        listenAddress = "localhost";
        listenPort = 8009;
      };
    };
  };
}
