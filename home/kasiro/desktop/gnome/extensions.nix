# GNOME Shell — включённые расширения
{ ... }:
{
  dconf.settings."org/gnome/shell" = {
    disable-user-extensions = true;
    enabled-extensions = [
      "appindicatorsupport@rgcjonas.gmail.com"
      "dash-to-dock@micxgx.gmail.com"
      "blur-my-shell@aunetx"
      "caffeine@patapon.info"
      "tophat@fflewddur.github.io"
      "app-hider@lynith.dev"
      "clipboard-history@alexsaveau.dev"
      "lockscreen-extension@pratap.fastmail.fm"
      # "window-calls@domandoman.xyz"
      "kando-integration@kando-menu.github.io"
    ];
  };
}
