# Точка входа — только оглавление. Вся логика в модулях.
{ ... }:
{
  imports = [
    ./modules
    ./modules/hardware/hardware-configuration.nix
    ./users
    ./modules/qtile/qtile.nix
  ];

  system.stateVersion = "26.05";
}
