{ lib, config, ... }:
{
  services.honk = {
    enable = config.monorepo.vars.ttyonly;
    servername = "ret2pop.net";
    username = "ret2pop";
  };
}
