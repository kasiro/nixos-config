import os
import subprocess

from libqtile import bar, hook, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"  # Super (Win)
terminal = guess_terminal()

# Горячие клавиши
keys = [
    # Терминал
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Закрытие окна
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    # Переключение раскладки
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    # Перезагрузка конфига
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    # Выход из Qtile
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Меню приложений (rofi)
    Key([mod], "d", lazy.spawn("rofi -show-drun"), desc="Launch app launcher"),
    # Переключение между окнами
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Перемещение окон
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Изменение размера окон
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Переключение окна в плавающий режим
    Key([mod, "shift"], "f", lazy.window.toggle_floating(), desc="Toggle floating"),
    # Полноэкранный режим
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
]

# Группы (рабочие столы)
groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend(
        [
            # Переключение на группу
            Key([mod], i.name, lazy.group[i.name].toscreen()),
            # Перемещение окна в группу
            Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
        ]
    )

# Лейауты (раскладки окон)
layouts = [
    layout.MonadTall(
        margin=8,
        border_width=2,
        border_focus="#5294e2",
        border_normal="#2e3440",
    ),
    layout.MonadWide(
        margin=8,
        border_width=2,
        border_focus="#5294e2",
        border_normal="#2e3440",
    ),
    layout.Max(
        margin=8,
        border_width=2,
        border_focus="#5294e2",
        border_normal="#2e3440",
    ),
    layout.Floating(
        border_focus="#5294e2",
        border_normal="#2e3440",
    ),
]

# Виджеты для панели
widget_defaults = {
    "font": "JetBrainsMono Nerd Font",
    "fontsize": 12,
    "padding": 3,
}
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    font="JetBrainsMono Nerd Font",
                    fontsize=14,
                    margin_y=3,
                    margin_x=0,
                    padding_y=5,
                    padding_x=3,
                    borderwidth=3,
                    active="#ffffff",
                    inactive="#808080",
                    rounded=False,
                    highlight_color="#2e3440",
                    highlight_method="line",
                    this_current_screen_border="#5294e2",
                    this_screen_border="#5294e2",
                    other_current_screen_border="#2e3440",
                    other_screen_border="#2e3440",
                    foreground="#ffffff",
                    background="#2e3440",
                ),
                widget.Separator(
                    linewidth=0,
                    padding=6,
                    foreground="#2e3440",
                    background="#2e3440",
                ),
                widget.WindowName(
                    foreground="#ffffff",
                    background="#2e3440",
                    font="JetBrainsMono Nerd Font",
                    fontsize=12,
                ),
                widget.Systray(
                    background="#2e3440",
                    padding=5,
                ),
                widget.Separator(
                    linewidth=0,
                    padding=6,
                    foreground="#2e3440",
                    background="#2e3440",
                ),
                widget.CurrentLayout(
                    foreground="#ffffff",
                    background="#2e3440",
                    font="JetBrainsMono Nerd Font",
                    fontsize=12,
                ),
                widget.Separator(
                    linewidth=0,
                    padding=6,
                    foreground="#2e3440",
                    background="#2e3440",
                ),
                widget.KeyboardLayout(
                    configured_keyboards=["us", "ru"],
                    foreground="#ffffff",
                    background="#2e3440",
                    font="JetBrainsMono Nerd Font",
                    fontsize=12,
                ),
                widget.Separator(
                    linewidth=0,
                    padding=6,
                    foreground="#2e3440",
                    background="#2e3440",
                ),
                widget.Volume(
                    foreground="#ffffff",
                    background="#2e3440",
                    font="JetBrainsMono Nerd Font",
                    fontsize=12,
                ),
                widget.Separator(
                    linewidth=0,
                    padding=6,
                    foreground="#2e3440",
                    background="#2e3440",
                ),
                widget.Clock(
                    format="%Y-%m-%d %H:%M",
                    foreground="#ffffff",
                    background="#2e3440",
                    font="JetBrainsMono Nerd Font",
                    fontsize=12,
                ),
            ],
            24,
            background="#2e3440",
            border_width=[0, 0, 2, 0],
            border_color=["000000", "000000", "5294e2", "000000"],
        ),
    ),
]

# Настройки мыши
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# Настройки плавающих окон
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ],
    border_focus="#5294e2",
    border_normal="#2e3440",
    border_width=2,
)


# Автозапуск приложений
@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser("~")
    subprocess.Popen([home + "/.config/qtile/autostart.sh"])


# Настройки
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "LG3D"
