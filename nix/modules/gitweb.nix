{ lib, config, ... }:
{
  services.gitweb = {
    gitwebTheme = true;
    projectroot = "/srv/git/";
  };
}
