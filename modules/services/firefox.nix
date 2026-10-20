# Firefox
{ ... }:
{
  programs.firefox.enable = true;

  # Фикс темы: Firefox не следует libadwaita-цветам GTK (сломанный контраст)
  programs.firefox.preferences = {
    "widget.gtk.libadwaita-colors.enabled" = false;
  };
}
