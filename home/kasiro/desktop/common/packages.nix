# Общие пакеты для всех DE
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Утилиты
    tree
    qbittorrent
    winetricks
    repomix
    mpvpaper # mp4 как обои (sway)
    socat
    mpv
  ];
}
