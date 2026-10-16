# Переменные окружения курсора — специфичные для пользователя kasiro
{ ... }:
let
  theme = import ../../../themes/kasiro/theme.nix;
in
{
  home.sessionVariables = {
    XCURSOR_THEME = theme.cursorTheme;
    XDG_ICON_THEME = theme.cursorTheme;
    XCURSOR_SIZE = toString theme.cursorSize;
    STEAM_CURSOR_THEME = theme.cursorTheme;
  };
}
