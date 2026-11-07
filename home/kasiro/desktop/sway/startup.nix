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
        command = "mpvpaper -p '*' ${config.home.homeDirectory}/Downloads/QhJKFx9emn-power-dancing-live-wallpaper.mp4 --mpv-options \"loop=yes hwdec=auto ao=null input-ipc-server=/tmp/mpv-socket\"";
        always = true;
      }
    ];
  };
}
