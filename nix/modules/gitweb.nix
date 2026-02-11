{ lib, config, ... }:
{
  services.gitweb = {
    gitwebTheme = lib.mkDefault config.monorepo.profiles.server.enable;
    projectroot = "/srv/git/";
    extraConfig = ''
our $export_ok = "git-daemon-export-ok";
'';
  };
}
