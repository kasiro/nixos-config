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
    nix-your-shell
    nix-output-monitor
    nvtopPackages.nvidia
    update-nix-fetchgit
    winetricks
    repomix
    qbittorrent
    tree
    nh
    # homebank # (посчитай налик)
  ];

  # Для Qtile (если вернёшь):
  # xdg.configFile."qtile/config.py".source = ../../modules/qtile/qtile-config.py;
}
