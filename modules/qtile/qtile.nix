{ pkgs, ... }: {
  # Qtile как X11-сессия, которую GDM увидит наравне с GNOME
  # (Опционально) пакеты, которые Qtile будет искать в PATH
  # (например, для виджетов со звуком/яркостью)
  services.xserver.windowManager.qtile = {
    enable = true;
    # python-пакеты
    extraPackages = python3Packages: with python3Packages; [
      qtile-extras
      requests
      # pyyaml
    ];
  };
}
