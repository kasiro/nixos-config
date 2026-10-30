# Общие значения конфигурации SwayFX: палитра, mod, terminal, menu, theme
{ pkgs, ... }:
{
  _module.args.sway = {
    # Catppuccin Mocha палитра
    catppuccin = {
      base = "#1e1e2e";
      mantle = "#181825";
      crust = "#11111b";
      text = "#cdd6f4";
      subtext0 = "#a6adc8";
      overlay0 = "#6c7086";
      surface0 = "#313244";
      surface1 = "#45475a";
      surface2 = "#585b70";
      blue = "#89b4fa";
      lavender = "#b4befe";
      sapphire = "#74c7ec";
      sky = "#89dceb";
      teal = "#94e2d5";
      green = "#a6e3a1";
      yellow = "#f9e2af";
      peach = "#fab387";
      maroon = "#eba0ac";
      red = "#f38ba8";
      mauve = "#cba6f7";
      pink = "#f5c2e7";
      flamingo = "#f2cdcd";
      rosewater = "#f5e0dc";
    };

    mod = "Mod4";
    terminal = "${pkgs.kitty}/bin/kitty";
    # Основной лаунчер — fuzzel
    menu = "${pkgs.fuzzel}/bin/fuzzel";
    # Fallback лаунчер (Mod4+Shift+a)
    wofiMenu = "${pkgs.wofi}/bin/wofi --show drun --allow-images";
    theme = import ../../../../themes/kasiro/theme.nix;
  };
}
