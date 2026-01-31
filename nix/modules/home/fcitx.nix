{ config, pkgs, lib, ... }:
{
  i18n.inputMethod = {
    type = "fcitx5";
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
      fcitx5-mozc
      fcitx5-rime
    ];
  };
}
