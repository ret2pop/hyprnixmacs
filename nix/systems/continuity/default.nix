{ ... }:
{
  imports = [
    ../../disko/btrfs-simple.nix
    ../common.nix
  ];
  config = {
    monorepo = {
      profiles = {
        impermanence.enable = true;
        secureBoot.enable = true;
      };
      vars = {
        device = "/dev/sda";
        fileSystem = "btrfs";
      };
    };
    networking.networkmanager.wifi.backend = "iwd";
  };
}
