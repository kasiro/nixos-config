# SwayFX — горячие клавиши и режим resize
{ pkgs, lib, sway, ... }:
{
  wayland.windowManager.sway.config = {
    # --- Горячие клавиши ---
    keybindings = lib.mkOptionDefault {
      "${sway.mod}+Return" = "exec ${sway.terminal}";
      "${sway.mod}+q" = "kill";
      "${sway.mod}+a" = "exec ${sway.menu}";
      "${sway.mod}+Shift+q" = "kill";
      "${sway.mod}+Shift+c" = "reload";
      "${sway.mod}+Shift+e" = "exec ${pkgs.sway}/bin/swaynag -t warning -m 'Выйти из Sway?' -b 'Да' 'swaymsg exit'";

      # Движение фокуса (vim-style)
      "${sway.mod}+h" = "focus left";
      "${sway.mod}+j" = "focus down";
      "${sway.mod}+k" = "focus up";
      "${sway.mod}+l" = "focus right";
      "${sway.mod}+Left" = "focus left";
      "${sway.mod}+Down" = "focus down";
      "${sway.mod}+Up" = "focus up";
      "${sway.mod}+Right" = "focus right";

      # Перемещение окон
      "${sway.mod}+Shift+h" = "move left";
      "${sway.mod}+Shift+j" = "move down";
      "${sway.mod}+Shift+k" = "move up";
      "${sway.mod}+Shift+l" = "move right";

      # Рабочие столы
      "${sway.mod}+1" = "workspace number 1";
      "${sway.mod}+2" = "workspace number 2";
      "${sway.mod}+3" = "workspace number 3";
      "${sway.mod}+4" = "workspace number 4";
      "${sway.mod}+5" = "workspace number 5";
      "${sway.mod}+6" = "workspace number 6";
      "${sway.mod}+7" = "workspace number 7";
      "${sway.mod}+8" = "workspace number 8";
      "${sway.mod}+9" = "workspace number 9";
      "${sway.mod}+0" = "workspace number 10";

      "${sway.mod}+Shift+1" = "move container to workspace number 1";
      "${sway.mod}+Shift+2" = "move container to workspace number 2";
      "${sway.mod}+Shift+3" = "move container to workspace number 3";
      "${sway.mod}+Shift+4" = "move container to workspace number 4";
      "${sway.mod}+Shift+5" = "move container to workspace number 5";

      # Layout
      "${sway.mod}+b" = "splith";
      "${sway.mod}+v" = "splitv";
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
