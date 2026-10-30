{ pkgs, ... }:
let

  # Собираем path-server из исходников
  path-server = pkgs.rustPlatform.buildRustPackage rec {
    pname = "path-server";
    version = "1.4.2"; # Проверь актуальную версию на GitHub

    src = pkgs.fetchFromGitHub {
      owner = "kunlinglio";
      repo = "path-server";
      rev = "v${version}"; # или конкретный коммит
      hash = "sha256-DKIDQZB9hzbS02fLheGo5yIdelpP2G6+VvRrVs0cj50=";
    };

    # Если в репозитории есть Cargo.lock, укажи его хэш
    cargoHash = "sha256-e9m175il3hzmMqVzuMF6e+8ByvAF+7XQheIS/f8JyUY=";

    # Отключаем ненужные проверки, если они мешают
    doCheck = false;
  };

  zedLaunch = pkgs.writeShellScriptBin "zed-launch" ''
    export WAYLAND_DISPLAY=""
    export MESA_VK_DEVICE_SELECT=10de:1402
    exec ${pkgs.zed-editor}/bin/zeditor "$@"
  '';

in
{
  targets.genericLinux.nixGL.vulkan.enable = true;

  home.packages =
    (with pkgs; [
      nixd
      nil
      rust-analyzer
      pyright
      luaPackages.lua-lsp
      fish-lsp
    ])
    ++ [
      zedLaunch
      path-server
    ];

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;

    userSettings = {
      # Тема и шрифты
      theme = "Catppuccin Macchiato - No Italics";
      show_completions_on_input = true;

      keymap = [
        {
          key = "alt+d";
          command = "editor::DuplicateLineDown";
        }
      ];

      # Настройки терминала
      # terminal = {
      #   shell = {
      #     with_arguments = {
      #       program = "${pkgs.fish}/bin/fish";
      #     };
      #   };
      #   line_height = "comfortable";
      #   env = {
      #     PATH = "/run/wrappers/bin:/run/current-system/sw/bin:$PATH";
      #   };
      # };
      languages.nix = {
        ensure_final_newline_on_save = false;
        remove_trailing_whitespace_on_save = false;
        format_on_save = "off";
      };

      # Настройки LSP (языковых серверов)
      # Это решит проблему, когда Zed не может скачать серверы сам
      lsp =
        pkgs.lib.genAttrs
          [
            "nix"
            "rust-analyzer"
            "pyright"
            "lua"
            "path-server-lsp"
            "fish-lsp"
          ]
          (name: {
            binary.path_lookup = true;
          });

      # Другие полезные настройки
      auto_update = false; # Отключаем автообновление, т.к. управляем через Nix
      hour_format = "hour24";
      vim_mode = false;

      extension_development_paths = [
        "/home/kasiro/Документы/dl/zed-dl"
      ];
    };

    # Список расширений для автоматической установки
    extensions = [
      "nix"
      "toml"
      "rust"
      "make"
      "pylsp"
      "lua"
      "path-server-lsp"
      "fish"
      "color-highlight"
    ];
  };

  xdg.desktopEntries.zed = {
    name = "Zed";
    comment = "Code Editor";
    exec = "${zedLaunch}/bin/zed-launch %F";
    icon = "zed";
    terminal = false;
    categories = [
      "Development"
      "IDE"
      "TextEditor"
    ];
    mimeType = [ "text/plain" ];
    settings = {
      StartupWMClass = "dev.zed.Zed";
    };
  };
}
