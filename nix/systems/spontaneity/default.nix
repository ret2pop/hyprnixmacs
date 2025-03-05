{ config, lib, ... }:
{
  imports = [
    # nixos-anywhere generates this file
    ./hardware-configuration.nix
    ../../disko/vda-simple.nix
    ../../modules/default.nix
    ../home.nix
  ];
  config = {
    monorepo = {
      profiles = {
        server.enable = true;
        ttyonly.enable = true;
        grub.enable = true;
      };
    };
    networking = {
      firewall.allowedTCPPorts = [
        80
        443
        8448
      ];
      domains = {
        enable = true;
        baseDomains = {
          "${config.monorepo.vars.remoteHost}" = {
            a.data = "66.42.84.130";
            aaaa.data = "2001:19f0:5401:10d0:5400:5ff:fe4a:7794";
          };
        };
        subDomains = {
              "${config.monorepo.vars.remoteHost}" = {};
          "matrix.${config.monorepo.vars.remoteHost}" = {};
          "www.${config.monorepo.vars.remoteHost}" = {};
        };
      };
    };
  };
}
