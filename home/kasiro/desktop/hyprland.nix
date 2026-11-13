# Hyprland configuration for home-manager
# Based on swrneko/dots-next
#
# Единственный источник конфига — ./hyprland/hyprland.lua (Lua API Hyprland 0.57).

{ pkgs, lib, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    # Сам Hyprland ставит NixOS-модуль programs.hyprland (flake input hyprland),
    # пакет из nixpkgs здесь не нужен.
    package = null;

    # xdg-desktop-portal-hyprland регистрирует NixOS-модуль programs.hyprland —
    # повторное подключение даёт коллизию user-юнитов «File exists».
    portalPackage = null;

    configType = "lua";
    systemd.enable = true;
    xwayland.enable = true;

    # В этой ревизии home-manager нет опций extraLuaFiles/sourceFile/configFile,
    # поэтому содержимое репозиториевского Lua вставляется в генерируемый
    # ~/.config/hypr/hyprland.lua через extraConfig.
    extraConfig = lib.fileContents ./hyprland/hyprland.lua;

    # Плагины Hyprland (из flake-входа hyprland-plugins)
    plugins = [
      # Плагины не требуются
    ];
  };

  # Noctalia — типизированный HM-модуль (flake-вход noctalia, импорт в
  # home/kasiro/default.nix). settings сериализуется pkgs.formats.toml в
  # ~/.config/noctalia/config.toml; пакет добавляется модулем сам.
  # Конфиг: swrneko/dots-next — Noctalia v5; документация:
  # https://docs.noctalia.dev/noctalia/configuration/
  # package задан явно: иначе mkDefault во flake-модуле подставит сборку пакета
  # из flake noctalia (на nixpkgs-unstable) вместо пакета из nixpkgs-26.05.
  # checkConfig = true (дефолт): конфиг валидируется «noctalia config validate»
  # при сборке.
  programs.noctalia = {
    enable = true;
    package = pkgs.noctalia;

    settings = {
      accessibility = {
        ui_scale = 1.05;
      };

      audio = {
        enable_sounds = true;
      };

      # Докбар: плавающий, авто-скрытие, почти прозрачный, поверх fullscreen
      dock = {
        enabled = true;
        position = "bottom";
        auto_hide = true;             # слайд-аут при уходе курсора
        margin_edge = 8;              # отступ 8 px от края экрана
        shadow = false;               # без тени
        reserve_space = false;        # не резервировать место под док
        background_opacity = 0.08;    # почти прозрачный
        layer = "overlay";            # wayland layer overlay (над fullscreen)
      };

      # Noctalia v5 использует bar.main вместо bar.default
      bar.default = {
        position = "top";
        background_opacity = 0.62;
        capsule = true;
        capsule_fill = "surface";
        center = [ "clock" "date" ];
        # "clipboard" — кнопка истории буфера обмена (открывает clipboard-панель)
        end = [ "clipboard" "tray" "sysmon" "bluetooth" "battery" "settings" "session" "control-center" ];
        font_family = "ComicShannsMono Nerd Font";
        margin_ends = 0;
        radius = 16;
        start = [ "launcher" "workspaces" "audio_visualizer" "active_window" ];
        thickness = 34;
        padding = 14;
        widget_spacing = 6;
        font_scale = 1.0;
        shadow = false;
        reserve_space = true;
      };

      # Местоположение: авто-определение по IP выключено
      location = {
        auto_locate = false;
      };

      # Встроенная погода выключена (open-meteo недоступен из сети, замена — плагин)
      weather = {
        enabled = false;
      };

      # Плагины Noctalia. Значения — зеркало GUI-слоя (~/.local/state/noctalia/
      # settings.toml): CLI включил плагин погоды и добавил персональный source.
      plugins = {
        # Автообновление git-source'ов выключено (обновлять вручную)
        auto_update = "none";
        # Включённые плагины: погода Цайюнь (personal) + официальные
        enabled = [
          "noctalia/timer"
          "noctalia/screen_recorder"
          "noctalia/wallhaven"
          "0x1ce/caiyun-weather"
        ];

        # Git-source'ы плагинов: official/community — встроенные дефолты,
        # personal — репо с плагином погоды caiyun-weather
        source = [
          {
            kind = "git";
            location = "https://github.com/noctalia-dev/official-plugins";
            name = "official";
          }
          {
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
            name = "community";
          }
          {
            kind = "git";
            location = "https://github.com/OHMCFXG/noctalia-plugins.git";
            name = "personal";
          }
        ];
      };

      # Координаты для плагина 0x1ce/caiyun-weather (Новосибирск).
      # Плагин читает их через plugin_settings (тип string в manifest).
      plugin_settings."0x1ce/caiyun-weather" = {
        latitude = "55.0226";
        longitude = "82.9317";
      };

      # Центр уведомлений (Control Center):
      # боковая панель при открытии вкладки — Полная; ширина — 800 px
      control_center = {
        sidebar_section = "full"; # full | compact | none
        width = 800;              # 600–1200, ширина full-sidebar режима
      };

      osd = {
        background_opacity = 0.58;
        offset_x = 8;
        offset_y = 15;
        position = "bottom_center";
      };

      shell = {
        corner_radius_scale = 2.0;
        font_family = "FiraCode Nerd Font";

        # Система → экранное время: вкл (учёт времени по приложениям для Control Center)
        screen_time_enabled = true;

        launcher = {
          provider_prefix = ">";
          layout = "full";
          app_grid = true;
          width = 760;
          show_icons = true;
          track_usage = true;
          sort_by_usage = true;

          providers.calculator = {
            global = false;
            prefix = "";
          };
        };

        panel = {
          launcher_placement = "floating";
          launcher_position = "center";
          open_near_click_launcher = false;
          transparency_mode = "glass";
        };

        screen_corners = {
          enabled = true;
          size = 28;
        };

        # shadow = {
        #   alpha = 1.0;
        #   direction = "center";
        # };
      };

      theme = {
        builtin = "Catppuccin";
        community_palette = "EnterpriseMaterial";
        mode = "dark";
        source = "community";
        wallpaper_scheme = "m3-content";

        templates = {
          builtin_ids = [ "cava" "gtk3" "gtk4" "kcolorscheme" "qt" ];
        };
      };

      # Экран блокировки: фон — снимок рабочего стола
      # (Безопасность → «Использовать снимок рабочего стола как фон экрана блокировки»)
      lockscreen = {
        blurred_desktop = true;
      };

      # Настройки виджетов в Noctalia v5 интегрированы в bar.main;
      # отдельные [widget.*] секции — для кастомных виджетов
      widget = {
        audio_visualizer = {
          bands = 128;
          width = 128;
        };

        launcher = {
          custom_image_colorize = true;
        };

        workspaces = {
          font_weight = 400;
          label_source = "name";
        };
      };

      # Input настройки для мыши/клавиатуры (Noctalia v5 / Umbriel)
      # Примечание: для Hyprland эти настройки НЕ применяются — используется hyprland.lua
      input = {
        mouse = {
          sensitivity = 0.0;
          natural_scroll = false;
          left_handed = false;
          accel_profile = "flat";
        };

        keyboard = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle";
          repeat_rate = 25;
          repeat_delay = 600;
        };
      };
    };
  };

  # Kitty — типизированный HM-модуль вместо plain kitty.conf.
  # settings сериализуется как «key value»; bool → yes/no; строки — как есть.
  programs.kitty = {
    enable = true;

    # shellIntegration.mode = null: HM по умолчанию ставит "no-rc" (пишет свою
    # shell_integration и вручную source'ит интеграцию в fish). Оставляем
    # исходное поведение — kitty.conf управляет сам через settings.
    shellIntegration.mode = null;

    settings = {
      # Font size (float сериализуется как «11», эквивалентно 11.0)
      font_size = 11.0;

      cursor_shape = "beam";
      cursor_trail = 10;
      wayland_titlebar_color = "system";
      linux_display_server = "wayland";
      remember_window_size = false;
      initial_window_state = "normal";

      # Не спрашивать подтверждение при закрытии окна с запущенным процессом
      confirm_os_window_close = 0;

      # Shell integration: только no-cursor, остальное — kitty по умолчанию
      shell_integration = "no-cursor";

      # Disable noise sound
      enable_audio_bell = false;

      # MAIN
      foreground = "#F5F3F2";
      background = "#1a1b26";
      background_opacity = 0.5;

      # Курсор и ввод
      cursor_text_color = "#1a1b26";

      # BLACK
      color0 = "#151720";
      color8 = "#151720";

      # RED
      color1 = "#ff7a93";
      color9 = "#ff7a93";

      # GREEN
      color2 = "#94e2d5";
      color10 = "#94e2d5";

      # YELLOW
      color3 = "#eed49f";
      color11 = "#eed49f";

      # BLUE
      color4 = "#bb9af7";
      color12 = "#bb9af7";

      # MAGENTA
      color5 = "#c6a0f6";
      color13 = "#c6a0f6";

      # CYAN
      color6 = "#b7bdf8";
      color14 = "#b7bdf8";

      # WHITE
      color7 = "#F5F3F2";
      color15 = "#F5F3F2";
    };

    # Генерируемый kitty-блок шрифтов (kitten choose-font его перезаписывает) —
    # вербатимно; programs.kitty.font НЕ задаём, чтобы не дублировать font_family.
    extraConfig = ''
      # BEGIN_KITTY_FONTS
      font_family      family="0xProto Nerd Font Mono"
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      # END_KITTY_FONTS
    '';
  };

  # Шрифты
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Шрифты
    nerd-fonts._0xproto
    nerd-fonts.comic-shanns-mono
    nerd-fonts.fira-code
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # Утилиты для Hyprland
    hyprlock
    hypridle
    hyprpicker
    hyprlang

    # Утилиты
    grim
    slurp
    wl-clipboard
    brightnessctl
    playerctl
    wireplumber
    pipewire
    pulseaudio

    # Файловый менеджер
    nemo
    nemo-fileroller

    # Системные
    btop
    xrdb
    xrandr
    xsetroot
    xprop
    xwininfo
    xdg-utils
  ];

  # XDG порталы (только gtk: hyprland-портал уже даёт NixOS-модуль)
  xdg.portal = {
    enable = lib.mkForce true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [
      hyprland
      noctalia
    ];
  };

  # Конфигурационные файлы
  xdg.configFile = {
    # Hyprlock конфиг
    "hypr/hyprlock.conf".source = ./hyprland/hyprlock.conf;

    # Скрипт группировки окон
    "hypr/scripts/group-all-windows.py" = {
      source = ./hyprland/scripts/group-all-windows.py;
      executable = true;
    };
  };
}
