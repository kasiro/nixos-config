{ pkgs, ... }:
{
  # Qtile + пакеты
  home.packages = with pkgs; [
    qtile
    qtile-extras
    alacritty
    firefox
    vscode-oss
    spotify
    thunar
    rofi-wayland
    picom
    dunst
    nitrogen
    cbatticon
    volumeicon
    udiskie
    networkmanagerapplet
    pamixer
    playerctl
    brightnessctl
    nerd-fonts.ubuntu-mono
  ];

  # Конфиг Qtile
  xdg.configFile."qtile/config.py".source = ../../../../modules/qtile/config.py;
  xdg.configFile."qtile/settings".source = ../../../../modules/qtile/settings;
  xdg.configFile."qtile/themes".source = ../../../../modules/qtile/themes;
  xdg.configFile."qtile/autostart.sh".source = ../../../../modules/qtile/autostart.sh;
  xdg.configFile."qtile/scripts".source = ../../../../modules/qtile/scripts;
}
