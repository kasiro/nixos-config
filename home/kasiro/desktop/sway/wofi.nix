{ pkgs, lib, sway, ... }:
{
  # --- Wofi — лаунчер в стиле Catppuccin ---
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      allow-images = true;
      hide-scroll = true;
      no-actions = true;
      width = 500;
      height = 400;
      location = "center";
      prompt = "🔍 Поиск...";
      filter_rate = 100;
      insensitive = true;
      gtk_dark = true;
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }
      window {
        background: #181825;
        color: #cdd6f4;
        border: 2px solid #cba6f7;
        border-radius: 12px;
      }
      #input {
        background: #313244;
        color: #cdd6f4;
        border: none;
        border-radius: 8px;
        padding: 10px;
        margin: 10px;
      }
      #input:focus {
        border: 2px solid #cba6f7;
      }
      #scroll {
        margin: 0 10px 10px 10px;
      }
      #entry {
        padding: 10px;
        border-radius: 6px;
        margin: 2px 0;
      }
      #entry:selected {
        background: #cba6f7;
        color: #1e1e2e;
        font-weight: bold;
      }
      #entry image {
        padding-right: 10px;
      }
    '';
  };
}
