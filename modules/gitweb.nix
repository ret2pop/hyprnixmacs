{ lib, config, ... }:
{
  services.gitweb = {
    gitwebTheme = lib.mkDefault config.monorepo.profiles.server.enable;
    projectroot = "/srv/git/";
    extraConfig = ''
our $export_ok = "git-daemon-export-ok";
our $site_name = "NullRing Git Server";
our $site_header = "NullRing Projects";
'';
  };
}
