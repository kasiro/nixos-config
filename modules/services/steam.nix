# Игры: Steam + GameMode
{ pkgs, pkgs-steam, ... }: {
  programs.steam = {
    enable = true;
    package = pkgs-steam.steam;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ ];
  };
  programs.gamemode.enable = true;
}
