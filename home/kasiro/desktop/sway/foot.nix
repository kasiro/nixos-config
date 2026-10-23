{ pkgs, lib, sway, ... }:
{
  # --- Foot — терминал Wayland (крупный шрифт + внутренние отступы) ---
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        pad = "12x12";
      };
    };
  };
}
