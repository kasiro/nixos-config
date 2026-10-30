# Точка входа — только оглавление. Вся логика в модулях.
{ ... }: {
  imports = [
    ./modules
    ./users
  ];

  system.stateVersion = "26.05";
}