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
          pipewire.enable = false;
          tor.enable = false;
          home.enable = false;
        };
      };

      boot.loader.grub.device = "nodev";
      networking = {
        extraHosts = ''
    127.0.0.1 livekit.${config.monorepo.vars.orgHost}
    127.0.0.1 matrix.${config.monorepo.vars.orgHost}
  '';
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
        defaultGateway = "66.42.84.1";
        firewall = {
          allowedTCPPorts = [
            80
            143
            443
            465
            587
            993
            3478
            5349
            6697
            6667
            7881
            8443
            8448
          ];
          allowedUDPPorts = [
            3478 5349 7882
          ];
          allowedUDPPortRanges = [
            { from = 49152; to = 65535; }
          ];
        };
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
            "notes.${config.monorepo.vars.remoteHost}" = {
              a.data = "45.76.87.125";
            };
            "matrix.${config.monorepo.vars.remoteHost}" = {};
            "www.${config.monorepo.vars.remoteHost}" = {};
            "mail.${config.monorepo.vars.remoteHost}" = {};

            "livekit.${config.monorepo.vars.orgHost}" = {};
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
