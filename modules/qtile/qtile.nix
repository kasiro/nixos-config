{ pkgs, ... }: {
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
    fading = true;
    fade-in-step = 0.03;
    fade-out-step = 0.03;

    # Настройки блюра
    blur = {
      enable = true;
      method = "dual_kawase"; # Самый красивый и оптимизированный метод блюра
      strength = 5; # Сила размытия (от 1 до 10)
      deviation = 1.0;
    };

    # Исключаем блюр для полноэкранных приложений и доков, чтобы не тормозило
    settings = {
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "fullscreen"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      # Делаем полупрозрачные терминалы (если захочешь)
      # opacity-rule = [ "90:class_g = 'Alacritty'" ];
    };
  };
}
