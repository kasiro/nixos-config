# Sway — декларативный конфиг через Home Manager
{ pkgs, lib, ... }:
let
  theme = import ../../../../themes/kasiro/theme.nix;
  mod = "Mod4"; # Super (Win)
  terminal = "${pkgs.foot}/bin/foot";
in
{
  wayland.windowManager.sway = {
    enable = true;
    package = null; # Берём системный sway из programs.sway
    config = rec {
      modifier = mod;
      inherit terminal;
      menu = "${pkgs.wofi}/bin/wofi --show drun";

      # --- Раскладка ---
      input = {
        "type:keyboard" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:shift_alt_toggle";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      # --- Оформление ---
      fonts = {
        names = [
          "JetBrainsMono Nerd Font"
          "monospace"
        ];
        size = 11.0;
      };
      bars = [ ]; # Отключаем встроенную — используем waybar ниже
      output = {
        "*" = {
          bg = "${pkgs.swaybg}/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill";
        };
      };
      gaps = {
        inner = 8;
        outer = 4;
      };
      window = {
        border = 2;
        titlebar = false;
      };
      floating.border = 2;

      # --- Цвета (Nord-подобная палитра) ---
      colors = {
        focused = {
          border = "#5294e2";
          background = "#5294e2";
          text = "#ffffff";
          indicator = "#5294e2";
          childBorder = "#5294e2";
        };
        focusedInactive = {
          border = "#2e3440";
          background = "#2e3440";
          text = "#ffffff";
          indicator = "#2e3440";
          childBorder = "#2e3440";
        };
        unfocused = {
          border = "#2e3440";
          background = "#2e3440";
          text = "#888888";
          indicator = "#2e3440";
          childBorder = "#2e3440";
        };
        urgent = {
          border = "#e74c3c";
          background = "#e74c3c";
          text = "#ffffff";
          indicator = "#e74c3c";
          childBorder = "#e74c3c";
        };
      };

      # --- Горячие клавиши ---
      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+q" = "kill";
        "${mod}+d" = "exec ${menu}";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" =
          "exec ${pkgs.sway}/bin/swaynag -t warning -m 'Выйти из Sway?' -b 'Да' 'swaymsg exit'";

        # Движение
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        # Перемещение окон
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # Рабочие столы
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";

        # Layout
        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+a" = "focus parent";

        # Resize mode
        "${mod}+r" = "mode resize";

        # Скриншоты
        "Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy";
        "${mod}+Print" =
          "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";

        # Медиа/звук
        "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
        "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
        "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      };

      # --- Режим resize ---
      modes.resize = {
        "h" = "resize shrink width 10 px";
        "j" = "resize grow height 10 px";
        "k" = "resize shrink height 10 px";
        "l" = "resize grow width 10 px";
        "Escape" = "mode default";
        "Return" = "mode default";
      };

      # --- Автозапуск ---
      startup = [
        { command = "${pkgs.mako}/bin/mako"; }
        { command = "${pkgs.waybar}/bin/waybar"; }
        {
          command = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 000000'";
        }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
      ];
    };

    # --- Waybar (отдельно, т.к. это не часть sway-конфига) ---
    extraConfig = ''
      # Любые дополнительные строки, которые не покрываются HM-опциями
    '';
  };

  # --- Waybar ---
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 28;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "clock"
          "tray"
        ];
        "sway/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
        };
        clock = {
          format = "{:%Y-%m-%d %H:%M}";
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
        };
        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ifname}";
          format-linked = "⚠";
          format-disconnected = "⚠";
        };
        cpu = {
          format = " {usage}%";
        };
        memory = {
          format = " {used:0.1f}G/{total:0.1f}G";
        };
        tray = {
          spacing = 10;
        };
      }
    ];
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 12px;
      }
      window#waybar { background: #2e3440; color: #ffffff; }
      #workspaces button { padding: 0 8px; color: #888888; border: none; }
      #workspaces button.focused { background: #5294e2; color: #ffffff; }
      #clock, #pulseaudio, #network, #cpu, #memory, #tray { padding: 0 10px; }
    '';
  };

  # --- Mako (нотификации) ---
  services.mako = {
    enable = true;
    font = theme.font;
    backgroundColor = "#2e3440";
    textColor = "#ffffff";
    borderColor = "#5294e2";
    defaultTimeout = 5000;
    layer = "overlay";
  };

  # --- Курсор (из темы kasiro) ---
  home.sessionVariables = {
    XCURSOR_THEME = theme.cursorTheme;
    XCURSOR_SIZE = toString theme.cursorSize;
  };
  gtk.cursorTheme = {
    name = theme.cursorTheme;
    size = theme.cursorSize;
  };
}
