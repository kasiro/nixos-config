{ config, pkgs, lib, ... }:
{
  imports = [
    ./desktop
    ./programs
    ./services
    ../common
  ];

  home.username = "whitepeach";
  home.homeDirectory = "/home/whitepeach";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    home-manager
  ];

  nixpkgs.config.allowUnfree = true;
}
