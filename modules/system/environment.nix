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
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
