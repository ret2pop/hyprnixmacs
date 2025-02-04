{ config, lib, home-manager, ... }:
{
  imports = [
    ../../modules/default.nix
    ../../modules/nvme-simple.nix
    ../home.nix
  ];
  config = {
    monorepo = {
      profiles = {
        server.enable = true;
        cuda.enable = true;
      };
      vars.hostName = "affinity";
    };
  };
}
