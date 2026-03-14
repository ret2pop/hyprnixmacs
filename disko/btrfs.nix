# [[file:../../config/nix.org::*Btrfs][Btrfs:1]]
{
  ESP = (import ./esp-boot.nix) // {
    size = "512M";
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
# Btrfs:1 ends here
