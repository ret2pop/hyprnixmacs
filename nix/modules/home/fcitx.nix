{ config, pkgs, lib, ... }:
{
  i18n.inputMethod = {
    type = "fcitx5";
    enable = lib.mkDefault config.monorepo.profiles.graphics.enable;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-chinese-addons
      fcitx5-configtool
      fcitx5-mozc
      fcitx5-rime
    ];
  };
}
