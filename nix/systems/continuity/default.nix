{ ... }:
{
  imports = [
    ../../disko/drive-simple.nix
    ../common.nix
  ];
  config = {
    monorepo = {
      profiles.impermanence.enable = true;
      vars = {
        device = "/dev/sda";
        fileSystem = "btrfs";
      };
    };
  };
}
