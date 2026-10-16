# Переменные окружения
{ ... }:
{
  # npm global packages ставятся в home (nix store read-only)
  environment.variables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    STARSHIP_LOG = "error";
    BUN_INSTALL = "$HOME/.bun";
    # Добавляем bin-директорию Bun в PATH, чтобы глобальные пакеты были доступны
    PATH = "$HOME/.bun/bin:$PATH";
    # Тема курсора для всех приложений (включая Steam)
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XDG_ICON_THEME = "Bibata-Modern-Ice";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Размер курсора (совпадает с cursor-size в dconf)
    XCURSOR_SIZE = "24";
  };
}
