{ config, lib, home-manager, ... }:
{
  imports = [
    ../includes.nix
    ../../disko/drive-simple.nix
  ];
  config = {
    monorepo = {
      vars.device = "/dev/nvme0n1";
      profiles = {
        server.enable = false;
        cuda.enable = true;
        workstation.enable = true;
      };
    };
  };
}
