{
  pkgs,
  ...
}:
{
  imports =
    [
      ./desktop/common
      ./desktop/gnome
      ./desktop/sway
      ./desktop/cosmic
      ./programs
      ./shell
      ./fish.nix
      ../common
    ];

  home.username = "kasiro";

  # Пакеты только для kasiro (DE-specific в desktop/*/packages.nix)
  home.packages = with pkgs; [
    nvtopPackages.nvidia
    # homebank # (посчитай налик)
  ];
}
