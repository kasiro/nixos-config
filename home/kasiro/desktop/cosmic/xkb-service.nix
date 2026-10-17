{ pkgs, ... }:
{
  systemd.user.services.setxkbmap-cosmic = {
    Unit = {
      Description = "Set Shift+Alt for layout switching in COSMIC";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.xorg.setxkbmap}/bin/setxkbmap -option grp:shift_alt_toggle";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
