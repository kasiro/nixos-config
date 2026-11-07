# SwayFX — автозапуск (mako, waybar, swayidle, polkit)
{ pkgs, config, sway, ... }:
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
      {
        command = "${config.home.homeDirectory}/nixos-config/home/kasiro/desktop/sway/scripts/wallpaper-pause.sh";
        always = true;
      }
    ];
  };
}
