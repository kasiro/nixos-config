# SwayFX — автозапуск (mako, waybar, swayidle, polkit)
{ pkgs, config, ... }:
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
        command = "${pkgs.nwg-dock}/bin/nwg-dock -d -i 48 -mb 10 -ws --num-ws 8";
      }
      # {
      #   command = "mpvpaper -p \"*\" \"Downloads/DwWrUmr8BXslX9w_Old Town Rain Live Wallpaper_4_105827.mp4\" --mpv-options \"loop=yes hwdec=auto ao=null input-ipc-server=/tmp/mpv-socket\"";
      #   always = true;
      # }
      # {
      #   command = "${config.home.homeDirectory}/.config/sway/scripts/wallpaper-pause.sh";
      # }
    ];
  };
}
