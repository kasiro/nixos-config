# GNOME: дисплей-менеджер, DE, dconf
{ pkgs, ... }:
{
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  programs.dconf.enable = true;
}
