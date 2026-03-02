{ lib, config, sounds, ... }:
{
  services.mako = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    settings = {
      on-notify = "exec mpv ${sounds}/polite.ogg --no-config --no-video";
      background-color = "#11111bf8";
      text-color = "#cdd6f4";
      border-color = "#89b4faff";
      border-radius = 1;
      font = "Fira Code 10";
      default-timeout = 3000;
    };
  };
}
