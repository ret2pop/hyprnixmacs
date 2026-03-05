{ ... }:
{
  imports = [
    ../common.nix
  ];
  config = {
    monorepo = {
      profiles = {
        impermanence.enable = true;
        desktop.enable = true;
      };
      vars = {
        device = "/dev/sda";
        fileSystem = "btrfs";
      };
    };
  };
}
