{ pkgs, lib, sway, ... }:
{
  # --- Курсор и GTK-тема ---
  home.sessionVariables = {
    XCURSOR_THEME = sway.theme.cursorTheme;
    XCURSOR_SIZE = toString sway.theme.cursorSize;
    GTK_THEME = "catppuccin-mocha-mauve-compact";
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-compact";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = sway.theme.cursorTheme;
      package = pkgs.bibata-cursors;
      size = sway.theme.cursorSize;
    };
  };
}
