# Starship — промпт
#
# ВАЖНО: programs.starship.settings намеренно НЕ задаётся. HM при непустых
# settings генерирует ~/.config/starship.toml как симлинк в /nix/store,
# из-за чего шаблон noctalia «starship» не может писать в файл в рантайме.
# При settings = {} HM файл не генерирует вообще
# (hasGeneratedConfig = settings != {} || presets != []), поэтому базовый
# конфиг сеет активация starshipSeed ниже: она гарантирует, что после
# переключения ~/.config/starship.toml — обычный файл, но не перезатирает
# его содержимое (в том числе правки шаблона noctalia) после первого сидирования.
{ pkgs, lib, ... }:
let
  # Базовый starship.toml (seed) — точное содержимое прежней HM-генерации.
  # `\n` здесь литеральный escape TOML, как и было в генерируемом файле.
  starshipSeedToml = pkgs.writeText "starship-seed.toml" ''
    format = "$all$nix_shell$python\n$directory$git_branch$git_status\n$character"

    [character]
    error_symbol = "[❯](bold red)"
    success_symbol = "[❯](bold green)"

    [directory]
    style = "bold cyan"
    truncation_length = 3

    [git_branch]
    format = "[$symbol$branch]($style) "
    style = "bold purple"

    [git_status]
    format = "[$all_status$ahead_behind]($style) "
    style = "bold red"

    [nix_shell]
    format = "via [$symbol $name]($style) "
    heuristic = true
    impure_msg = "impure"
    pure_msg = "pure"
    style = "bold blue"
    symbol = "❄️"
    unknown_msg = ""
  '';
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Условие: после активации ~/.config/starship.toml — обычный файл с базовым
  # конфигом. Активация идемпотентна: существующий обычный файл не трогаем.
  # Симлинк от прежнего HM-поколения конвертируем в обычный файл (в рантайме
  # HM ещё держит симлинк: удаление старых файлов происходит позже, в
  # linkGeneration); если store-цель симлинка уже отсутствует (сборка
  # собрана/GC) — пишем seed. Отсутствующий файл — сеем seed.
  home.activation.starshipSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    seed="$HOME/.config/starship.toml"
    if [ -f "$seed" ] && [ ! -L "$seed" ]; then
      # Обычный файл (базовый конфиг и/или блок noctalia) — не трогаем
      :
    elif [ -L "$seed" ]; then
      # Симлинк от прежнего поколения → заменить обычным файлом с тем же
      # содержимым, чтобы noctalia могла писать в него в рантайме
      tmp="$(mktemp "$seed.XXXXXX")"
      if cp -- "$(readlink -f "$seed")" "$tmp" 2>/dev/null; then
        :
      else
        cat "${starshipSeedToml}" > "$tmp"
      fi
      mv -f -- "$tmp" "$seed"
    else
      install -m 644 -- "${starshipSeedToml}" "$seed"
    fi
  '';
}
