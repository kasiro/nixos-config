# Внешний вид интерфейса: курсор, hot corners
{ lib, ... }:
let
  theme = import ../../../themes/whitepeach/theme.nix;
in
{
  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = theme.cursorTheme;
    cursor-size = lib.gvariant.mkInt32 theme.cursorSize;
    enable-hot-corners = false;
    accent-color = theme.accent-color;
    color-scheme = theme.color-scheme;
  };
}
