# SwayFX — обои: случайная ротация из папки по таймеру (через swaymsg)
{ config, lib, ... }:
let
  wallpaperDir = "${config.home.homeDirectory}/Загрузки/wallpapers";
  interval = "5min";

  # Обои, которые показываем только днём (ночью исключаются)
  dayOnly = [
    "2025-01-07_677cdab643f08_image-1.png"
    "i.webp"
  ];

  # Обои, которые не показываем никогда
  exclude = [
    "B1WsW.jpg"
    "miCia.jpg"
    "agZCBoVc.webp"
  ];

  script = "${config.home.homeDirectory}/.config/sway/scripts/wallpaper-rotate.py";

  # Sway-сессия уже объявляет свой target; таймер живёт внутри неё
  sessionTarget = "sway-session.target";
in
{
  home.file.".config/sway/scripts/wallpaper-rotate.py" = {
    source = ./scripts/wallpaper-rotate.py;
    executable = true;
  };

  systemd.user.services.sway-wallpaper = {
    Unit.Description = "Смена обоев Sway";
    Service = {
      Type = "oneshot";
      # SWAYMSG не задаём: скрипт сам находит системный swaymsg (swayfx-enhanced)
      Environment = [
        "SWAY_WALLPAPER_DIR=${wallpaperDir}"
        "SWAY_WALLPAPER_DAY_ONLY=${lib.concatStringsSep ":" dayOnly}"
        "SWAY_WALLPAPER_EXCLUDE=${lib.concatStringsSep ":" exclude}"
        "SWAY_WALLPAPER_OUTPUT=*"
        "SWAY_WALLPAPER_MODE=fill"
      ];
      ExecStart = script;
    };
    Install.WantedBy = [ sessionTarget ];
  };

  systemd.user.timers.sway-wallpaper = {
    Unit.Description = "Ротация обоев Sway";
    Timer = {
      Unit = "sway-wallpaper.service";
      OnActiveSec = "1min";
      OnUnitActiveSec = interval;
    };
    Install.WantedBy = [ sessionTarget ];
  };
}
