# Переменные окружения
{ ... }:
let
  theme = import ../../themes/kasiro/theme.nix;
in
{
  # npm global packages ставятся в home (nix store read-only)
  environment.variables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    STARSHIP_LOG = "error";
    BUN_INSTALL = "$HOME/.bun";
    # Добавляем bin-директорию Bun в PATH, чтобы глобальные пакеты были доступны
    PATH = "$HOME/.bun/bin:$PATH";
    # Тема курсора для всех приложений (включая Steam)
    XCURSOR_THEME = theme.cursorTheme;
    XDG_ICON_THEME = theme.cursorTheme;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Размер курсора (совпадает с cursor-size в dconf)
    XCURSOR_SIZE = toString theme.cursorSize;
  };
}
