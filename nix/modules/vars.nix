{ lib, ... }:
{
  options.monorepo.vars = {
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      example = "/dev/nvme0n1";
      description = "device that NixOS is installed to";
    };

    fileSystem = lib.mkOption {
      type = lib.types.str;
      default = "ext4";
      example = "btrfs";
      description = "filesystem to install with disko";
    };

    diskoSpec = lib.mkOption {
      type = lib.types.attrs;
      description = "retains a copy of the disko spec for reflection";
    };

    userName = lib.mkOption {
      type = lib.types.str;
      default = "preston";
      example = "myUser";
      description = "system username";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Preston Pan";
      example = "John Doe";
      description = "Full Name";
    };

    gpgKey = lib.mkOption {
      type = lib.types.str;
      default = "AEC273BF75B6F54D81343A1AC1FE6CED393AE6C1";
      example = "1234567890ABCDEF...";
      description = "GPG key fingerprint";
    };

    remoteHost = lib.mkOption {
      type = lib.types.str;
      default = "ret2pop.net";
      example = "example.com";
      description = "Address to push to and pull from for website and git repos";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/Vancouver";
      example = "America/Chicago";
      description = "Linux timezone";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "HDMI-A-1"
        "eDP-1"
        "DP-2"
        "DP-3"
        "DP-4"
        "LVDS-1"
      ];
      example = [];
      description = "Monitors that waybar will use";
    };
  };
}
