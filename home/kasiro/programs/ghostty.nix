{ pkgs, ... }:
{
  # Ghostty — терминал с нативной поддержкой blur
  # https://ghostty.org/docs/config/reference
  
  home.packages = with pkgs; [ ghostty ];
  
  # Конфиг Ghostty
  xdg.configFile."ghostty/config".text = ''
    # Прозрачность и blur (как KGX с blur-my-shell)
    background-opacity = 0.85
    background-blur = true
    
    # КРИТИЧНО: применять прозрачность ко ВСЕМ ячейкам (TUI, bubbletea)
    background-opacity-cells = true
    
    # Отступы
    window-padding-x = 10
    window-padding-y = 10
    
    # Шрифт
    font-family = "JetBrains Mono Nerd Font"
    font-size = 14
    
    # Тема
    theme = "dark:Catppuccin Mocha"
    
    # Cursor
    cursor-style = "block"
    cursor-style-blink = false
    
    # Copy/paste
    clipboard-trim-trailing-spaces = false
    confirm-close-surface = false
    
    # Window
    window-decoration = false
    window-align = "center"
  '';
}
