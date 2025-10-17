{ config, pkgs, lib, ... }:
{
  services.kubo = {
    enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
    autoMount = false;
    enableGC = true;
    settings = {
      Addresses.API = [
        "/ip4/127.0.0.1/tcp/5001"
      ];
      Bootstrap = [
        "/ip4/128.199.219.111/tcp/4001/ipfs/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu"
        "/ip4/162.243.248.213/tcp/4001/ipfs/QmSoLueR4xBeUbY9WZ9xGUUxunbKWcrNFTDAadQJmocnWm"
      ];
      Datastore = {
        StorageMax = "20GB";
      };
    };
  };
}
