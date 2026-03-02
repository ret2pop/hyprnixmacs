{ lib, config, ... }:
{
  services.honk = {
    enable = lib.mkDefault config.monorepo.profiles.server.enable;
    servername = "ret2pop.net";
    username = "ret2pop";
  };
}
