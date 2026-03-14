# [[file:../../../config/nix.org::*MPV][MPV:1]]
{ lib, config, ... }:
{
  programs.mpv = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    config = {
      profile = "gpu-hq";
      force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
  };
}
# MPV:1 ends here
