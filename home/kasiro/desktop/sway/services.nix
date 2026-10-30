# Sway-specific systemd сервисы
{ pkgs, ... }:
{
  # swayidle как systemd сервис (альтернатива startup)
  systemd.user.services.swayidle = {
    Unit = {
      Description = "Sway idle manager";
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 1e1e2e'";
      Restart = "on-failure";
    };
  };
}
