{ config, lib, ... }:
{
  services.bitcoind."${config.monorepo.vars.userName}" = {
    enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
    prune = 10000;
  };
}
