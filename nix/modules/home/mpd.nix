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
        type            "pipewire"
        name            "pipewire output"
      }

      audio_output {
        type		"httpd"
        name		"Ret2pop's Music Stream"
        encoder		"opus"
        port		"8000"
        bitrate		"128000"
        format		"48000:16:1"
        always_on       "yes"
        tags            "yes"
      }

      audio_output {
        type            "shout"
        name            "My VPS Stream"
        host            "127.0.0.1"
        port            "8888"
        mount           "/stream"
        password        "SuperSecretSourcePass"
        bitrate         "128"
        format          "44100:16:2"
        protocol        "icecast2"
        user            "source"
        description     "My MPD Stream"
        genre           "Mixed"
    }
    '';
  };
}
