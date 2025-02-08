{ config, lib, home-manager, ... }:
{
  imports = [
    ../../modules/default.nix
    ../../disko/nvme-simple.nix
    ../home.nix
  ];
  config = {
    monorepo = {
      profiles = {
        server.enable = false;
        cuda.enable = true;
        workstation.enable = true;
      };
    };
  };
}
