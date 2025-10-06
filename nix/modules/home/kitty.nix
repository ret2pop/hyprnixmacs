{ lib, config, ... }:
{
  programs.kitty = {
    enable = lib.mkDefault (config.monorepo.profiles.hyprland.enable && config.monorepo.profiles.graphics.enable);
    settings = {
      enable_audio_bell = false;
      font_family = "Iosevka Nerd Font";
      font_size = 14;
      confirm_os_window_close = 0;
      background_opacity = "0.7";
      # Catppuccin theme
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#1e1e2e";
      selection_background = "#f5e0dc";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      url_color = "#f5e0dc";
      active_border_color = "#B4BEFE";
      inactive_border_color = "#6C7086";
      bell_border_color = "#F9E2AF";
      wayland_titlebar_color = "#1E1E2E";
      macos_titlebar_color = "#1E1E2E";
      active_tab_foreground = "#11111B";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111B";
      mark1_foreground = "#1E1E2E";
      mark1_background = "#B4BEFE";
      mark2_foreground = "#1E1E2E";
      mark2_background = "#CBA6F7";
      mark3_foreground = "#1E1E2E";
      mark3_background = "#74C7EC";
      color0 = "#45475A";
      color8 = "#585B70";
      color1 = "#F38BA8";
      color9 = "#F38BA8";
      color2 = "#A6E3A1";
      color10 = "#A6E3A1";
      color3 = "#F9E2AF";
      color11 = "#F9E2AF";
      color4 = "#89B4FA";
      color12 = "#89B4FA";
      color5 = "#F5C2E7";
      color13 = "#F5C2E7";
      color6 = "#94E2D5";
      color14 = "#94E2D5";
      color7 = "#BAC2DE";
      color15 = "#A6ADC8";
    };
  };
}
