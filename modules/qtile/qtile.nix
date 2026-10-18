{ pkgs, ... }: {
  # Включаем X11 для GDM
  services.xserver.enable = true;

  # Qtile как X11-сессия, которую GDM увидит наравне с GNOME
  services.xserver.windowManager.qtile = {
    enable = true;
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
  environment.systemPackages = with pkgs; [
    python313Packages.qtile
    python313Packages.qtile-extras
    alacritty
    firefox
    thunar
    rofi-wayland
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
