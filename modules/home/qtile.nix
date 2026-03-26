# [[file:../../../config/nix.org::*QTile][QTile:1]]
{ sounds, wallpapers, pkgs, ... }:
let
  qtilePaths = pkgs.writeText "qtile-paths.py" ''
WALLPAPER = "${wallpapers}/pastel-city.png"
SOUND = "${sounds}/nice.wav"
  '';
in
{
  xdg.configFile."qtile/config.py".source = ../../qtile/config.py;
  xdg.configFile."qtile/paths.py".source = qtilePaths;
}
# QTile:1 ends here
