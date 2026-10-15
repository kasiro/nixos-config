# home/qtile-config.py
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod4"  # Super (Win)
terminal = "alacritty"

keys = [
    Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle layout"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload"),
]

groups = [Group(i) for i in "123456789"]

layouts = [
    layout.MonadTall(),
    layout.Max(),
    layout.Tile(),
]

screens = [
    Screen(
        bottom=bar.Bar(
            [
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(),
                widget.Clock(format="%Y-%m-%d %H:%M"),
                widget.Systray(),
            ],
            24,
        ),
    ),
]

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating()),
    Drag([mod], "Button3", lazy.window.set_size_floating()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating()
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "LG3D"
