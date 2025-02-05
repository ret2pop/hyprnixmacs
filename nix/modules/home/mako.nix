{ lib, config, sounds, ... }:
{
  services.mako = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    backgroundColor = "#11111bf8";
    textColor = "#cdd6f4";
    borderColor = "#89b4faff";
    borderRadius = 1;
    font = "Fira Code 10";
    defaultTimeout = 3000;
    extraConfig = ''
on-notify=exec mpv ${sounds}/polite.ogg --no-config --no-video
'';
  };
}
