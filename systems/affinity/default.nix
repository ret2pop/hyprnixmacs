{ ... }:
{
  imports = [
    ../common.nix
  ];
  config = {
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
