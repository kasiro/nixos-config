{ config, ... }:
{
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";
  xdg.enable = true;
  xdg.mime.enable = true;
  nixpkgs.config.allowUnfree = true;
}
