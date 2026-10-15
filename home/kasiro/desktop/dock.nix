# Dash to Dock
{ ... }:
{
  dconf.settings."org/gnome/shell/extensions/dash-to-dock" = {
    dock-position = "BOTTOM";
    intellihide = true;
    show-trash = true;
    show-show-apps-button = false;
  };
}
