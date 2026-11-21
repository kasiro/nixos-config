# GTK3-приложения и порталы берут тему из gsettings, а home-manager
# пишет только settings.ini — ключа gtk-theme в dconf нет, отсюда
# светлый Adwaita. Значение берём из gtk.theme.name, чтобы не разъезжалось.
# color-scheme не дублируем: уже задан в desktop/gnome/interface.nix.
{ config, ... }:
{
  dconf.settings."org/gnome/desktop/interface".gtk-theme = config.gtk.theme.name;
}
