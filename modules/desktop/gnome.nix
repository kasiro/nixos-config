# GNOME: дисплей-менеджер, DE, dconf
{ ... }:
{
  # services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;
}
