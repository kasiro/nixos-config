{ pkgs, ... }: {
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages =
      python3Packages: with python3Packages; [
        qtile-extras
        requests
      ];
  };

  services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
    shadow = true;
    fading = true;
    fade-in-step = 0.03;
    fade-out-step = 0.03;

    # Правильный синтаксис для blur через settings
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 5;
        deviation = 1.0;
      };

      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "fullscreen"
        "_GTK_FRAME_EXTENTS@:c"
      ];
    };
  };
}
