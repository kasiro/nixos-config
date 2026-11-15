# Игры: Steam + GameMode
{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    package = pkgs.steam;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ ];
  };
  programs.gamemode.enable = true;
}
