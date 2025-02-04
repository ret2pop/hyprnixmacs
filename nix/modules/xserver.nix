{ lib, config, pkgs, ... }:
{
  services.xserver = {
    enable = lib.mkDefault true;
    displayManager = {
      startx.enable = true;
    };

    windowManager = {
	    i3 = {
	      enable = ! config.monorepo.profiles.ttyonly.enable;
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

    videoDrivers = (if config.monorepo.profiles.cuda.enable then [ "nvidia" ] else []);
  };
}
