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
      # {
      #   command = "mpvpaper -p '*' ${config.home.homeDirectory}/path/to/your/video.mp4 --mpv-options \"loop=yes hwdec=auto\"";
      #   always = true;
      # }
    ];
  };
}
