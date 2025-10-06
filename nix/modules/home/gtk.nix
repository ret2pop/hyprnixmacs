{ lib, config, pkgs, ... }:
{
  gtk = {
    theme = {
      package = pkgs.catppuccin-gtk;
    };
  };
}
