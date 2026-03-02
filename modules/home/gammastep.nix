{ lib, config, ... }:
{
  services.gammastep = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    provider = "manual";
    latitude = 49.282730;
    longitude = -123.120735;
    
    temperature = {
      day = 5000;
      night = 3000;
    };

    settings = {
      general = {
        adjustment-method = "wayland";
      };
    };
  };
}
