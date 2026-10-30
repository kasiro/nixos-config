{ pkgs, lib, sway, ... }:
{
  home.packages = with pkgs; [ kitty ];
  
  # Конфиг Kitty — аналог Ghostty
  # https://sw.kovidgoyal.net/kitty/conf/
  xdg.configFile."kitty/kitty.conf".text = lib.mkAfter ''
    # ========== Тема Catppuccin Mocha ==========
    # Цвета из sway.catppuccin
    foreground ${sway.catppuccin.text}
    background ${sway.catppuccin.base}
    cursor ${sway.catppuccin.rosewater}
    
    # Цветовая палитра
    color0 ${sway.catppuccin.overlay0}
    color1 ${sway.catppuccin.red}
    color2 ${sway.catppuccin.green}
    color3 ${sway.catppuccin.yellow}
    color4 ${sway.catppuccin.blue}
    color5 ${sway.catppuccin.pink}
    color6 ${sway.catppuccin.teal}
    color7 ${sway.catppuccin.subtext1}
    color8 ${sway.catppuccin.overlay1}
    color9 ${sway.catppuccin.red}
    color10 ${sway.catppuccin.green}
    color11 ${sway.catppuccin.yellow}
    color12 ${sway.catppuccin.blue}
    color13 ${sway.catppuccin.pink}
    color14 ${sway.catppuccin.teal}
    color15 ${sway.catppuccin.white}
    
    # ========== Прозрачность и blur ==========
    # Kitty не поддерживает нативный blur — только через композитор (swayfx)
    # background_blur работает только на macOS
    background_opacity 0.65
    
    # ========== Шрифт ==========
    font_family      JetBrains Mono Nerd Font
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    font_size        12.0
    
    # ========== Отступы (по умолчанию 10px) ==========
    window_padding_width 10
    
    # ========== Cursor ==========
    cursor_shape block
    cursor_blink_interval -1
    
    # ========== Window ==========
    window_border_width 0.5pt
    active_border_color ${sway.catppuccin.lavender}
    inactive_border_color ${sway.catppuccin.surface1}
    hide_window_decorations yes
    
    # ========== Tab bar ==========
    tab_bar_edge bottom
    tab_bar_style powerline
    active_tab_font_style bold
    inactive_tab_font_style regular
    
    # ========== Scrollback ==========
    scrollback_lines 10000
    
    # ========== Bell ==========
    enable_audio_bell no
    
    # ========== Clipboard ==========
    confirm_os_window_close 0
    
    # ========== Keyboard shortcuts ==========
    # Открытие новой вкладки
    map ctrl+shift+t new_tab
    
    # Переключение вкладок
    map ctrl+tab next_tab
    map ctrl+shift+tab previous_tab
    
    # Переключение окон
    map ctrl+alt+h neighboring_window left
    map ctrl+alt+l neighboring_window right
    map ctrl+alt+k neighboring_window up
    map ctrl+alt+j neighboring_window down
    
    # Изменение размера окон
    map ctrl+alt+left resize_window narrower
    map ctrl+alt+right resize_window wider
    map ctrl+alt+up resize_window taller
    map ctrl+alt+down resize_window shorter
  '';
  
  # ========== Wrapper для opencode с нулевым padding ==========
  # Используется вместо обычного opencode для запуска в Kitty без padding
  # home.file.".local/bin/opencode-kitty".text = ''
  #   #!/bin/sh
  #   # Wrapper для запуска opencode в Kitty с нулевым padding
  #   # Используется при запуске через горячие клавиши
    
  #   exec kitty -o window_padding_width=0 -- opencode "$@"
  # '';
  # home.file.".local/bin/opencode-kitty".executable = true;
}
