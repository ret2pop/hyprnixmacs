{ config, pkgs, lib, ... }:
{
  services.kubo = {
    enable = lib.mkDefault config.monorepo.profiles.workstation.enable;
  };
}
