# Hyprland configuration for home-manager
# Based on swrneko/dots-next

{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    
    settings = {
      # Мониторы — универсальный fallback
      monitor = [
        ",preferred,auto,auto"
      ];

      # Общие настройки
      general = {
        gaps_in = 5;
        gaps_out = 15;
        border_size = 3;
        "col.active_border" = "rgb(7366bd)";
        "col.inactive_border" = "rgb(4c4f69)";
        layout = "dwindle";
        allow_tearing = false;
        resize_on_border = true;
        extend_border_grab_area = 15;
      };

      # Декорации
      decoration = {
        rounding = 18;
        active_opacity = 1.0;
        fullscreen_opacity = 1.0;
        
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          popups = false;
          popups_ignorealpha = 0.15;
          ignore_opacity = true;
        };

        shadow = {
          enabled = false;
        };

        dim_inactive = true;
        dim_strength = 0.25;
        dim_around = 0.1;
      };

      # Ввод
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:win_space_toggle";
        force_no_accel = true;
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = false;
        };
      };

      # Dwindle layout
      dwindle = {
        preserve_split = true;
        force_split = 2;
      };

      # Курсор
      cursor = {
        no_warps = true;
        no_hardware_cursors = true;
      };

      # XWayland
      xwayland = {
        enabled = true;
        force_zero_scaling = true;
        use_nearest_neighbor = true;
      };

      # Группы
      group = {
        auto_group = false;
      };

      # Разное
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        layers_hog_keyboard_focus = true;
      };

      # Анимации
      animations = {
        enabled = true;
        
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1"
          "winIn, 0.1, 1, 0.1, 1.05"
          "winOut, 0.3, 0, 0, 1"
          "layIn, 0.1, 1, 0.1, 1.1"
          "layOut, 0.3, 0, 0, 1"
          "liner, 1, 1, 1, 1"
        ];

        animation = [
          "windows, 6, wind, slide"
          "windowsIn, 6, winIn, slide"
          "windowsOut, 6, winOut, slide"
          "windowsMove, 6, wind, slide"
          "border, 1, liner"
          "borderangle, 30, liner, loop"
          "fade, 10, default"
          "workspaces, 5, wind"
          "specialWorkspaceIn, 5, winIn, slidevert"
          "specialWorkspaceOut, 6, winOut, slidevert"
          "layersIn, 5, layIn, slide"
          "layersOut, 5, layOut, slide"
        ];
      };

      # Привязки клавиш
      bind = [
        # Программы
        "SUPER, Return, exec, kitty"
        "SUPER, E, exec, nemo"
        "SUPER, Y, exec, zen-browser"
        "SUPER, D, exec, noctalia msg panel-toggle launcher"
        "SUPER, U, exec, kitty -e btop"

        # Режимы окон
        "SUPER, M, exec, hyprctl dispatch workspace togglespecial:magic"
        "SUPER SHIFT, F, exec, hyprctl dispatch fullscreen toggle"
        "SUPER SHIFT, T, exec, hyprctl dispatch layoutmsg togglesplit"
        "SUPER SHIFT, M, movetoworkspace, special:magic"
        "SUPER SHIFT, S, togglefloating"
        "SUPER SHIFT, P, pseudo"

        # Система
        "SUPER SHIFT, Q, killactive"
        "SUPER SHIFT ALT, E, exit"
        "SUPER CONTROL, L, exec, hyprlock"

        # Яркость
        ", XF86MonBrightnessUp, exec, brightnessctl set +2%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 2%-"

        # Громкость
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # Циклинг
        "SUPER, Tab, cyclenext, prev"
        "ALT, Tab, bringactivetotop"

        # Скриншоты
        ", Print, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        "SUPER SHIFT, Print, exec, mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp -d)\" - | tee ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S').png | wl-copy"

        # Навигация стрелками
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"

        # Перемещение окон стрелками
        "SUPER SHIFT, left, swapwindow, l"
        "SUPER SHIFT, right, swapwindow, r"
        "SUPER SHIFT, up, swapwindow, u"
        "SUPER SHIFT, down, swapwindow, d"

        # Перемещение мышью стрелками
        "SUPER ALT, left, movewindow, l"
        "SUPER ALT, right, movewindow, r"
        "SUPER ALT, up, movewindow, u"
        "SUPER ALT, down, movewindow, d"

        # Ресайз стрелками
        "SUPER CONTROL, left, resizewindow, -20 0"
        "SUPER CONTROL, right, resizewindow, 20 0"
        "SUPER CONTROL, up, resizewindow, 0 -20"
        "SUPER CONTROL, down, resizewindow, 0 20"

        # Циклинг floating/tiled
        "SUPER, N, cyclenext, floating"
        "SUPER SHIFT, N, cyclenext, tiled"

        # Воркспейсы 1-10
        "CONTROL, 1, workspace, 1"
        "CONTROL, 2, workspace, 2"
        "CONTROL, 3, workspace, 3"
        "CONTROL, 4, workspace, 4"
        "CONTROL, 5, workspace, 5"
        "CONTROL, 6, workspace, 6"
        "CONTROL, 7, workspace, 7"
        "CONTROL, 8, workspace, 8"
        "CONTROL, 9, workspace, 9"
        "CONTROL, 0, workspace, 10"

        # Перемещение на воркспейсы
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"

        # Скролл мыши для воркспейсов
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"

        # Drag/resize мышью
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      # Привязки с repeat
      bindm = [
        "SUPER CONTROL, left, resizewindow, -20 0"
        "SUPER CONTROL, right, resizewindow, 20 0"
        "SUPER CONTROL, up, resizewindow, 0 -20"
        "SUPER CONTROL, down, resizewindow, 0 20"
      ];

      # Правила окон
      windowrule = [
        "float, Waydroid"
        "fullscreen, Waydroid"
        "noblur, xwayland:1"
        "nofocus,noinitialfocus, xwayland:1 floating:1"
        "nodim, floating:1"
        "float center, title:^(Open|Save|Choose|Select|Library|File Upload|Choose wallpaper)(.*)$"
      ];

      # Правила слоёв
      layerrule = [
        "blur, noctalia-(bar|desktop-widget)-.*"
        "ignorealpha 0.35, noctalia-(bar|desktop-widget)-.*"
        "animation fade, logout_dialog"
        "animation fade, selection"
      ];

      # Правила воркспейсов с именами
      workspace = [
        "1, defaultname:1"
        "2, defaultname:2"
        "3, defaultname:3"
        "4, defaultname:4"
        "5, defaultname:5"
        "6, defaultname:6"
        "7, defaultname:7"
        "8, defaultname:8"
        "9, defaultname:9"
        "10, defaultname:10"
      ];
    };
  };

  # Переменные окружения
  wayland.windowManager.hyprland.extraConfig = ''
    # Environment variables
    env = XDG_CURRENT_DESKTOP,Hyprland
    env = QT_SCALE_FACTORS,1.3
    env = QT_ENABLE_HIGHDPI_SCALING,1
    env = QT_FONT_DPI,81
    env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
    env = QT_QPA_PLATFORMTHEME,qt5ct
    env = QT_QPA_PLATFORM,wayland;xcb
    env = QT_SCALE_FACTOR_ROUNDING_POLICY,RoundPreferFloor
    env = GTK_SCALE,1
    env = GDK_DPI_SCALE,1
    env = GTK_USE_PORTAL,1
    env = XCURSOR_SIZE,24
    env = HYP RCURSOR_THEME,afterglow
    env = HYP RCURSOR_SIZE,24
    # NVIDIA environment variables (требуется для legacy_580)
    env = LIBVA_DRIVER_NAME,nvidia
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    env = GBM_BACKEND,nvidia-drm
  '';

  # Автозапуск
  wayland.windowManager.hyprland.systemd.variables = {
    Hyprland = [
      "hyprpm reload"
      "hyprlock"
      "noctalia -d"
      "/run/wrappers/bin/xdg-desktop-portal-hyprland"
      "/run/wrappers/bin/xdg-desktop-portal-gtk"
      "xrdb ~/.Xresources"
    ];
  };

  # Шрифты
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Шрифты
    (nerdfonts.override { fonts = [ "0xProto" "ComicShannsMono" ]; })
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    
    # Утилиты для Hyprland
    hyprlock
    hypridle
    hyprpicker
    hyprlang
    
    # Noctalia
    noctalia
    
    # Терминал
    kitty
    
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
    xorg.xrdb
    xorg.xrandr
    xorg.xsetroot
    xorg.xprop
    xorg.xwininfo
    xdg-utils
  ];

  # XDG порталы
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [
      hyprland
      noctalia
    ];
  };

  # Конфигурационные файлы
  xdg.configFile = {
    # Lua конфиг для Hyprland 0.55+
    "hypr/hyprland.lua".source = ./hyprland/hyprland.lua;
    
    # Noctalia конфиг
    "noctalia/config.toml".source = ./hyprland/noctalia.toml;
    
    # Kitty конфиг
    "kitty/kitty.conf".source = ./hyprland/kitty.conf;
    
    # Hyprlock конфиг
    "hypr/hyprlock.conf".source = ./hyprland/hyprlock.conf;
  };
}
