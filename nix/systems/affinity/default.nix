{ config, lib, home-manager, ... }:
{
  imports = [
    ../../modules/default.nix
    ../../modules/home/home.nix
    ../../modules/nvme-simple.nix
  ];
  config.monorepo = {
    profiles = {
	server.enable = true;
	cuda.enable = true;
    };
    vars.hostName = "affinity";
  };
  config.home-manager.users."${config.monorepo.vars.userName}".monorepo.profiles.cuda.enable = true;
}
