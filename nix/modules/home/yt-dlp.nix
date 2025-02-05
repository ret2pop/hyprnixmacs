{ lib, config, ... }:
{
  programs.yt-dlp = {
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    settings = {
      embed-thumbnail = true;
      embed-subs = true;
      sub-langs = "all";
      downloader = "aria2c";
      downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
    };
  };
}
