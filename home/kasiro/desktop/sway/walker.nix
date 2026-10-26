# Walker — основной лаунчер (drun-аналог) на бэкенде elephant.
# wofi.nix сохранён как fallback, но его биндинг отключён (см. keybindings.nix).
{ sway, ... }:
let
  palette = sway.catppuccin;
  themeName = "catppuccin";
in
{
  # elephant — сервис-провайдер данных: desktopapplications (drun), иконки, история
  services.elephant.enable = true;

  services.walker = {
    enable = true;
    # systemd-сервис `walker --gapplication-service`: окно по биндингу открывается мгновенно
    systemd.enable = true;
    # Requires/After=elephant.service (юнит создаётся модулем services.elephant)
    enableElephantIntegration = true;

    settings = {
      theme = themeName;
      placeholders.default = {
        input = "Поиск…";
        list = "Ничего не найдено";
      };
    };

    theme = {
      name = themeName;
      # GTK4 CSS в стиле Catppuccin Mocha (по мотивам текущего wofi-конфига).
      # layout.xml не переопределяется — берётся встроенный из пакета.
      style = ''
        @define-color base      ${palette.base};
        @define-color mantle    ${palette.mantle};
        @define-color crust     ${palette.crust};
        @define-color text      ${palette.text};
        @define-color subtext0  ${palette.subtext0};
        @define-color overlay0  ${palette.overlay0};
        @define-color surface0  ${palette.surface0};
        @define-color surface1  ${palette.surface1};
        @define-color mauve     ${palette.mauve};
        @define-color red       ${palette.red};

        * {
          all: unset;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
        }

        /* Слой-шелл тянется на весь экран: фон окна должен быть прозрачным */
        .window {
          background: transparent;
        }

        popover {
          background: rgba(30, 30, 46, 0.85);
          border: 1px solid @surface1;
          border-radius: 10px;
          padding: 8px;
          backdrop-filter: blur(10px);
          -webkit-backdrop-filter: blur(10px);
        }

        .box-wrapper {
          background: @base;
          border: 2px solid @mauve;
          border-radius: 12px;
          padding: 10px;
          box-shadow:
            0 19px 38px rgba(0, 0, 0, 0.3),
            0 15px 12px rgba(0, 0, 0, 0.22);
        }

        .search-container {
          border-radius: 8px;
        }

        .input {
          background: @surface0;
          color: @text;
          caret-color: @mauve;
          border-radius: 8px;
          padding: 10px;
        }

        .input placeholder {
          color: @overlay0;
        }

        .input selection {
          background: @mauve;
          color: @base;
        }

        .list {
          color: @text;
        }

        .item-box {
          padding: 8px 10px;
          border-radius: 6px;
        }

        child:selected .item-box,
        row:selected .item-box {
          background: @mauve;
        }

        child:selected .item-text,
        child:selected .item-subtext,
        row:selected .item-text,
        row:selected .item-subtext {
          color: @base;
        }

        .item-text {
          font-size: 13px;
        }

        .item-subtext {
          font-size: 11px;
          color: @subtext0;
        }

        .item-image {
          -gtk-icon-size: 24px;
        }

        .normal-icons {
          -gtk-icon-size: 16px;
        }

        .large-icons {
          -gtk-icon-size: 24px;
        }

        .item-image-text {
          font-size: 20px;
        }

        .item-quick-activation {
          background: alpha(@surface1, 0.5);
          border-radius: 4px;
          padding: 2px 6px;
          color: @subtext0;
        }

        scrollbar {
          opacity: 0;
        }

        .placeholder,
        .elephant-hint,
        .preview-box {
          color: @overlay0;
        }

        .preview {
          border: 1px solid @surface1;
          border-radius: 8px;
        }

        .keybinds {
          border-top: 1px solid @surface0;
          padding-top: 6px;
          font-size: 11px;
          color: @overlay0;
        }

        .keybind-button {
          opacity: 0.7;
        }

        .keybind-button:hover {
          opacity: 1;
        }

        .keybind-bind {
          opacity: 0.5;
        }

        .keybind-label {
          border: 1px solid @surface1;
          border-radius: 4px;
          padding: 0 4px;
          color: @subtext0;
        }

        .error {
          background: @red;
          color: @base;
          padding: 10px;
          border-radius: 6px;
        }
      '';
    };
  };
}
