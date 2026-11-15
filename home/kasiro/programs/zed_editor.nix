{ pkgs, lib, ... }:
let
  # Собираем path-server из исходников
  path-server = pkgs.rustPlatform.buildRustPackage rec {
    pname = "path-server";
    version = "1.4.2";

    src = pkgs.fetchFromGitHub {
      owner = "kunlinglio";
      repo = "path-server";
      rev = "v${version}";
      hash = "sha256-DKIDQZB9hzbS02fLheGo5yIdelpP2G6+VvRrVs0cj50=";
    };

    cargoHash = "sha256-e9m175il3hzmMqVzuMF6e+8ByvAF+7XQheIS/f8JyUY=";
    doCheck = false;
  };

  # WAYLAND_DISPLAY="" — намеренный XWayland. MESA_VK_DEVICE_SELECT убран:
  # на проприетарном драйвере NVIDIA он не влияет ни на что (это ключ mesa).
  zedLaunch = pkgs.writeShellScriptBin "zed-launch" ''
    export WAYLAND_DISPLAY=""
    exec ${pkgs.zed-editor}/bin/zeditor "$@"
  '';
in
{
  # targets.genericLinux.nixGL.* убран: genericLinux — таргет для НЕ-NixOS.

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;

    # LSP — в PATH обёртки Zed (тогда binary.path_lookup их находит).
    # nil убран: два Nix-сервера одновременно не нужны, оставлен nixd.
    extraPackages = with pkgs; [
      nixd
      rust-analyzer
      pyright
      lua-language-server
      fish-lsp
      path-server
    ];

    # Zed сам пишет settings.json/keymap.json при правках из UI. Без mutable*
    # это симлинк в store → «read-only». Размен: GUI-правки живут, но могут
    # разъехаться с Nix. Хочешь чистую декларативность — поставь false.
    mutableUserSettings = true;
    mutableUserKeymaps = true;

    # Кеймапы живут в keymap.json, а не в settings.json
    userKeymaps = [
      {
        context = "Editor";
        bindings = { "alt-d" = "editor::DuplicateLineDown"; };
      }
    ];

    userSettings = {
      theme = "Catppuccin Macchiato - No Italics";
      show_completions_on_input = true;
      auto_update = false;
      hour_format = "hour24";
      vim_mode = false;

      # Имя языка — как в UI Zed, с большой буквы. "nix" игнорировался.
      languages.Nix = {
        ensure_final_newline_on_save = false;
        remove_trailing_whitespace_on_save = false;
        format_on_save = "off";
      };

      # Ключи lsp — имена СЕРВЕРОВ, не языков ("nix"/"lua" были мимо)
      lsp = lib.genAttrs
        [ "nixd" "rust-analyzer" "pyright" "lua-language-server" "fish-lsp" "path-server-lsp" ]
        (_: { binary.path_lookup = true; });

      extension_development_paths = [ "/home/kasiro/Документы/dl/zed-dl" ];
    };

    # "pylsp" убран: в пакетах pyright, а расширение тянет другой сервер
    extensions = [ "nix" "toml" "rust" "make" "lua" "fish" "path-server-lsp" ];
  };

  home.packages = [ zedLaunch ];

  xdg.desktopEntries.zed = {
    name = "Zed";
    comment = "Code Editor";
    exec = "${zedLaunch}/bin/zed-launch %F";
    icon = "zed";
    terminal = false;
    categories = [ "Development" "IDE" "TextEditor" ];
    mimeType = [ "text/plain" ];
    settings.StartupWMClass = "dev.zed.Zed";
  };
}
