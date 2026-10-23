# SwayFX — красивый конфиг в стиле Catppuccin Mocha
{ pkgs, lib, ... }:
let
  # Catppuccin Mocha палитра
  catppuccin = {
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
    text = "#cdd6f4";
    subtext0 = "#a6adc8";
    overlay0 = "#6c7086";
    surface0 = "#313244";
    surface1 = "#45475a";
    surface2 = "#585b70";
    blue = "#89b4fa";
    lavender = "#b4befe";
    sapphire = "#74c7ec";
    sky = "#89dceb";
    teal = "#94e2d5";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    peach = "#fab387";
    maroon = "#eba0ac";
    red = "#f38ba8";
    mauve = "#cba6f7";
    pink = "#f5c2e7";
    flamingo = "#f2cdcd";
    rosewater = "#f5e0dc";
  };

  mod = "Mod4";
  terminal = "${pkgs.foot}/bin/foot";
  menu = "${pkgs.wofi}/bin/wofi --show drun --allow-images";
  theme = import ../../../../themes/kasiro/theme.nix;
in
{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    config = rec {
      modifier = mod;
      inherit terminal;
      inherit menu;

      # --- Раскладка ---
      input = {
        "type:keyboard" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:alt_shift_toggle";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      # --- Оформление ---
      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        size = 11.0;
      };

      bars = [ ]; # Используем Waybar

      # Обои — сплошной цвет (Catppuccin base)
      output = {
        "*" = {
          bg = "${catppuccin.base} solid_color";
        };
      };

      # Отступы между окнами
      gaps = {
        inner = 10;
        outer = 6;
      };

      # Рамки окон
      window = {
        border = 2;
        titlebar = false;
      };
      floating.border = 2;

      # --- Цвета (Catppuccin Mocha) ---
      colors = {
        focused = {
          border = catppuccin.mauve;
          background = catppuccin.mantle;
          text = catppuccin.text;
          indicator = catppuccin.mauve;
          childBorder = catppuccin.mauve;
        };
        focusedInactive = {
          border = catppuccin.surface1;
          background = catppuccin.mantle;
          text = catppuccin.subtext0;
          indicator = catppuccin.surface1;
          childBorder = catppuccin.surface1;
        };
        unfocused = {
          border = catppuccin.surface0;
          background = catppuccin.mantle;
          text = catppuccin.overlay0;
          indicator = catppuccin.surface0;
          childBorder = catppuccin.surface0;
        };
        urgent = {
          border = catppuccin.red;
          background = catppuccin.mantle;
          text = catppuccin.text;
          indicator = catppuccin.red;
          childBorder = catppuccin.red;
        };
        placeholder = {
          border = catppuccin.surface2;
          background = catppuccin.mantle;
          text = catppuccin.subtext0;
          indicator = catppuccin.surface2;
          childBorder = catppuccin.surface2;
        };
      };

      # --- Горячие клавиши ---
      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+q" = "kill";
        "${mod}+a" = "exec ${menu}";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" = "exec ${pkgs.sway}/bin/swaynag -t warning -m 'Выйти из Sway?' -b 'Да' 'swaymsg exit'";

        # Движение фокуса (vim-style)
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
        "${mod}+g" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+d" = "focus parent";

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
        {
          command = "${pkgs.mako}/bin/mako";
        }
        {
          command = "${pkgs.waybar}/bin/waybar";
        }
        {
          command = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c ${catppuccin.crust}'";
        }
        {
          command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        }
      ];
    };

    # --- SwayFX специфичные настройки (через extraConfig) ---
    extraConfig = ''
      default_border pixel 3
      default_floating_border pixel 3
      corner_radius 10

      blur {
        enabled true
        xray true
        passes 2
        radius 8
        noise 0.02
        contrast 0.9
        brightness 0.95
      }

      # Правила для плавающих окон
      for_window [app_id="wofi"] floating enable, border pixel 0
      for_window [app_id="pavucontrol"] floating enable
      for_window [app_id="nm-connection-editor"] floating enable
    '';
  };

  # --- Waybar — красивая панель в стиле Catppuccin ---
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 4;
        margin-top = 6;
        margin-left = 6;
        margin-right = 6;
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
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            default = "";
          };
        };

        "sway/window" = {
          max-length = 50;
          tooltip = false;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " Mute";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pamixer -t";
          tooltip = false;
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ifname}";
          format-linked = "⚠ No IP";
          format-disconnected = "";
          tooltip = false;
        };

        cpu = {
          format = " {usage}%";
          interval = 5;
          tooltip = false;
        };

        memory = {
          format = " {used:0.1f}G/{total:0.1f}G";
          interval = 10;
          tooltip = false;
        };

        clock = {
          format = "{:%H:%M    %d.%m.%Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        tray = {
          spacing = 10;
          icon-size = 16;
        };
      }
    ];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        font-weight: 500;
        min-height: 0;
      }
      window#waybar {
        background: rgba(24, 24, 37, 0.85);
        color: #cdd6f4;
        border-radius: 12px;
        border: 1px solid #313244;
      }
      #workspaces {
        background: #313244;
        border-radius: 8px;
        margin: 4px 8px 4px 4px;
        padding: 2px 4px;
      }
      #workspaces button {
        padding: 4px 10px;
        color: #a6adc8;
        border-radius: 6px;
        margin: 2px;
        transition: all 0.2s ease;
      }
      #workspaces button:hover {
        background: #45475a;
        color: #cdd6f4;
      }
      #workspaces button.focused {
        background: #cba6f7;
        color: #1e1e2e;
        font-weight: bold;
      }
      #workspaces button.urgent {
        background: #f38ba8;
        color: #1e1e2e;
      }
      #mode {
        background: #f38ba8;
        color: #1e1e2e;
        border-radius: 6px;
        padding: 4px 10px;
        margin: 4px 0;
        font-weight: bold;
      }
      #window {
        color: #cdd6f4;
        padding: 4px 12px;
      }
      #pulseaudio, #network, #cpu, #memory, #clock {
        background: #313244;
        border-radius: 8px;
        padding: 4px 12px;
        margin: 4px 3px;
        color: #cdd6f4;
      }
      #pulseaudio { color: #89b4fa; }
      #network { color: #a6e3a1; }
      #cpu { color: #f9e2af; }
      #memory { color: #fab387; }
      #clock { color: #cba6f7; font-weight: bold; }
      #tray {
        background: #313244;
        border-radius: 8px;
        padding: 4px 8px;
        margin: 4px 4px 4px 8px;
      }
    '';
  };

  # --- Mako — уведомления в стиле Catppuccin ---
  services.mako = {
    enable = true;
    settings = {
      font = theme.font;
      background-color = "#181825";
      text-color = "#cdd6f4";
      border-color = "#cba6f7";
      border-radius = 10;
      default-timeout = 5000;
      layer = "overlay";
      padding = "12";
      margin = "10";
      width = 320;
      height = 120;
      anchor = "top-right";
    };
  };

  # --- Wofi — лаунчер в стиле Catppuccin ---
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      allow-images = true;
      hide-scroll = true;
      no-actions = true;
      width = 500;
      height = 400;
      location = "center";
      prompt = "🔍 Поиск...";
      filter_rate = 100;
      insensitive = true;
      gtk_dark = true;
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }
      window {
        background: #181825;
        color: #cdd6f4;
        border: 2px solid #cba6f7;
        border-radius: 12px;
      }
      #input {
        background: #313244;
        color: #cdd6f4;
        border: none;
        border-radius: 8px;
        padding: 10px;
        margin: 10px;
      }
      #input:focus {
        border: 2px solid #cba6f7;
      }
      #scroll {
        margin: 0 10px 10px 10px;
      }
      #entry {
        padding: 10px;
        border-radius: 6px;
        margin: 2px 0;
      }
      #entry:selected {
        background: #cba6f7;
        color: #1e1e2e;
        font-weight: bold;
      }
      #entry image {
        padding-right: 10px;
      }
    '';
  };

  # --- Курсор и GTK-тема ---
  home.sessionVariables = {
    XCURSOR_THEME = theme.cursorTheme;
    XCURSOR_SIZE = toString theme.cursorSize;
    GTK_THEME = "catppuccin-mocha-mauve-compact";
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-compact";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = theme.cursorTheme;
      package = pkgs.bibata-cursors;
      size = theme.cursorSize;
    };
  };
}
