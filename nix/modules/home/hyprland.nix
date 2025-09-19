{ lib, config, wallpapers, pkgs, scripts, ... }:
{
  wayland.windowManager.hyprland = {
    enable = lib.mkDefault config.monorepo.profiles.hyprland.enable;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      bezier = [
        "overshot,0,1,0,0.95"
      ];
      animation = [
        "workspaces, 1, 10, overshot"
      ];
      exec-once = [
        "waybar"
        "swww-daemon --format xrgb"
        "swww img ${wallpapers}/imagination.png"
        "fcitx5-remote -r"
        "fcitx5 -d --replace"
        "fcitx5-remote -r"
        "emacs"
        "firefox"
      ];
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];
      blurls = [
        "waybar"
      ];
      monitor = [
        "Unknown-1,disable"
      ];
      windowrulev2 = [
        "workspace 1, class:^(emacs)$"
        "workspace 2, class:^(firefox)$"
        "workspace 2, title:^(.*Tor Browser.*)$"
        "workspace 2, title:^(.*Chromium-browser.*)$"
        "workspace 2, class:^(chromium)$"
        "workspace 3, class:^(discord)$"
        "workspace 3, class:^(vesktop)$"
        "workspace 3, title:^(.*fluffychat.*)$"
        "workspace 3, class:^(.*element-desktop.*)$"
        "workspace 4, class:^(.*qpwgraph.*)$"
        "workspace 4, class:^(.*mpv.*)$"
        "workspace 5, title:^(.*Monero.*)$"
        "workspace 5, title:^(.*org\.bitcoin\..*)$"
        "workspace 5, title:^(.*Bitcoin Core - preston.*)$"
        "workspace 5, title:^(.*org\.getmonero\..*)$"
        "workspace 5, title:^(.*Monero - preston.*)$"
        "workspace 5, title:^(.*electrum.*)$"
        "pseudo,title:fcitx"
      ];
      bind = [
        "$mod, F, exec, firefox"
        "$mod, T, exec, tor-browser"
        "$mod, Return, exec, kitty"
        "$mod, E, exec, emacs"
        "$mod, B, exec, bitcoin-qt"
        "$mod, M, exec, monero-wallet-gui"
        "$mod, V, exec, vesktop"
        "$mod, C, exec, fluffychat"
        "$mod, D, exec, wofi --show run"
        "$mod, P, exec, bash ${scripts}/powermenu.sh"
        "$mod, Q, killactive"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        ", XF86AudioPlay, exec, mpc toggle"
        ", Print, exec, grim"
      ]
      ++ (
        builtins.concatLists (builtins.genList
          (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
            in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
          )
          10)
      );
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioNext, exec, mpc next"
        ", XF86AudioPrev, exec, mpc prev"
        ", XF86MonBrightnessUp , exec, xbacklight -inc 10"
        ", XF86MonBrightnessDown, exec, xbacklight -dec 10"
      ];
      decoration = {
        blur = {
          enabled = true;
          size = 5;
          passes = 2;
        };
        rounding = 5;
      };
      device = {
        name = "beken-usb-gaming-mouse-1";
        sensitivity = -0.5;
      };
      input = {
        kb_options = "caps:swapescape";
        repeat_delay = 300;
        repeat_rate = 50;
        natural_scroll = true;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
      };
      cursor = {
        no_hardware_cursors = true;
      };
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };
    };
  };
}
