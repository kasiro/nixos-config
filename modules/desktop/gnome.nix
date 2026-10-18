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
  programs.dconf = {
    enable = true;
  };
  
  services.displayManager.gdm.systemDb = {
    enable = true;
    # Создать системную БД dconf для GDM
    profiles.gdm = {
      settings = {
        # Отключить GNOME Shell — только greeter
        "org/gnome/shell" = {
          disable-user-extensions = true;
        };
      };
    };
  };
  
  # Сессия по умолчанию — Sway, не GNOME
  environment.sessionVariables = {
    DESKTOP_SESSION = "sway";
  };
}
