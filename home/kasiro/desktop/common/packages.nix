# Общие пакеты для всех DE
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Утилиты
    tree
    qbittorrent
    winetricks
    repomix
  ];
}
