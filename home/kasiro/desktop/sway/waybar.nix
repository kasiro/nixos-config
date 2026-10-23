{ pkgs, lib, sway, ... }:
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
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "swap"
          "clock"
          "tray"
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

        memory = {
          format = " {used:0.1f}G/{total:0.1f}G";
          interval = 10;
          tooltip = false;
        };

        swap = {
          format = "zram {used:0.1f}G/{total:0.1f}G";
          interval = 10;
          tooltip = false;
        };

        clock = {
          format = "{:%H:%M    %d.%m.%Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        tray = {
          spacing = 10;
          icon-size = 16;
        };
      }
    ];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        font-weight: 500;
        min-height: 0;
      }
      window#waybar {
        background: rgba(24, 24, 37, 0.85);
        color: #cdd6f4;
        border-radius: 12px;
        border: 1px solid #313244;
      }
      #workspaces {
        background: #313244;
        border-radius: 8px;
        margin: 4px 8px 4px 4px;
        padding: 2px 4px;
      }
      #workspaces button {
        padding: 4px 10px;
        color: #a6adc8;
        border-radius: 6px;
        margin: 2px;
        transition: all 0.2s ease;
      }
      #workspaces button:hover {
        background: #45475a;
        color: #cdd6f4;
      }
      #workspaces button.focused {
        background: #cba6f7;
        color: #1e1e2e;
        font-weight: bold;
      }
      #workspaces button.urgent {
        background: #f38ba8;
        color: #1e1e2e;
      }
      #mode {
        background: #f38ba8;
        color: #1e1e2e;
        border-radius: 6px;
        padding: 4px 10px;
        margin: 4px 0;
        font-weight: bold;
      }
      #window {
        color: #cdd6f4;
        padding: 4px 12px;
      }
      #pulseaudio, #network, #cpu, #memory, #swap, #clock {
        background: #313244;
        border-radius: 8px;
        padding: 4px 12px;
        margin: 4px 3px;
        color: #cdd6f4;
      }
      #pulseaudio { color: #89b4fa; }
      #network { color: #a6e3a1; }
      #cpu { color: #f9e2af; }
      #memory { color: #fab387; }
      #swap { color: #94e2d5; }
      #clock { color: #cba6f7; font-weight: bold; }
      #tray {
        background: #313244;
        border-radius: 8px;
        padding: 4px 8px;
        margin: 4px 4px 4px 8px;
      }
    '';
  };
}
