# GTK/QT темы, иконки, курсоры — общие для всех DE (значения по умолчанию)
{ pkgs, lib, ... }:
{
  home.pointerCursor = lib.mkDefault {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
  };

  gtk = {
    enable = lib.mkDefault true;
    theme = {
      name = lib.mkDefault "Catppuccin-Mocha-Standard-Blue-Dark";
      package = lib.mkDefault pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = lib.mkDefault "Papirus-Dark";
      package = lib.mkDefault pkgs.papirus-icon-theme;
    };
  };

  qt = {
    enable = lib.mkDefault true;
    platformTheme = lib.mkDefault "gtk";
    style = lib.mkDefault "gtk";
  };
}
