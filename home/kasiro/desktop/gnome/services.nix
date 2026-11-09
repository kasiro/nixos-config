# GNOME-specific systemd сервисы
{ config, pkgs, ... }:
{
  systemd.user.services = {
    # gnome-keyring НЕ переопределяем: юнит с корректным ExecStart определён
    # в modules/desktop/sway.nix и работает во всех сессиях (Sway, Hyprland,
    # GNOME). Перекрытие без Service.ExecStart давало
    # «Service has no ExecStart= … Refusing».
    #
    # polkit-агент — без условия по DE, иначе в Sway/Hyprland его нет.
    polkit-gnome = {
      Unit = {
        Description = "PolicyKit GNOME Authentication Agent";
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
