# GNOME-specific systemd сервисы
{ ... }:
{
  systemd.user.services = {
    gnome-keyring = {
      Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=GNOME";
    };
    polkit-gnome = {
      Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=GNOME";
    };
  };
}
