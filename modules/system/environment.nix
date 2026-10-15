# Переменные окружения
{ ... }:
{
  # npm global packages ставятся в home (nix store read-only)
  environment.variables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    STARSHIP_LOG = "error";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
