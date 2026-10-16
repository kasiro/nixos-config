{
  pkgs,
  ...
}:
{
  imports = [
    ./desktop
    ./programs
    ./services
    ../common
  ];

  home.username = "whitepeach";

  home.packages = with pkgs; [
    home-manager
  ];
}
