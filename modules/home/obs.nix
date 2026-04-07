# [[file:../../../config/nix.org::*OBS][OBS:1]]
{ pkgs, config, ... }:
{
  programs.obs-studio = {
    enable = config.monorepo.profiles.workstation.enable;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
# OBS:1 ends here
