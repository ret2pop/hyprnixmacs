# [[file:../../../config/nix.org::*Affinity][Affinity:1]]
{ ... }:
{
  imports = [
    ../common.nix
  ];
  config = {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    monorepo = {
      vars.device = "/dev/nvme0n1";
      vars.fileSystem = "ext4";
      profiles = {
        cuda.enable = true;
        workstation.enable = true;
      };
    };
  };
}
# Affinity:1 ends here
