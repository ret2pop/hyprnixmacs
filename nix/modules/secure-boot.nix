{ pkgs, lib, config, inputs, ... }:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options = {
    secure-boot.enable = lib.mkEnableOption "Enables secure boot on system";
  };

  config = lib.mkIf config.secure-boot.enable {
    boot = {
      loader.systemd-boot.enable = lib.mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
