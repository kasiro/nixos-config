# COSMIC-specific systemd сервисы
{ ... }:
{
  systemd.user.services = {
    cosmic-settings-daemon = {
      Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=cosmic";
    };
  };
}
