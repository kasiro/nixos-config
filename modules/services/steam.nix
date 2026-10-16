# Игры: Steam + GameMode
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ ];
  };
  programs.gamemode.enable = true;
}
