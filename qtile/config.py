# [[file:../../config/qtile.org::*Imports][Imports:1]]
from paths import WALLPAPER, SOUND
from libqtile import bar, layout, widget, qtile
from libqtile.config import Key, Group, Screen, Click, Drag, Match
from libqtile.lazy import lazy
from libqtile.backend.wayland import InputConfig
from qtile_extras.layout.decorations import RoundedCorners

import re
# Imports:1 ends here

# [[file:../../config/qtile.org::*Data][Data:1]]
mod = "mod4"
terminal = "kitty"
wallpaper = WALLPAPER

colors = {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
}

workspace_keys = {
    "1": "1",
    "2": "2",
    "3": "3",
    "4": "4",
    "5": "5",
    "6": "6",
    "7": "7",
    "8": "8",
    "9": "9",
}
# Data:1 ends here

# [[file:../../config/qtile.org::*Config][Config:1]]
groups = [
    Group("1", matches=[Match(wm_class=re.compile(r"^emacs$", re.IGNORECASE))]),
    Group("2", matches=[Match(wm_class=re.compile(r"(qutebrowser|org\.qutebrowser\.qutebrowser)", re.IGNORECASE))]),
    Group(
        "3",
        matches=[
            Match(wm_class=re.compile(r"^signal.*", re.IGNORECASE)),
            Match(wm_class=re.compile(r"^element.*", re.IGNORECASE)),
        ],
    ),
    Group("4", matches=[Match(wm_class=re.compile(r"(pavucontrol|org\.pulseaudio\.pavucontrol)", re.IGNORECASE))]),
    Group("5"),
    Group("6"),
    Group("7"),
    Group("8"),
    Group("9"),
]

wl_input_rules = {
    "type:keyboard": InputConfig(
        kb_options="caps:escape",
        kb_repeat_rate=50,
        kb_repeat_delay=250,
    ),

    "type:pointer": InputConfig(
        scroll_method="on_button_down",
        scroll_button=276,  # Your exact trackball button code
    ),
}

class QuietBattery(widget.Battery):
    def poll(self):
        try:
            status = self._battery.update_status()
        except RuntimeError:
            return ""
        return self.build_string(status)

def logout():
    qtile.stop()


def reboot():
    qtile.spawn("systemctl reboot")


def shutdown():
    qtile.spawn("systemctl poweroff")


def workspace_bindings():
    bindings = []
    for group_name, key_name in workspace_keys.items():
        bindings.append(Key([mod], key_name, lazy.group[group_name].toscreen()))
        bindings.append(Key([mod, "shift"], key_name, lazy.window.togroup(group_name)))
    return bindings


keys = [
    # apps / session
    Key([mod], "Return", lazy.spawn(terminal)),
    Key([mod], "d", lazy.spawncmd()),
    Key([mod], "q", lazy.window.kill()),
    Key([mod], "f", lazy.window.toggle_fullscreen()),
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod, "control"], "r", lazy.reload_config()),
    Key([mod], "t", lazy.window.toggle_floating()),

    # focus
    Key([mod], "h", lazy.layout.left()),
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod], "l", lazy.layout.right()),

    # move windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up()),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right()),

    # resize windows
    Key([mod, "control"], "h", lazy.layout.grow_left()),
    Key([mod, "control"], "j", lazy.layout.grow_down()),
    Key([mod, "control"], "k", lazy.layout.grow_up()),
    Key([mod, "control"], "l", lazy.layout.grow_right()),
    Key([mod], "n", lazy.layout.normalize()),

    # layout helpers
    Key([mod], "space", lazy.layout.next()),
    Key([mod, "shift"], "space", lazy.layout.toggle_split()),

    # session shortcuts
    Key([mod, "shift"], "q", lazy.shutdown()),
    Key([mod, "control"], "Delete", lazy.spawn("systemctl reboot")),
    Key([mod, "shift"], "Delete", lazy.spawn("systemctl poweroff")),

    # app launchers
    Key([mod], "e", lazy.spawn("emacs")),
    Key([mod], "w", lazy.spawn("qutebrowser")),
    Key([mod], "c", lazy.spawn("signal-desktop")),
    Key([mod], "v", lazy.spawn("element-desktop")),
    Key([mod], "s", lazy.spawn("pavucontrol")),

    Key([], "XF86AudioPlay", lazy.spawn("mpc toggle")),
    Key([], "XF86AudioNext", lazy.spawn("mpc next")),
    Key([], "XF86AudioPrev", lazy.spawn("mpc prev")),
    Key([], "XF86AudioStop", lazy.spawn("mpc stop")),

    Key([], "XF86AudioRaiseVolume", lazy.spawn("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
    Key([], "Print", lazy.spawn("sh -c 'grim ~/screenshot-$(date +%Y%m%d-%H%M%S).png'")),
] + workspace_bindings()

layouts = [
    layout.Columns(
        border_focus=colors["blue"],
        border_normal=colors["surface0"],
        
        border_focus_stack=colors["mauve"],
        border_normal_stack=colors["surface1"],
        
        border_width=3,
        margin=8,
        insert_position=1,
    ),
    layout.Max(
        border_focus=colors["blue"],
        border_normal=colors["surface0"],
        border_width=3,
        margin=8,
    ),
]

widget_defaults = {
    "font": "Iosevka Nerd Font",
    "fontsize": 13,
    "padding": 6,
    "background": colors["mantle"],
    "foreground": colors["text"],
}
extension_defaults = widget_defaults.copy()

mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod],
        "Button3",
        lazy.window.set_size_floating(),
        start=lazy.window.get_size(),
    ),
    Click(
        [mod],
        "Button2",
        lazy.window.bring_to_front(),
    ),
]


def segment_icon(text, color, background=None, padding=8, font=None, fontsize=None):
    return widget.TextBox(
        text=text,
        foreground=color,
        background=background or colors["surface0"],
        padding=padding,
        font=font or "Iosevka Nerd Font",
        fontsize=fontsize,
    )


def segment_sep(padding=6):
    return widget.Sep(
        linewidth=0,
        padding=padding,
        background=colors["mantle"],
    )


power_widget = widget.WidgetBox(
    text_closed="󰐥",
    text_open="󰐥",
    close_button_location="right",
    background=colors["mantle"],
    font="Iosevka Nerd Font",
    widgets=[
        widget.TextBox(
            text=" 󰑐 ",
            foreground=colors["blue"],
            background=colors["surface0"],
            padding=8,
            font="Iosevka Nerd Font",
            mouse_callbacks={"Button1": reboot},
        ),
        widget.TextBox(
            text=" 󰍃 ",
            foreground=colors["mauve"],
            background=colors["surface0"],
            padding=8,
            font="Iosevka Nerd Font",
            mouse_callbacks={"Button1": logout},
        ),
        widget.TextBox(
            text=" 󰐥 ",
            foreground=colors["red"],
            background=colors["surface0"],
            padding=8,
            font="Iosevka Nerd Font",
            mouse_callbacks={"Button1": shutdown},
        ),
    ],
)

screens = [
    Screen(
        wallpaper=wallpaper,
        wallpaper_mode="fill",
        top=bar.Bar(
            [
                widget.GroupBox(
                    font="Iosevka Nerd Font",
                    fontsize=13,
                    background=colors["mantle"],
                    active=colors["text"],
                    inactive=colors["overlay0"],
                    highlight_method="line",
                    highlight_color=[colors["mantle"], colors["mantle"]],
                    this_current_screen_border=colors["lavender"],
                    other_current_screen_border=colors["blue"],
                    this_screen_border=colors["surface2"],
                    other_screen_border=colors["surface1"],
                    urgent_border=colors["red"],
                    urgent_text=colors["red"],
                    borderwidth=2,
                    rounded=False,
                    disable_drag=True,
                    spacing=8,
                    padding_x=8,
                    padding_y=5,
                    margin_y=2,
                    margin_x=0,
                ),
                widget.Spacer(length=10),
                widget.Prompt(
                    name="prompt",
                    prompt="❯ ",
                    cursor_color=colors["blue"],
                    foreground=colors["text"],
                    background=colors["surface0"],
                    padding=10,
                    font="Iosevka Nerd Font",
                ),
                widget.Spacer(),

                segment_icon("󰖙", colors["blue"]),
                widget.Wttr(
                    background=colors["surface0"],
                    format="%l: %t %C",
                    update_interval=1800,
                    font="Iosevka Nerd Font",
                    foreground=colors["teal"],
                ),
                segment_sep(),

                segment_icon("󰎆", colors["green"]),
                widget.Mpd2(
                    background=colors["surface0"],
                    foreground=colors["green"],
                    status_format="{play_status} {artist} - {title}",
                    idle_format=" idle",
                    idle_message="idle",
                    max_chars=40,
                    padding=10,
                    hide_crash=True,
                    font="Iosevka Nerd Font",
                ),
                segment_sep(),

                segment_icon("󰂄", colors["yellow"]),
                QuietBattery(
                    background=colors["surface0"],
                    foreground=colors["yellow"],
                    format="{percent:2.0%}",
                    charge_char="󰂄",
                    discharge_char="󰁹",
                    full_char="󰁹",
                    empty_char="󰂎",
                    update_interval=30,
                    padding=10,
                    font="Iosevka Nerd Font",
                ),
                segment_sep(),

                segment_icon("󰂚", colors["peach"]),
                widget.Notify(
                    foreground=colors["peach"],
                    background=colors["surface0"],
                    default_timeout=10,
                    audiofile=SOUND,
                    padding=10,
                    font="Iosevka Nerd Font",
                ),
                segment_sep(),

                segment_icon("󰃭", colors["lavender"]),
                widget.Clock(
                    format="%a %d %b",
                    foreground=colors["lavender"],
                    background=colors["surface0"],
                    padding=10,
                    font="Lora",
                ),
                segment_icon("󰥔", colors["blue"]),
                widget.Clock(
                    format="%H:%M",
                    foreground=colors["blue"],
                    background=colors["surface0"],
                    padding=10,
                    font="Iosevka Nerd Font",
                ),

                widget.Spacer(length=10),
                power_widget,
                widget.Spacer(length=10),
            ],
            30,
            margin=[8, 10, 0, 10],
            background=colors["mantle"],
            opacity=0.97,
        ),
    ),
]

follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
auto_minimize = True
wmname = "Qtile"
# Config:1 ends here
