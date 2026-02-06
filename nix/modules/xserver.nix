{ lib, config, pkgs, ... }:
{
  services.xserver = {
    enable = (! config.monorepo.profiles.ttyonly.enable);
    displayManager = {
      startx.enable = (! config.monorepo.profiles.ttyonly.enable);
    };

    windowManager = {
	    i3 = {
	      enable = (! config.monorepo.profiles.ttyonly.enable);
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
