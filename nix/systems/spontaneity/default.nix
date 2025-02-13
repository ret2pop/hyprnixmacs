{ config, lib, ... }:
{
  imports = [
    # nixos-anywhere generates this file
    ./hardware-configuration.nix

    ../../disko/vda-simple.nix

    ../../modules/default.nix
    ../home.nix
  ];

  config.monorepo = {
    profiles = {
      server.enable = true;
      ttyonly.enable = true;
      grub.enable = true;
    };
  };
  config.networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
