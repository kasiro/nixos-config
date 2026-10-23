{ pkgs, lib, sway, ... }:
{
  # --- Mako — уведомления в стиле Catppuccin ---
  services.mako = {
    enable = true;
    settings = {
      font = sway.theme.font;
      background-color = "#181825";
      text-color = "#cdd6f4";
      border-color = "#cba6f7";
      border-radius = 10;
      default-timeout = 5000;
      layer = "overlay";
      padding = "12";
      margin = "10";
      width = 320;
      height = 120;
      anchor = "top-right";
    };
  };
}
