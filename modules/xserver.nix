# [[file:../../config/nix.org::*X11][X11:1]]
{ config, ... }:
{
  services.xserver = {
    enable = (! config.monorepo.profiles.ttyonly.enable);
    displayManager = {
      startx.enable = (! config.monorepo.profiles.ttyonly.enable);
    };

    desktopManager = {
      runXdgAutostartIfNone = true;
    };

    videoDrivers = (if config.monorepo.profiles.cuda.enable then [ "nvidia" ] else []);
  };
}
# X11:1 ends here
