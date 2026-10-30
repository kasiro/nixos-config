# GNOME-specific systemd сервисы
{ config, pkgs, ... }:
{
  systemd.user.services = {
    gnome-keyring = {
      Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=GNOME";
    };
    polkit-gnome = {
      Unit = {
        Description = "PolicyKit GNOME Authentication Agent";
        ConditionEnvironment = "XDG_CURRENT_DESKTOP=GNOME";
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
