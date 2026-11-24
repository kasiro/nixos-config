# Noctalia settings, mirrored from the GUI by the dmopp/settings-to-nix plugin
# (/home/kasiro/.local/state/noctalia/settings.toml). Every export overwrites this file.
#
# This file is your backup: keep it somewhere safe, for example in git.
#
# To restore, run this as your user in the directory of this file:
#   $(nix-build --no-out-link ./noctalia-gui-settings.nix)/bin/noctalia-restore-settings
# It replaces settings.toml (the old one is kept as settings.toml.bak-<time>).
# Then restart Noctalia; it installs the plugins listed here again on startup.
{ pkgs ? import <nixpkgs> { } }:
let
  settings = {
    bar.default = {
      capsule_group = [
        {
          accordion = false;
          accordion_direction = "end";
          enabled = true;
          fill = "surface";
          id = "g1";
          members = [ "clock" "date" ];
          opacity = 1.0;
          padding = 6.0;
          radius = 16.0;
          widget_spacing = 7;
        }
      ];
      capsule_radius = 10;
      center = [ "group:g1" "bar" "wallpaper" "wallhaven" "mpvpaper" "recorder" ];
      concave_edge_corners = false;
      end = [
        "keyboard_layout"
        "clipboard"
        "tray"
        "sysmon"
        "bluetooth"
        "battery"
        "settings"
        "session"
        "control-center"
      ];
      margin_edge = 5;
      margin_ends = 7;
      padding = 10;
      radius = 13;
      scale = 1.0500000081956387;
    };
    config_version = 14;
    control_center = {
      calendar.show_events_card = false;
      sidebar_section = "full";
      width = 800;
    };
    desktop_widgets = {
      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };
      schema_version = 2;
      widget = {
        desktop-widget-0000000000000004 = {
          box_height = 112.0;
          box_width = 496.0;
          cx = 520.0;
          cy = 1004.0;
          output = "DVI-I-1";
          placement_height = 1080.0;
          placement_width = 1920.0;
          rotation = 0.0;
          settings = {
            background_color = "surface_variant";
            background_opacity = 0.70000000000000007;
            bands = 44;
            centered = false;
            mirrored = false;
            reversed = false;
            show_when_idle = false;
          };
          type = "audio_visualizer";
        };
        desktop-widget-0000000000000005 = {
          box_height = 288.0;
          box_width = 528.0;
          cx = 1640.0;
          cy = 924.0;
          output = "DVI-I-1";
          placement_height = 1080.0;
          placement_width = 1920.0;
          rotation = 0.0;
          settings = {
            background_opacity = 0.81000000000000005;
            description = "Боитесь что то сделать?         сделайте по приколу.                 не получится - будет прикол.    получится - будет ебааать прикол.  если измерять всё в приколах - не будет так страшно) кому похуй - тот неуязвим.";
            opacity = 1.0;
            title = "приколы";
          };
          type = "label";
        };
      };
      widget_order = [ "desktop-widget-0000000000000004" "desktop-widget-0000000000000005" ];
    };
    dock = {
      auto_hide = false;
      background_opacity = 0.079999998211860657;
      border = "primary";
      border_width = 3.0;
      concave_edge_corners = false;
      enabled = true;
      layer = "overlay";
      margin_edge = 8;
      pinned = [ "chromium-browser" "dev.zed.Zed" "kitty" "obsidian" ];
      shadow = false;
      show_dots = true;
      smart_auto_hide = true;
    };
    lockscreen = {
      blurred_desktop = true;
      fingerprint = false;
    };
    lockscreen_widgets = {
      enabled = false;
      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };
      schema_version = 2;
      widget."lockscreen-login-box@DVI-I-1" = {
        box_height = 196.0;
        box_width = 810.0;
        cx = 960.0;
        cy = 898.0;
        output = "DVI-I-1";
        placement_height = 1080.0;
        placement_width = 1920.0;
        rotation = 0.0;
        settings = {
          background_color = "surface_variant";
          background_opacity = 0.88;
          background_radius = 12.0;
          center_password_text = false;
          input_opacity = 1.0;
          input_radius = 6.0;
          layout = "regular";
          show_caps_lock = true;
          show_keyboard_layout = true;
          show_login_button = true;
          show_media = true;
          show_session_buttons = true;
          show_unlock_hint = true;
          show_weather = true;
        };
        type = "login_box";
      };
      widget_order = [ "lockscreen-login-box@DVI-I-1" ];
    };
    notification.position = "top_center";
    osd.position = "top_center";
    plugin_settings = {
      "dmopp/settings-to-nix".target_path = "/home/kasiro/nixos-config/home/kasiro/desktop/hyprland/noctalia-gui-settings.nix";
      "noctalia/mpvpaper".video_directory = "/home/kasiro/Downloads";
      "noctalia/notes".panel_position = "center";
    };
    plugins = {
      auto_update = "all";
      enabled = [
        "noctalia/timer"
        "noctalia/wallhaven"
        "noctalia/mpvpaper"
        "dmopp/settings-to-nix"
        "noctalia/screen_recorder"
      ];
      source = [
        {
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
          name = "official";
        }
        {
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
          name = "community";
        }
        {
          kind = "git";
          location = "https://github.com/OHMCFXG/noctalia-plugins.git";
          name = "personal";
        }
        {
          kind = "path";
          location = "/nix/store/h990y4cs8fksjs0q4vc6ljzwzhzbsaid-noctalia-settings-to-nix-plugin";
          name = "nix-settings-to-nix";
        }
      ];
    };
    shell = {
      avatar_path = "/home/kasiro/Загрузки/5289763524160726659.jpg";
      font_family = "FiraCode Nerd Font";
      launcher = {
        app_grid = true;
        pinned = [
          "zed"
          "obsidian"
          "chromium-browser"
          "com.mitchellh.ghostty"
          "chrome-jaadefahflmkfinoajcpnhcejikckjdh-Default"
          "org.gnome.Nautilus"
          "chrome-hmjcdonmhijmnefklekckjkeoknbiipb-Default"
          "org.telegram.desktop"
          "kitty"
          "chrome-callopjomjkljkgpgnflciibleibpnbp-Default"
          "Happ"
          "chrome-bknofkbphlmjdamhfgnibeebjmfjklfh-Default"
        ];
      };
      panel = {
        control_center_placement = "attached";
        control_center_position = "center";
        launcher_placement = "floating";
        shadow = false;
      };
      password_style = "random";
      screen_time_enabled = true;
      screenshot.show_cursor = true;
      settings_window_translucent = true;
    };
    theme = {
      builtin = "Noctalia";
      community_palette = "Ayu Red";
      custom_palette = "ab5idxtz-ts";
      mode = "dark";
      source = "custom";
      templates.builtin_ids = [
        "alacritty"
        "btop"
        "cava"
        "gtk3"
        "gtk4"
        "ghostty"
        "hyprland"
        "kcolorscheme"
        "qt"
      ];
      wallpaper_scheme = "m3-content";
    };
    wallpaper.directory = "/home/kasiro/Загрузки/wallpapers";
    weather.enabled = false;
    widget = {
      audio_visualizer = {
        bands = 17;
        centered = false;
        mirrored = false;
      };
      bar.type = "noctalia/timer:bar";
      battery.enabled = false;
      bluetooth.enabled = false;
      control-center.enabled = false;
      mpvpaper.type = "noctalia/mpvpaper:mpvpaper";
      recorder.type = "noctalia/screen_recorder:recorder";
      wallhaven.type = "noctalia/wallhaven:wallhaven";
    };
  };
  settingsToml = (pkgs.formats.toml { }).generate "noctalia-settings.toml" settings;
in
(pkgs.writeShellScriptBin "noctalia-restore-settings" ''
  set -eu
  PATH=${pkgs.coreutils}/bin:$PATH
  if [ -n "''${NOCTALIA_STATE_HOME:-}" ]; then
    dir="$NOCTALIA_STATE_HOME/noctalia"
  elif [ -n "''${XDG_STATE_HOME:-}" ]; then
    dir="$XDG_STATE_HOME/noctalia"
  else
    dir="$HOME/.local/state/noctalia"
  fi
  mkdir -p "$dir"
  if [ -e "$dir/settings.toml" ]; then
    backup="$dir/settings.toml.bak-$(date +%Y%m%d-%H%M%S)"
    cp "$dir/settings.toml" "$backup"
    echo "Previous settings saved to $backup"
  fi
  tmp=$(mktemp "$dir/.settings.toml.XXXXXX")
  cat ${settingsToml} > "$tmp"
  chmod 644 "$tmp"
  mv "$tmp" "$dir/settings.toml"
  # Skip the first-run wizard; it would write its own choices over the restored ones.
  touch "$dir/.setup-complete"
  echo "Noctalia settings restored to $dir/settings.toml."
  echo "Restart Noctalia so it installs the plugins from the restored settings."
'') // { inherit settings; }
