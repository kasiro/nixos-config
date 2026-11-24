# Hyprland configuration for home-manager
# Based on swrneko/dots-next
#
# Единственный источник конфига — ./hyprland/hyprland.lua (Lua API Hyprland 0.57).

{ pkgs, lib, ... }:

# Пиннутые ревизии репозиториев плагинов Noctalia (rev из catalog.toml каждого
# репозитория, выбранные под plugin_api 3..30 noctalia v5.0.1):
#   official-plugins @ 03411380 — notes 1.3.0 (api 26, первый коммит 1.3.0)
#   official-plugins @ 8c6b90fa — mpvpaper 1.2.1 (api 26, release-строка каталога)
#   official-plugins @ 73d4aea7 — timer 1.5.0 (api 20, release-строка каталога)
#   official-plugins @ f4aafbda — wallhaven 1.3.1 (api 26, release-строка каталога)
#   community-plugins @ a4e31fa3 — noctes 0.20.1 (api 26, release-строка каталога)
# Каждый path-каталог — одна ревизия, поэтому в нём symlink ровно одного
# плагина; noctalia читает <source>/<subdir>/plugin.toml, где subdir — часть id
# после «author/» (pluginSubdirFromId отбрасывает автора: «noctalia/notes» → notes/).
let
  officialMpvpaperSrc = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "official-plugins";
    rev = "8c6b90fa92519bd2da1dd8b5f2cc940cce08367f";
    hash = "sha256-sPxOFsGN3rCJ56gUtSRShvYOv1H11nqA+4FL0iraoac=";
  };
  officialTimerSrc = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "official-plugins";
    rev = "73d4aea7bd3f18d30f5f74ed5dc874eab1c664d6";
    hash = "sha256-1uVa2RNSWayBvm+4Z330vanrkWuOfIFCZwfQD4qJ19g=";
  };
  officialWallhavenSrc = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "official-plugins";
    rev = "f4aafbda29540bd1abebddd07fb5192704afa2a5";
    hash = "sha256-mvrLkM7M53EHVmr/mMAIpwalLiVH9c9SQusKA9gJDho=";
  };
  communityPluginsSrc = pkgs.fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "community-plugins";
    rev = "3f6037a1ee9ce3a1028f66a94bf469d13276b7ec";
    hash = "sha256-UXxQUp02YFqayCcYz8pr5OWPVuicDgGAGCxAasuz56g=";
  };

  noctaliaMpvpaperPlugin = pkgs.runCommand "noctalia-mpvpaper-plugin" { } ''
    mkdir -p $out
    ln -s ${officialMpvpaperSrc}/mpvpaper $out/mpvpaper
  '';

  noctaliaTimerPlugin = pkgs.runCommand "noctalia-timer-plugin" { } ''
    mkdir -p $out
    ln -s ${officialTimerSrc}/timer $out/timer
  '';

  noctaliaWallhavenPlugin = pkgs.runCommand "noctalia-wallhaven-plugin" { } ''
    mkdir -p $out
    ln -s ${officialWallhavenSrc}/wallhaven $out/wallhaven
  '';

  noctaliaSettingsToNixPlugin = pkgs.runCommand "noctalia-settings-to-nix-plugin" { } ''
    mkdir -p $out
    ln -s ${communityPluginsSrc}/settings-to-nix $out/settings-to-nix
  '';

  # Плагины Noctalia — единый источник для ручного слоя и GUI-экспорта ниже.
  # Значения — зеркало GUI-слоя (~/.local/state/noctalia/settings.toml):
  # CLI включил плагин погоды и добавил персональный source.
  # Автообновление git-source'ов выключено (обновлять вручную).
  noctaliaPluginsAutoUpdate = "none";
  noctaliaPluginsEnabled = [
    "noctalia/timer"
    "noctalia/wallhaven"
    # Плагины из path-источников ниже (nix store, пиннутые ревизии)
    "noctalia/mpvpaper"
    "dmopp/settings-to-nix"
  ];
  # Git-source'ы плагинов: official/community — встроенные дефолты,
  # personal — репо с плагином погоды caiyun-weather. Path-источники
  # (nix store): поздние перекрывают ранние; в каждом каталоге ровно один
  # плагин. Обновление/удаление для них — no-op, auto_update их не касается.
  noctaliaPluginsSource = [
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
        {
      kind = "path";
      location = "${noctaliaMpvpaperPlugin}";
      name = "nix-mpvpaper";
    }
    {
      kind = "path";
      location = "${noctaliaSettingsToNixPlugin}";
      name = "nix-settings-to-nix";
    }
    {
      kind = "path";
      location = "${noctaliaTimerPlugin}";
      name = "nix-timer";
    }
    {
      kind = "path";
      location = "${noctaliaWallhavenPlugin}";
      name = "nix-wallhaven";
    }
  ];

  # Экспорт GUI-настроек noctalia (плагин dmopp/settings-to-nix зеркалит
  # state-слой в файл ./hyprland/noctalia-gui-settings.nix автоматически).
  # settings-attrset мержится ПОВЕРХ ручного слоя в programs.noctalia.settings.
  noctaliaGuiSettings =
    let
      gui = (import ./hyprland/noctalia-gui-settings.nix { inherit pkgs; }).settings;
    in
    gui // {
      # plugins из экспорта не годятся как есть: enabled урезан (нет
      # notes/noctes/caiyun-weather), в source зашит store-путь прошлой
      # сборки, а auto_update = "all" включает автообновление git-source'ов.
      # Берём значения из ручного слоя (списки выше — единый источник).
      plugins = {
        auto_update = noctaliaPluginsAutoUpdate;
        enabled = noctaliaPluginsEnabled;
        source = noctaliaPluginsSource;
      };
    };
in
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

    # Плагины Hyprland
    # plugins = [
    #   # Плагины не требуются
    # ];
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

    # settings: ручной слой снизу, GUI-экспорт ПОВЕРХ (noctaliaGuiSettings
    # побеждает при recursiveUpdate — плагин dmopp/settings-to-nix зеркалит
    # актуальный state-слой, ручной attrset остаётся как fallback/основа).
    settings = lib.recursiveUpdate {
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

      # Плагины Noctalia — значения из let-блока (единый источник с
      # GUI-экспортом; в самом экспорте списки урезаны/с протухшими путями).
      plugins = {
        auto_update = noctaliaPluginsAutoUpdate;
        enabled = noctaliaPluginsEnabled;
        source = noctaliaPluginsSource;
      };

      # Координаты для плагина 0x1ce/caiyun-weather (Новосибирск) удалены
      # вместе с самим блоком: плагин выпал из enabled (WARN 6).

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
          app_grid = true;
          show_icons = true;
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
          builtin_ids = [ "cava" "gtk3" "gtk4" "kcolorscheme" "qt" "hyperland" "ghostty" "btop" "alacritty" ];
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
    } noctaliaGuiSettings;
  };

  # Шрифты
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Шрифты
    # nerd-fonts._0xproto
    # nerd-fonts.comic-shanns-mono
    # nerd-fonts.fira-code
    # noto-fonts-cjk-sans
    # noto-fonts-cjk-serif

    # Утилиты для Hyprland
    # hyprlock
    # hypridle
    # hyprpicker
    # hyprlang

    # Утилиты
    # grim
    # slurp
    # wl-clipboard
    # brightnessctl
    # playerctl
    # wireplumber
    # pipewire
    # pulseaudio

    # Системные
    # btop
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
      noctalia
    ];
  };

  # Конфигурационные файлы
  xdg.configFile = {
    # Hyprlock конфиг
    "hypr/hyprlock.conf".source = ./hyprland/hyprlock.conf;
  };
}
