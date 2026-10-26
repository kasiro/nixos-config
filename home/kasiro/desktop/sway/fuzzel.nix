{ pkgs, lib, sway, ... }:
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
        font = "JetBrainsMono Nerd Font:size=13";
        # В кавычках — иначе fuzzel срезает пробелы в конце строки
        prompt = "\"Поиск: \"";
        icons-enabled = "yes";
        icon-theme = "Papirus-Dark";
        terminal = sway.terminal;
        lines = 12;
        width = 45;
        horizontal-pad = 20;
        vertical-pad = 20;
        inner-pad = 8;
        anchor = "center";
        layer = "overlay";
        dpi-aware = "no";
        # cache не задаём: по умолчанию $XDG_CACHE_HOME/fuzzel
      };

      colors = {
        background = rgba palette.base "ee";
        text = rgba palette.text "ff";
        match = rgba palette.mauve "ff";
        selection = rgba palette.mauve "ff";
        selection-text = rgba palette.base "ff";
        selection-match = rgba palette.mauve "ff";
        border = rgba palette.mauve "ff";
        prompt = rgba palette.mauve "ff";
        input = rgba palette.text "ff";
        counter = rgba palette.overlay0 "ff";
      };

      border = {
        width = 2;
        radius = 8;
      };
    };
  };
}
