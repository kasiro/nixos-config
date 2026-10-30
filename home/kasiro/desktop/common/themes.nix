# GTK/QT темы, иконки, курсоры — общие для всех DE (значения по умолчанию)
{ pkgs, lib, ... }:
{
  home.pointerCursor = lib.mkDefault {
    name = "default";
    package = pkgs.bibata-cursors;
  };

  gtk = {
    enable = lib.mkDefault true;
    iconTheme = {
      name = lib.mkDefault "Papirus-Dark";
      package = lib.mkDefault pkgs.papirus-icon-theme;
    };
  };
}
