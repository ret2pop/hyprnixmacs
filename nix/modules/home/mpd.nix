{ lib, config, ... }:
{
  services.mpd = {
  enable = lib.mkDefault config.monorepo.profiles.music.enable;
  dbFile = "/home/${config.monorepo.vars.userName}/.config/mpd/db";
  dataDir = "/home/${config.monorepo.vars.userName}/.config/mpd/";
  network.port = 6600;
  musicDirectory = "/home/${config.monorepo.vars.userName}/music";
  playlistDirectory = "/home/${config.monorepo.vars.userName}/.config/mpd/playlists";
  network.listenAddress = "0.0.0.0";
  extraConfig = ''
      audio_output {
        type "pipewire"
        name "pipewire output"
      }
      audio_output {
        type		"httpd"
        name		"My HTTP Stream"
        encoder		"opus"		# optional
        port		"8000"
     #	quality		"5.0"			# do not define if bitrate is defined
        bitrate		"128000"			# do not define if quality is defined
        format		"48000:16:1"
        always_on       "yes" # prevent MPD from disconnecting all listeners when playback is stopped.
        tags            "yes" # httpd supports sending tags to listening streams.
      }
    '';
  };
}
