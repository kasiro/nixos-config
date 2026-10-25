# SwayFX — горячие клавиши и режим resize
{ pkgs, lib, sway, ... }:
{
  wayland.windowManager.sway.config = {
    # --- Горячие клавиши ---
    keybindings = lib.mkOptionDefault {
      "${sway.mod}+Return" = "exec ${sway.terminal}";
      "Control+q" = "kill";
      "${sway.mod}+a" = "exec ${sway.menu}";
      # "${sway.mod}+Shift+c" = "reload";
      "${sway.mod}+Shift+e" = "exec ${pkgs.sway}/bin/swaynag -t warning -m 'Выйти из Sway?' -b 'Да' 'swaymsg exit'";

      # Движение фокуса (vim-style)
      "${sway.mod}+Left" = "focus left";
      "${sway.mod}+Down" = "focus down";
      "${sway.mod}+Up" = "focus up";
      "${sway.mod}+Right" = "focus right";

      # Перемещение окон (COSMIC-style: умное — если край, то workspace)
      "${sway.mod}+Shift+Left" = "exec cd /home/kasiro/nixos-config/home/kasiro/desktop/sway/scripts && uv run python smart-move.py left";
      "${sway.mod}+Shift+Down" = "move down";
      "${sway.mod}+Shift+Up" = "move up";
      "${sway.mod}+Shift+Right" = "exec cd /home/kasiro/nixos-config/home/kasiro/desktop/sway/scripts && uv run python smart-move.py right";

      # Рабочие столы
      "Control+1" = "workspace number 1";
      "Control+2" = "workspace number 2";
      "Control+3" = "workspace number 3";
      "Control+4" = "workspace number 4";
      "Control+5" = "workspace number 5";
      "Control+6" = "workspace number 6";
      "Control+7" = "workspace number 7";
      "Control+8" = "workspace number 8";
      "Control+9" = "workspace number 9";
      "Control+0" = "workspace number 10";
      
      # "${sway.mod}+Shift+1" = "move container to workspace number 1";
      # "${sway.mod}+Shift+2" = "move container to workspace number 2";
      # "${sway.mod}+Shift+3" = "move container to workspace number 3";
      # "${sway.mod}+Shift+4" = "move container to workspace number 4";
      # "${sway.mod}+Shift+5" = "move container to workspace number 5";
      # "${sway.mod}+Shift+6" = "move container to workspace number 6";
      # "${sway.mod}+Shift+7" = "move container to workspace number 7";
      # "${sway.mod}+Shift+8" = "move container to workspace number 8";
      # "${sway.mod}+Shift+9" = "move container to workspace number 9";
      # "${sway.mod}+Shift+0" = "move container to workspace number 10";

      # # Перемещение окон на Ctrl+Shift+Num
      # "Control+Shift+1" = "move container to workspace number 1";
      # "Control+Shift+2" = "move container to workspace number 2";
      # "Control+Shift+3" = "move container to workspace number 3";
      # "Control+Shift+4" = "move container to workspace number 4";
      # "Control+Shift+5" = "move container to workspace number 5";
      # "Control+Shift+6" = "move container to workspace number 6";
      # "Control+Shift+7" = "move container to workspace number 7";
      # "Control+Shift+8" = "move container to workspace number 8";
      # "Control+Shift+9" = "move container to workspace number 9";
      # "Control+Shift+0" = "move container to workspace number 10";

      # Layout
      # "${sway.mod}+b" = "splith";
      # "${sway.mod}+v" = "splitv";
      "${sway.mod}+f" = "fullscreen toggle";
      "${sway.mod}+g" = "floating toggle";
      "${sway.mod}+space" = "focus mode_toggle";
      "${sway.mod}+d" = "focus parent";

      # Resize mode
      "${sway.mod}+r" = "mode resize";

      # Скриншоты
      "Print" = "exec ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy";
      "${sway.mod}+Print" =
        "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";

      # Медиа/звук
      "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
      "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
      "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
      "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
    };

    # --- Режим resize ---
    modes.resize = {
      "h" = "resize shrink width 10 px";
      "j" = "resize grow height 10 px";
      "k" = "resize shrink height 10 px";
      "l" = "resize grow width 10 px";
      "Escape" = "mode default";
      "Return" = "mode default";
    };
  };
}
