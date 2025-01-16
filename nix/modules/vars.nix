{ lib, ... }:
{
  hostName = lib.mkOption {
    type = lib.types.str;
    default = "continuity";
    example = "hostname";
    description = "system hostname";
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
    default = "nullring.xyz";
    example = "example.com";
    description = "Address to push to and pull from for website and git repos";
  };

  timeZone = lib.mkOption {
    type = lib.types.str;
    default = "America/Vancouver";
    example = "America/Chicago";
    description = "Linux timezone";
  };
  disk = lib.mkOption {
    type = lib.types.str;
    default = "/dev/sda";
    example = "/dev/nvme0n1";
    description = "Disk to install NixOS to";
  };
}
