# SwayFX — ядро: включение, пакет, модификатор, терминал, меню, ввод
{ pkgs, lib, sway, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    config = {
      modifier = sway.mod;
      terminal = sway.terminal;
      menu = sway.menu;

      # --- Раскладка ---
      input = {
        "type:keyboard" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:alt_shift_toggle";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
    };
  };
}
