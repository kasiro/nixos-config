# Точка входа — только оглавление. Вся логика в модулях.
{ ... }: {
  imports = [
    ./modules
    ./users
    # ./modules/qtile/qtile.nix
    # ./modules/services/lantern/lanternd.nix
  ];

  system.stateVersion = "26.05";
}