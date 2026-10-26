{ lib, sway, ... }:
let
  inherit (lib) removePrefix;

  # Catppuccin Mocha: hex без '#' + альфа-канал (fuzzel ждёт rrggbbaa)
  rgb = color: removePrefix "#" color;
  rgba = color: alpha: "${rgb color}${alpha}";

  palette = sway.catppuccin;
in
{
  # --- Fuzzel — лаунчер приложений (заменил wofi; wofi остаётся fallback'ом) ---
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # Как foot: 12pt, а не 13 — на 1080p крупнее выглядит грубо
        font = "JetBrainsMono Nerd Font:size=12";
        # В кавычках — иначе fuzzel срезает пробелы в конце строки
        prompt = "\"› \"";
        placeholder = "\"Поиск…\"";
        icons-enabled = "yes";
        icon-theme = "Papirus-Dark";
        terminal = sway.terminal;
        lines = 10;
        width = 42;
        horizontal-pad = 14;
        vertical-pad = 14;
        inner-pad = 5;
        line-height = 22;
        # Строкой, иначе Nix отрендерит 0.300000
        letter-spacing = "0.3";
        # Счётчик совпадений справа от ввода
        match-counter = "yes";
        anchor = "center";
        layer = "overlay";
        dpi-aware = "no";
        # cache не задаём: по умолчанию $XDG_CACHE_HOME/fuzzel
      };

      colors = {
        # Полупрозрачный base с blur (80% opacity)
        background = rgba palette.base "cc";
        text = rgba palette.text "ff";
        match = rgba palette.mauve "ff";
        # Мягкая mauve-подсветка строки, а не сплошная заливка
        selection = rgba palette.mauve "44";
        selection-text = rgba palette.text "ff";
        selection-match = rgba palette.rosewater "ff";
        border = rgba palette.surface1 "ff";
        prompt = rgba palette.mauve "ff";
        input = rgba palette.text "ff";
        counter = rgba palette.subtext0 "ff";
        placeholder = rgba palette.overlay0 "ff";
      };

      border = {
        width = 1;
        radius = 6;
        # Скругление выделенной строки внутри окна
        selection-radius = 4;
      };
    };
  };
}
