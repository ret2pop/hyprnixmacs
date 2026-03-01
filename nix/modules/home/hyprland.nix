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
        "overshot, 0.05, 0.9, 0.1, 1.05"
      ];
      animation = [
        # "workspaces, 1, 10, overshot"
        "windows, 1, 2, default"
        "workspaces, 1, 2, default, slidefade 20%"
      ];
      exec-once = [
        "waybar"
        "swww-daemon --format xrgb"
        "sh -c 'swww img \"$(find ${wallpapers} -type f \\( -iname \"*.jpg\" -o -iname \"*.png\" \\) | shuf -n1)\"'"
        "fcitx5-remote -r"
        "fcitx5 -d --replace"
        "fcitx5-remote -r"
        "emacs"
        "librewolf"
      ];
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      monitor = [
        "DP-4,2560x1440@165.000000,0x0,1"
        "Unknown-1,disable"
      ];

      layerrule = [
        {
          name = "waybar blur";
          "match:namespace" = "waybar";
          blur = "on";
        }
      ];

      windowrule = [ 
        {
          name = "emacs";
          "match:class" = "emacs";
          workspace = 1;
        }
        {
          name = "librewolf";
          "match:class" = "librewolf";
          workspace = 2;
        }
        {
          name = "element-desktop";
          "match:class" = "element-desktop";
          workspace = 3;
        }
        {
          name = "vesktop";
          "match:class" = "vesktop";
          workspace = 3;
        }
        {
          name = "pavucontrol";
          "match:class" = "pavucontrol";
          workspace = 4;
        }
        {
          name = "qpwgraph";
          "match:class" = "qpwgraph";
          workspace = 4;
        }
        {
          name = "mpv";
          "match:class" = "mpv";
          workspace = 4;
        }
      ];

      bind = [
        "$mod, F, exec, librewolf"
        "$mod, Return, exec, kitty"
        "$mod, E, exec, emacs"
        "$mod, B, exec, bitcoin-qt"
        "$mod, S, exec, pavucontrol"
        "$mod, M, exec, monero-wallet-gui"
        "$mod, V, exec, element-desktop"
        "$mod, C, exec, fluffychat"
        "$mod, D, exec, wofi --show run"
        "$mod, P, exec, bash ${scripts}/powermenu.sh"
        "$mod, Q, killactive"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        "$mod SHIFT, T, togglefloating"
        "$mod SHIFT, F, fullscreen"

        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        ", XF86AudioPlay, exec, mpc toggle"
        ", Print, exec, grim"

        "$mod, right, resizeactive, 30 0"
        "$mod, left, resizeactive, -30 0"
        "$mod, up, resizeactive, 0 -30"
        "$mod, down, resizeactive, 0 30"
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
          size = 9;
          passes = 4;
          contrast = 0.8;
          brightness = 1.1;
          noise = 0.02;
          new_optimizations = true;
          ignore_opacity = true;
          xray = false;
        };
        rounding = 5;
      };
      input = {
        scroll_method = "on_button_down";
        scroll_button = 276;
        sensitivity = -0.5;
        kb_options = "caps:swapescape";
        repeat_delay = 300;
        repeat_rate = 50;
        natural_scroll = false;
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
