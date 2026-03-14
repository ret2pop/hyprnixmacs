# [[file:../../config/nix.org::*Bitcoind][Bitcoind:1]]
{ config, lib, ... }:
{
  services.bitcoind."${config.monorepo.vars.userName}" = {
    enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
    prune = 10000;
  };
}
# Bitcoind:1 ends here
