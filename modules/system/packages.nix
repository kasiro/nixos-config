# Системные пакеты (доступны всем пользователям)
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    jq
    micro
    neovim
    obsidian
    telegram-desktop

    appimage-run
    gnome-randr
    usbutils

    pavucontrol
    pulseaudio

    nodejs
    bun
    python3
    uv

    wl-clipboard
    gnome-extension-manager
    chromium

    cargo
    rustc
    rustup

    btop
    pciutils

    fastfetch
    microfetch
    bat
    opencode

    # nix
    nix-info
    direnv
    nix-direnv
    dconf2nix
    nix-prefetch-github
    nix-your-shell
    update-nix-fetchgit
    nix-output-monitor
    nh

    (nerdfonts.override { fonts = [
     "JetBrainsMono"
     "FiraCode"
     "Hack"
    ]; })

    ydotool
    wtype
    gcc
    gnumake
    unzip
    fd
    ripgrep
    tree-sitter

    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.tophat
    gnomeExtensions.clipboard-history
    gnomeExtensions.window-calls
    gnomeExtensions.app-hider
    gnomeExtensions.kando-integration
    bibata-cursors
  ];
}
