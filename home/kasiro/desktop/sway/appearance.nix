# SwayFX — оформление: шрифты, обои, отступы, рамки, цвета, эффекты
{ sway, ... }:
{
  wayland.windowManager.sway = {
    config = {
      # --- Оформление ---
      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        size = 11.0;
      };

      bars = [ ]; # Используем Waybar

      # Обои — сплошной цвет (Catppuccin base)
      output = {
        "*" = {
          bg = "${sway.catppuccin.base} solid_color";
        };
      };

      # Отступы между окнами
      gaps = {
        inner = 10;
        outer = 6;
      };

      # Рамки окон
      window = {
        border = 2;
        titlebar = true;
      };
      floating.border = 2;

      # --- Цвета (Catppuccin Mocha) ---
      colors = {
        focused = {
          border = sway.catppuccin.mauve;
          background = sway.catppuccin.mantle;
          text = sway.catppuccin.text;
          indicator = sway.catppuccin.mauve;
          childBorder = sway.catppuccin.mauve;
        };
        focusedInactive = {
          border = sway.catppuccin.surface1;
          background = sway.catppuccin.mantle;
          text = sway.catppuccin.subtext0;
          indicator = sway.catppuccin.surface1;
          childBorder = sway.catppuccin.surface1;
        };
        unfocused = {
          border = sway.catppuccin.surface0;
          background = sway.catppuccin.mantle;
          text = sway.catppuccin.overlay0;
          indicator = sway.catppuccin.surface0;
          childBorder = sway.catppuccin.surface0;
        };
        urgent = {
          border = sway.catppuccin.red;
          background = sway.catppuccin.mantle;
          text = sway.catppuccin.text;
          indicator = sway.catppuccin.red;
          childBorder = sway.catppuccin.red;
        };
        placeholder = {
          border = sway.catppuccin.surface2;
          background = sway.catppuccin.mantle;
          text = sway.catppuccin.subtext0;
          indicator = sway.catppuccin.surface2;
          childBorder = sway.catppuccin.surface2;
        };
      };
    };

    # --- SwayFX специфичные настройки (через extraConfig) ---
    extraConfig = ''
      default_border pixel 3
      default_floating_border pixel 3
      corner_radius 10
      animation_duration_ms 10

      # Blur — плоский синтаксис (swayfx-enhanced 0.5.3)
      blur enable
      blur_xray enable
      blur_passes 2
      blur_radius 8
      blur_noise 0.02
      blur_contrast 0.9
      blur_brightness 0.95

      # Layer-shell поверхности: waybar
      layer_effects "waybar" {
        blur enable
        blur_ignore_transparent enable
        corner_radius 10
      }

      # Per-window blur для плавающих окон
      for_window [app_id="wofi"] floating enable, border pixel 0, blur enable, blur_ignore_transparent enable, shadows enable, corner_radius 10
      for_window [app_id="pavucontrol"] floating enable, blur enable, blur_ignore_transparent enable, shadows enable, corner_radius 10
      for_window [app_id="nm-connection-editor"] floating enable, blur enable, blur_ignore_transparent enable, shadows enable, corner_radius 10
    '';
  };
}
