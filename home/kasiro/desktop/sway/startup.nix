# SwayFX — автозапуск (mako, waybar, swayidle, polkit)
{ pkgs, sway, ... }:
{
  # Развёртывание скриптов
  home.file.".config/sway/scripts/smart-move.py" = {
    source = ./scripts/smart-move.py;
    executable = true;
  };

  wayland.windowManager.sway.config = {
    # --- Автозапуск ---
    startup = [
      {
        command = "${pkgs.mako}/bin/mako";
      }
      {
        command = "${pkgs.waybar}/bin/waybar";
      }
      {
        command = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c ${sway.catppuccin.crust}'";
      }
      {
        command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      }
    ];
  };
}
