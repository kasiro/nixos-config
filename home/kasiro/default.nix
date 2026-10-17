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
    deezer-desktop
    # homebank # (посчитай налик)
  ];

  # Для Qtile (если вернёшь):
  # xdg.configFile."qtile/config.py".source = ../../modules/qtile/qtile-config.py;
}
