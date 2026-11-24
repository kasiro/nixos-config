{ ... }:
{
  # Kitty — типизированный HM-модуль вместо plain kitty.conf.
  # settings сериализуется как «key value»; bool → yes/no; строки — как есть.
  programs.kitty = {
    enable = true;

    # shellIntegration.mode = null: HM по умолчанию ставит "no-rc" (пишет свою
    # shell_integration и вручную source'ит интеграцию в fish). Оставляем
    # исходное поведение — kitty.conf управляет сам через settings.
    shellIntegration.mode = null;

    settings = {
      # Font size (float сериализуется как «11», эквивалентно 11.0)
      font_size = 11.0;

      cursor_shape = "beam";
      cursor_trail = 10;
      wayland_titlebar_color = "system";
      linux_display_server = "wayland";
      remember_window_size = false;
      initial_window_state = "normal";

      # Не спрашивать подтверждение при закрытии окна с запущенным процессом
      confirm_os_window_close = 0;

      # Shell integration: только no-cursor, остальное — kitty по умолчанию
      shell_integration = "no-cursor";

      # Disable noise sound
      enable_audio_bell = false;

      # MAIN
      foreground = "#F5F3F2";
      background = "#1a1b26";
      background_opacity = 0.5;

      # Курсор и ввод
      cursor_text_color = "#1a1b26";

      # BLACK
      color0 = "#151720";
      color8 = "#151720";

      # RED
      color1 = "#ff7a93";
      color9 = "#ff7a93";

      # GREEN
      color2 = "#94e2d5";
      color10 = "#94e2d5";

      # YELLOW
      color3 = "#eed49f";
      color11 = "#eed49f";

      # BLUE
      color4 = "#bb9af7";
      color12 = "#bb9af7";

      # MAGENTA
      color5 = "#c6a0f6";
      color13 = "#c6a0f6";

      # CYAN
      color6 = "#b7bdf8";
      color14 = "#b7bdf8";

      # WHITE
      color7 = "#F5F3F2";
      color15 = "#F5F3F2";
    };

    # Генерируемый kitty-блок шрифтов (kitten choose-font его перезаписывает) —
    # вербатимно; programs.kitty.font НЕ задаём, чтобы не дублировать font_family.
    extraConfig = ''
      # BEGIN_KITTY_FONTS
      font_family      family="0xProto Nerd Font Mono"
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      # END_KITTY_FONTS

      # Тема Noctalia: apply-скрипт шаблона «kitty» ищет эту строку по точному
      # совпадению («include themes/noctalia.conf»). Пока строка на месте,
      # скрипт не изменяет kitty.conf (HM-симлинк в store, запись в него
      # невозможна), а пишет только ~/.config/kitty/themes/noctalia.conf.
      # include стоит ПОСЛЕ настроек HM (settings собираются с mkOrder 540,
      # пользовательский extraConfig — после них) и перекрывает блок цветов.
      include themes/noctalia.conf
    '';
  };
}
