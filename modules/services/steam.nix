# Игры: Steam + GameMode
{ ... }:
let
  theme = import ../../themes/kasiro/theme.nix;
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ ];
  };
  programs.gamemode.enable = true;

  environment.sessionVariables = {
    STEAM_CURSOR_THEME = theme.cursorTheme;
  };
}
