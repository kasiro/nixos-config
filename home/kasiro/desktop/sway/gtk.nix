{ pkgs, sway, ... }:
{
  # --- Курсор и GTK-тема ---
  home.pointerCursor = {
    enable = true;
    name = sway.theme.cursorTheme;
    package = pkgs.bibata-cursors;
    size = sway.theme.cursorSize;
    # Создаёт symlink ~/.icons/default -> ~/.nix-profile/share/icons/Bibata-Modern-Ice
    dotIcons.enable = true;
    # Генерирует конфиг Sway: seat "*" { xcursor_theme = "Bibata-Modern-Ice 24" }
    sway.enable = true;
    # Для GTK-приложений
    gtk.enable = true;
  };

  home.sessionVariables = {
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
    # home.pointerCursor.gtk.enable уже задаёт cursorTheme, но оставляем для явности
    cursorTheme = {
      name = sway.theme.cursorTheme;
      package = pkgs.bibata-cursors;
      size = sway.theme.cursorSize;
    };
  };
}
