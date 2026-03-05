{ ... }:
{
  imports = [
    ../common.nix
  ];
  config = {
    monorepo = {
      vars.device = "/dev/nvme0n1";
      profiles = {
        cuda.enable = true;
        workstation.enable = true;
      };
    };
  };
}
