{ lib, config, wallpapers, pkgs, scripts, ... }:
{
  wayland.windowManager.hyprland = {
    enable = lib.mkDefault config.monorepo.profiles.hyprland.enable;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
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
      windowrule = [
        "workspace 1, ^(.*emacs.*)$"
        "workspace 2, ^(.*firefox.*)$"
        "workspace 2, ^(.*Tor Browser.*)$"
        "workspace 2, ^(.*Chromium-browser.*)$"
        "workspace 2, ^(.*chromium.*)$"
        "workspace 3, ^(.*discord.*)$"
        "workspace 3, ^(.*vesktop.*)$"
        "workspace 3, ^(.*fluffychat.*)$"
        "workspace 3, ^(.*element-desktop.*)$"
        "workspace 4, ^(.*qpwgraph.*)$"
        "workspace 4, ^(.*mpv.*)$"
        "workspace 5, ^(.*Monero.*)$"
        "workspace 5, ^(.*org\.bitcoin\..*)$"
        "workspace 5, ^(.*Bitcoin Core - preston.*)$"
        "workspace 5, ^(.*org\.getmonero\..*)$"
        "workspace 5, ^(.*Monero - preston.*)$"
        "workspace 5, ^(.*electrum.*)$"
        "pseudo,fcitx"
      ];
      bind = [
        "$mod, F, exec, firefox"
        "$mod, T, exec, tor-browser"
        "$mod, Return, exec, kitty"
        "$mod, E, exec, emacs"
        "$mod, B, exec, bitcoin-qt"
        "$mod, M, exec, monero-wallet-gui"
        "$mod, V, exec, vesktop"
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
