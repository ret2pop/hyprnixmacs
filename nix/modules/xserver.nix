{ config, lib, pkgs, ... }:
{
  enable = lib.mkDefault config.monorepo.profiles.home.hyprland.enable;
  displayManager = {
    startx.enable = true;
  };

  windowManager = {
    i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };

  desktopManager = {
    runXdgAutostartIfNone = true;
  };

  xkb = {
    layout = "us";
    variant = "";
    options = "caps:escape";
  };

  videoDrivers = config.monorepo.profiles.vars.videoDrivers;
}
