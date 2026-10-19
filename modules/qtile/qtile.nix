# Исправлено 2026-10-19:
# - GDM запускал wayland-сессию qtile (пакет шипит оба .desktop),
#   но конфиг сделан под X11 → Systray/autostart не работали,
#   гонка wayland-бэкенда 'Core' object has no attribute 'qtile'
# - Фикс: wayland-сессия удаляется при сборке, GDM видит только X11-вход
{ pkgs, ... }:
let
  # GDM видит в пакете qtile оба десктопа (xsessions/qtile.desktop и
  # wayland-sessions/qtile.desktop, оба с Exec=qtile start) и выбирает
  # wayland-сессию → qtile стартует на wlroots-бэкенде, Systray не работает,
  # autostart.sh (xrandr, setxkbmap, cbatticon, volumeicon) не запускается.
  #
  # Опция backend = "x11" из модуля services.xserver.windowManager.qtile
  # ВЫПИЛЕНА в NixOS 26.05 (mkRemovedOptionModule: "The qtile package now
  # provides separate display sessions for both X11 and Wayland"), опция
  # services.displayManager.gdm.wayland тоже удалена ("no longer supported
  # with GNOME 50"). Поэтому вырезаем wayland-десктоп у самого пакета.
  #
  # Ловушка: модуль делает finalPackage = cfg.package.override { extraPackages },
  # а makeOverridable пересобирает derivation из исходных аргументов и
  # ОТКАТЫВАЕТ overrideAttrs. Поэтому переопределяем и .override, чтобы он
  # пропускал нашу правку пост-сборки.
  baseQtile = pkgs.python3Packages.qtile;
  x11Only =
    drv:
    drv.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          rm -f $out/share/wayland-sessions/qtile.desktop
        '';
    });
  qtileX11 = x11Only baseQtile // {
    override = args: x11Only (baseQtile.override args);
  };
in
{
  # Включаем X11 для GDM
  services.xserver.enable = true;

  # Qtile как X11-сессия, которую GDM увидит наравне с GNOME
  # Qtile работает ТОЛЬКО на X11 — Wayland сессия отключена
  services.xserver.windowManager.qtile = {
    enable = true;
    # package переопределяем: внутри qtileX11 убран wayland-десктоп,
    # чтобы GDM видел только X11-сессию qtile.
    # ВАЖНО: package не указываем "сырой" python3Packages.qtile — модуль сам
    # обернёт его через finalPackage с extraPackages (иначе в PATH попадает
    # бинарь без qtile_extras). Наш qtileX11 сохраняет .override.
    package = qtileX11;
    extraPackages =
      python3Packages: with python3Packages; [
        qtile-extras
        requests
      ];
  };

  # Включаем Picom с красивым блюром
  services.picom = {
    enable = true;
    backend = "glx"; # Используем OpenGL для рендеринга (быстрее и поддерживает блюр)
    fade = true;
    shadow = true;

    # Правильный синтаксис для шагов затухания: [fade_in fade_out]
    fadeSteps = [
      0.03
      0.03
    ];

    # Все специфичные настройки передаём через settings
    settings = {
      # Настройки блюра
      blur = {
        method = "dual_kawase"; # Самый красивый и оптимизированный метод блюра
        strength = 5; # Сила размытия (от 1 до 10)
        deviation = 1.0;
      };

      # Исключаем блюр для полноэкранных приложений и доков, чтобы не тормозило
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "fullscreen"
        "_GTK_FRAME_EXTENTS@:c"
      ];
    };
  };

  # Пакеты QtileDots на system-level
  # NOTE: python3Packages.qtile / qtile-extras здесь НЕ кладём — сырые пакеты
  # дают свой .desktop/bin, перебивая обёртку services.xserver.windowManager.qtile
  # (finalPackage с extraPackages). Модуль сам ставит обёрнутый qtile.
  environment.systemPackages = with pkgs; [
    alacritty
    firefox
    thunar
    rofi
    picom
    dunst
    nitrogen
    pamixer
    playerctl
    brightnessctl
    udiskie
    networkmanagerapplet
    nerd-fonts.ubuntu-mono
    cbatticon
    volumeicon
  ];

  # Копировать конфиги QtileDots пользователю при активации
  system.activationScripts.qtile-config = ''
    echo "Setting up Qtile config for kasiro..."
    mkdir -p /home/kasiro/.config/qtile
    cp -r ${../../modules/qtile/config.py} /home/kasiro/.config/qtile/config.py
    cp -r ${../../modules/qtile/settings} /home/kasiro/.config/qtile/settings
    cp -r ${../../modules/qtile/themes} /home/kasiro/.config/qtile/themes
    cp -r ${../../modules/qtile/autostart.sh} /home/kasiro/.config/qtile/autostart.sh
    cp -r ${../../modules/qtile/scripts} /home/kasiro/.config/qtile/scripts
    chown -R kasiro:users /home/kasiro/.config/qtile
  '';
}
