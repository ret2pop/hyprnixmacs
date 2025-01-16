{ lib, config, ... }:
{
  services.mako = {
    enable = true;
    backgroundColor = "#11111bf8";
    textColor = "#cdd6f4";
    borderColor = "#89b4faff";
    borderRadius = 1;
    font = "Fira Code 10";
    defaultTimeout = 3000;
    extraConfig = ''
on-notify=exec mpv /home/${config.monorepo.vars.userName}/sounds/notification.wav --no-config --no-video
'';
  };
}
