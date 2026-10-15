# direnv + nix-direnv
{ ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    config = {
      global = {
        # Убирает вывод diff'а переменных окружения
        hide_env_diff = true;

        # Формат вывода — как есть, без префикса (префикс добавим сами через log_filter)
        log_format = "%s";

        # Фильтр: только самое важное
        log_filter = "^(loading|using flake|nix-direnv: Using cached dev shell)";
      };
    };
  };
}
