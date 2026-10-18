# GNOME: дисплей-менеджер, DE, dconf
{ pkgs, ... }:
{
  services.displayManager.gdm = {
    enable = true;
    # Отключить GNOME Shell в GDM — нужен только greeter
    wayland = true;
    # Использовать простой greeter без GNOME Shell
    # autoLogin отключён — требуется ручной вход
    # autoLogin = { user = "kasiro"; };  # раскомментировать для авто-входа
  };

  services.desktopManager.gnome.enable = true;

  # Правильное решение для dconf в GDM
  programs.dconf.enable = true;
}
