{
  pkgs,
  inputs,
  ...
}:
{
  imports =
    [
      ./desktop/common
      ./desktop/gnome
      ./desktop/hyprland.nix
      ./programs
      ./shell
      ./fish.nix
      ../common

      # Типизированный HM-модуль noctalia (programs.noctalia) из flake проекта
      inputs.noctalia.homeModules.default
    ];

  home.username = "kasiro";

  # Пакеты только для kasiro (DE-specific в desktop/*/packages.nix)
  home.packages = with pkgs; [
    nvtopPackages.nvidia
    # homebank # (посчитай налик)
  ];
}
