# Hyprland configuration for home-manager
# Based on swrneko/dots-next
#
# Единственный источник конфига — ./hyprland/hyprland.lua (Lua API Hyprland 0.57).

{ pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    # Сам Hyprland ставит NixOS-модуль programs.hyprland (flake input hyprland),
    # пакет из nixpkgs здесь не нужен.
    package = null;

    # xdg-desktop-portal-hyprland регистрирует NixOS-модуль programs.hyprland —
    # повторное подключение даёт коллизию user-юнитов «File exists».
    portalPackage = null;

    configType = "lua";
    systemd.enable = true;
    xwayland.enable = true;

    # В этой ревизии home-manager нет опций extraLuaFiles/sourceFile/configFile,
    # поэтому содержимое репозиториевского Lua вставляется в генерируемый
    # ~/.config/hypr/hyprland.lua через extraConfig.
    extraConfig = lib.fileContents ./hyprland/hyprland.lua;
  };

  # Шрифты
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Шрифты
    nerd-fonts._0xproto
    nerd-fonts.comic-shanns-mono
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # Утилиты для Hyprland
    hyprlock
    hypridle
    hyprpicker
    hyprlang

    # Noctalia
    noctalia

    # Терминал
    kitty

    # Утилиты
    grim
    slurp
    wl-clipboard
    brightnessctl
    playerctl
    wireplumber
    pipewire
    pulseaudio

    # Файловый менеджер
    nemo
    nemo-fileroller

    # Системные
    btop
    xrdb
    xrandr
    xsetroot
    xprop
    xwininfo
    xdg-utils
  ];

  # XDG порталы (только gtk: hyprland-портал уже даёт NixOS-модуль)
  xdg.portal = {
    enable = lib.mkForce true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [
      hyprland
      noctalia
    ];
  };

  # Конфигурационные файлы
  xdg.configFile = {
    # Noctalia конфиг
    "noctalia/config.toml".source = ./hyprland/noctalia.toml;

    # Kitty конфиг
    "kitty/kitty.conf".source = ./hyprland/kitty.conf;

    # Hyprlock конфиг
    "hypr/hyprlock.conf".source = ./hyprland/hyprlock.conf;

    # Скрипт группировки окон
    "hypr/scripts/group-all-windows.py" = {
      source = ./hyprland/scripts/group-all-windows.py;
      executable = true;
    };
  };
}
