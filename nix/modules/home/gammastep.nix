{ lib, config, ... }:
{
  services.gammastep = {
    enable = true;
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
