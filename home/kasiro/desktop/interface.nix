# Внешний вид интерфейса: курсор, hot corners
{ lib, ... }:
{
  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = "Bibata-Modern-Ice";
    cursor-size = lib.gvariant.mkInt32 24;
    enable-hot-corners = false;
  };
}
