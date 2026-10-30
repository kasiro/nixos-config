{ pkgs, ... }:
{
  home.packages = with pkgs; [
    waycal  # Календарь popup (как в GNOME/COSMIC)
  ];
}
