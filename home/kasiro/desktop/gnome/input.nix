# Раскладки клавиатуры + переключение Shift+Alt
{ lib, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.gvariant.mkTuple [ "xkb" "us" ])
        (lib.gvariant.mkTuple [ "xkb" "ru" ])
      ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Shift>Alt_L" ];
      switch-input-source-backward = [ "<Shift>Alt_R" ];
    };
  };
}
