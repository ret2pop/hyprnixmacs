# [[file:../../../config/nix.org::*Continuity][Continuity:1]]
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
# Continuity:1 ends here
