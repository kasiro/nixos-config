# SwayFX — автозапуск (mako, waybar, swayidle, polkit)
{ pkgs, sway, ... }:
{
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
        command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      }
    ];
  };
}
