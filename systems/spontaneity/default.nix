# [[file:../../../config/nix.org::*Spontaneity][Spontaneity:1]]
{ ... }:
{
  imports = [
    ../common.nix
    # nixos-anywhere generates this file
    ./hardware-configuration.nix
  ];
  config = {
    monorepo = {
      vars.device = "/dev/vda";
      profiles = {
        server = {
          enable = true;
          ipv4 = "66.42.84.130";
          gateway = "66.42.84.1";
          ipv6 = "2001:19f0:5401:10d0:5400:5ff:fe4a:7794";
          interface = "ens3";
        };
        grub.enable = true;
        pipewire.enable = false;
        tor.enable = false;
      };
    };
    boot.loader.grub.device = "nodev";
  };
}
# Spontaneity:1 ends here
