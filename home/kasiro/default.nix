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
}
