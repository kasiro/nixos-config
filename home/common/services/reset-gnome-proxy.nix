{pkgs, config, ... }: {

  # reset-gnome-proxy after restart.
  systemd.user.services.reset-gnome-proxy = {
    Unit = {
      Description = "Сброс системного прокси GNOME в режим none";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      # gsettings находится в пакете glib
      ExecStart = "${pkgs.glib}/bin/gsettings set org.gnome.system.proxy mode 'none'";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
}
