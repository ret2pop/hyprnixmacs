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
      boot.kernel.sysctl = {
        "net.ipv6.conf.ens3.autoconf" = 0;
        # Keep accept_ra = 1 so you still get the default gateway/route!
        "net.ipv6.conf.ens3.accept_ra" = 1; 
      };

      systemd.network.enable = true;
      systemd.network.networks."40-ens3" = {
        matchConfig.Name = "ens3";
        networkConfig = {
          # This is the magic combo for Vultr:
          IPv6AcceptRA = true;         # Accept routes (so we know where the internet is)
          IPv6PrivacyExtensions = false; # No random privacy IPs
        };
        ipv6AcceptRAConfig = {
          UseAutonomousPrefix = false; # Do NOT generate an IP address from the RA
        };
      };
      networking = {
        useDHCP = lib.mkForce false;
        networkmanager.enable = lib.mkForce false;
        tempAddresses = "disabled";
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
        interfaces.ens3.useDHCP = lib.mkForce false;
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
            9418
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

              mx.data = [
                {
                  preference = 10;
                  exchange = "mail.${config.monorepo.vars.orgHost}";
                }
              ];
              txt = {
                data = "v=spf1 ip4:${ipv4addr} ip6:${ipv6addr} -all";
              };
            };
          };
          subDomains = {
            "${config.monorepo.vars.remoteHost}" = {};
            "notes.${config.monorepo.vars.remoteHost}" = {
              a.data = "45.76.87.125";
            };

            "_dmarc.${config.monorepo.vars.orgHost}" = {
              txt = {
                data = "v=DMARC1; p=none";
              };
            };

            "default._domainkey.${config.monorepo.vars.orgHost}" = {
              txt = {
                data = "v=DKIM1; k=rsa; p=${config.monorepo.vars.dkimKey}";
              };
            };

            "ntfy.${config.monorepo.vars.remoteHost}" = {};
            "matrix.${config.monorepo.vars.remoteHost}" = {};
            "www.${config.monorepo.vars.remoteHost}" = {};
            "music.${config.monorepo.vars.remoteHost}" = {};
            "mail.${config.monorepo.vars.remoteHost}" = {
            };

            "livekit.${config.monorepo.vars.orgHost}" = {};
            "${config.monorepo.vars.orgHost}" = {};
            "git.${config.monorepo.vars.orgHost}" = {};
            "matrix.${config.monorepo.vars.orgHost}" = {};
            "social.${config.monorepo.vars.orgHost}" = {};
            "list.${config.monorepo.vars.orgHost}" = {};
            "talk.${config.monorepo.vars.orgHost}" = {};
            "mail.${config.monorepo.vars.orgHost}" = {};
            "${config.monorepo.vars.internetName}.${config.monorepo.vars.orgHost}" = {};
          };
        };
      };
    };
  }
