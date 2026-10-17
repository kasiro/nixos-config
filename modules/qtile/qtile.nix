{ pkgs, ... }: {
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
}
