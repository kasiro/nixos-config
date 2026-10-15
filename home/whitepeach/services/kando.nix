# Kando Pie Menu — автозапуск
{ config, pkgs, ... }:
{
  systemd.user.services.kando = {
    Unit = { Description = "Kando Pie Menu"; };
    Service = {
      ExecStart = "${pkgs.appimage-run}/bin/appimage-run ${config.home.homeDirectory}/Загрузки/Kando-3.0.0-x86_64.AppImage";
      Restart = "on-failure";
      # Задержка 5 секунд после входа в сессию
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}
