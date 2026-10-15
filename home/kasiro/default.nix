{
  pkgs,
  ...
}:
{
  imports = [
    ./desktop
    ./programs
    ./shell
    ./fish.nix
    ../common
  ];

  home.username = "kasiro";
  home.homeDirectory = "/home/kasiro";
  home.stateVersion = "26.05";

  # Пакеты только для kasiro
  home.packages = with pkgs; [
    nix-your-shell
    nix-output-monitor
    nvtopPackages.nvidia
    update-nix-fetchgit
    winetricks
    repomix
    qbittorrent
    tree
    nh
    keet
    # homebank # (посчитай налик)
  ];

  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;
  xdg.mime.enable = true;

  # Для Qtile (если вернёшь):
  # xdg.configFile."qtile/config.py".source = ../../modules/qtile/qtile-config.py;
}
