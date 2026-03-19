# [[file:../../../config/nix.org::*rpi-zero][rpi-zero:1]]
{ ... }:
{
  imports = [
    ../common.nix
  ];

  config = {
    boot = {
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
      initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
      kernelParams = [
        "console=ttyS1,115200n8"
      ];
    };

    zramSwap.memoryPercent = 100;
    services.gitDaemon.enable = true;

    monorepo = {
      vars.device = "/dev/mmcblk0";
      profiles = {
        ttyonly.enable = true;
      };
    };
  };
}
# rpi-zero:1 ends here
