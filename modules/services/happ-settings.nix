# Включение Happ (сам модуль — в ./happ/)
{ ... }:
{
  services.happ = {
    enable = true;
    # XWayland + софтверный рендер — обход краша Qt6 Wayland на wlroots
    forceXwayland = true;
    forceSoftwareRendering = true;
  };
}
