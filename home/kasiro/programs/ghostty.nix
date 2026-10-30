{ pkgs, lib, sway, ... }:
{
  # Ghostty — терминал с нативной поддержкой blur
  # https://ghostty.org/docs/config/reference

  home.packages = with pkgs; [ ghostty ];

  # Конфиг Ghostty
  xdg.configFile."ghostty/config" = {
    text = lib.mkAfter ''
      # Прозрачность и blur (как KGX с blur-my-shell)
      background-opacity = 0.65
      background-blur = true

      # КРИТИЧНО: применять прозрачность ко ВСЕМ ячейкам (TUI, bubbletea)
      background-opacity-cells = true

      # Scrollback — 500,000 строк (50 MB)
      scrollback-limit = 52428800

      # Прокрутка колёсиком (3 строки за скролл)
      mouse-scroll-multiplier = 3

      # Отступы
      window-padding-x = 10
      window-padding-y = 10

      # Шрифт
      font-family = "JetBrains Mono Nerd Font"
      font-size = 12

      # Тема
      theme = "Catppuccin Mocha"

      # Цвет фона (из sway.catppuccin.base — Catppuccin Mocha base)
      background = "${sway.catppuccin.base}"

      # Cursor
      cursor-style = "block"
      cursor-style-blink = false

      # Copy/paste
      clipboard-trim-trailing-spaces = false
      confirm-close-surface = false

      # Window
      window-decoration = false
    '';
    force = true;
  };
}
