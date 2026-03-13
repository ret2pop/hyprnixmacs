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
