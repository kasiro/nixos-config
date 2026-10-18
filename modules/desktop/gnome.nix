# GNOME: дисплей-менеджер, DE, dconf
{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;

  services.desktopManager.gnome.enable = true;

  # Правильное решение для dconf в GDM
  programs.dconf.enable = true;
}
