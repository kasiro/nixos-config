{ builtins, ... }:
{
  # --- Waybar — красивая панель в стиле Catppuccin ---
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 4;
        margin-top = 6;
        margin-left = 6;
        margin-right = 6;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "sway/language"
          "pulseaudio"
          "network"
          "cpu"
          "memory#ram"
          "memory#swap"
        ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
            default = "";
          };
        };

        "sway/window" = {
          max-length = 50;
          tooltip = false;
        };

        "sway/language" = {
          format = "{short}";
          tooltip = false;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " Mute";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pamixer -t";
          tooltip = false;
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = " {ifname}";
          format-linked = "⚠ No IP";
          format-disconnected = "";
          tooltip = false;
        };

        cpu = {
          format = " {usage}%";
          interval = 1;
          tooltip = false;
        };

        "memory#ram" = {
          format = " {used:0.1f}G/{total:0.1f}G ({percentage}%)";
          interval = 10;
          tooltip = false;
        };

        "memory#swap" = {
          format = " {swapUsed:0.1f}G/{swapTotal:0.1f}G ({swapPercentage}%)";
          interval = 10;
          tooltip = false;
        };

        clock = {
          format = "{:%H:%M    %d.%m.%Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><big>{calendar}</big></tt>";
        };

        tray = {
          spacing = 10;
          icon-size = 16;
        };
      }
    ];

    style = builtins.readFile ./waybar.css;
  };
}
