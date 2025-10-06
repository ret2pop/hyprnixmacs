{ config, lib, ... }:
let
  ipv4addr = "66.42.84.130";
  ipv6addr = "2001:19f0:5401:10d0:5400:5ff:fe4a:7794";
in
{
  imports = [
    ../common.nix
    ../../disko/drive-bios.nix

    # nixos-anywhere generates this file
    ./hardware-configuration.nix
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
      interfaces.ens3.ipv4.addresses = [
        {
          address = ipv4addr;
          prefixLength = 24;
        }
      ];
      interfaces.ens3.ipv6.addresses = [
        {
          address = ipv6addr;
          prefixLength = 64;
        }
      ];
      firewall.allowedTCPPorts = [
        80
        143
        443
        465
        587
        993
        6697
        6667
        8448
      ];
      domains = {
        enable = true;
        baseDomains = {
          "${config.monorepo.vars.remoteHost}" = {
            a.data = ipv4addr;
            aaaa.data = ipv6addr;
          };
          "${config.monorepo.vars.orgHost}" = {
            a.data = ipv4addr;
            aaaa.data = ipv6addr;
          };
        };
        subDomains = {
          "${config.monorepo.vars.remoteHost}" = {};
          "matrix.${config.monorepo.vars.remoteHost}" = {};
          "www.${config.monorepo.vars.remoteHost}" = {};
          "mail.${config.monorepo.vars.remoteHost}" = {
            mx.data = "10 mail.${config.monorepo.vars.remoteHost}.";
          };

          "${config.monorepo.vars.orgHost}" = {};
          "git.${config.monorepo.vars.orgHost}" = {};
          "matrix.${config.monorepo.vars.orgHost}" = {};
          "talk.${config.monorepo.vars.orgHost}" = {};
          "mail.${config.monorepo.vars.orgHost}" = {};
          "${config.monorepo.vars.internetName}.${config.monorepo.vars.orgHost}" = {};
        };
      };
    };
  };
}
