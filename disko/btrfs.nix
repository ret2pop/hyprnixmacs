{
  ESP = {
    size = "512M";
    type = "EF00";
    content = import ./esp-boot.nix;
  };
  luks = {
    size = "100%";
    content = {
      type = "luks";
      name = "crypted";
      passwordFile = "/tmp/secret.key";
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "/root" = {
            mountpoint = "/";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };

          "/home" = {
            mountpoint = "/home";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };

          "/nix" = {
            mountpoint = "/nix";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };

          "/persistent" = {
            mountpoint = "/persistent";
            mountOptions = [
              "compress=zstd"
              "noatime"
            ];
          };
        };
      };
    };
  };
}
