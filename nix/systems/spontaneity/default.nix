{ config, lib, ... }:
{
  imports = [
    ../includes.nix
    # nixos-anywhere generates this file
    ./hardware-configuration.nix
    ../../disko/drive-bios.nix
  ];
  config = {
    monorepo = {
      vars.device = "/dev/vda";
      profiles = {
        server.enable = true;
        ttyonly.enable = true;
        grub.enable = true;
      };
    };

    boot.loader.grub.device = "nodev";
    networking = {
      interfaces.ens3.ipv6.addresses = [
        {
          address = "2001:19f0:5401:10d0:5400:5ff:fe4a:7794";
          prefixLength = 64;
        }
      ];
      firewall.allowedTCPPorts = [
        80
        443
        465
        993
        8448
        6697
        6667
      ];
      domains = {
        enable = true;
        baseDomains = {
          "${config.monorepo.vars.remoteHost}" = {
            a.data = "66.42.84.130";
            aaaa.data = "2001:19f0:5401:10d0:5400:5ff:fe4a:7794";
          };
          "nullring.xyz" = {
            a.data = "66.42.84.130";
            aaaa.data = "2001:19f0:5401:10d0:5400:5ff:fe4a:7794";
          };
        };
        subDomains = {
          "${config.monorepo.vars.remoteHost}" = {};
          "matrix.${config.monorepo.vars.remoteHost}" = {};
          "www.${config.monorepo.vars.remoteHost}" = {};
          "mail.${config.monorepo.vars.remoteHost}" = {};

          "nullring.xyz" = {};
          "git.nullring.xyz" = {};
          "matrix.nullring.xyz" = {};
          "talk.nullring.xyz" = {};
          "mail.nullring.xyz" = {};
          "ret2pop.nullring.xyz" = {};
        };
      };
    };
  };
}
