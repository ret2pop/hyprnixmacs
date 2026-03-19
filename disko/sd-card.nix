# [[file:../../config/nix.org::*SD Card][SD Card:1]]
{
  boot = {
    name = "ESP";
    start = "16M";
    end = "516M";
    bootable = true;
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
    };
  };

  root = {
    name = "root";
    start = "516M";
    end = "100%";
    content = {
      type = "filesystem";
      format = "btrfs";
      mountpoint = "/";
      mountOptions = [ "compress=zstd" ];
    };
  };
}
# SD Card:1 ends here
