# Мышь: замедление + flat-профиль (паритет с input.sensitivity в hyprland.lua)
{ lib, ... }:
{
  dconf.settings."org/gnome/desktop/peripherals/mouse" = {
    speed = lib.gvariant.mkDouble (-0.5);
    accel-profile = "flat";
  };
}
