{
  pkgs,
  ...
}:
{
  imports = [
    ./desktop
    ./programs
    ./shell
    ./fish.nix
    ../common
  ];

  home.username = "kasiro";

  # Пакеты только для kasiro
  home.packages = with pkgs; [
    nvtopPackages.nvidia
    winetricks
    repomix
    qbittorrent
    tree
    # homebank # (посчитай налик)
  ];

  # Для Qtile:
  xdg.configFile."qtile/config.py".source = ../../modules/qtile/config.py;
  xdg.configFile."qtile/settings".source = ../../modules/qtile/settings;
  xdg.configFile."qtile/themes".source = ../../modules/qtile/themes;
  xdg.configFile."qtile/autostart.sh".source = ../../modules/qtile/autostart.sh;
  xdg.configFile."qtile/scripts".source = ../../modules/qtile/scripts;
}
