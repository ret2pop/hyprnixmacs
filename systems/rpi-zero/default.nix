{ ... }:
{
  imports = [
    ../common.nix
  ];
  config = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    monorepo = {
      vars.device = "/dev/mmcblk0";
      profiles = {
        ttyonly.enable = true;
      };
    };
  };
}
