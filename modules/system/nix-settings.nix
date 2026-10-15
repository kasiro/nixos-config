# Всё, что касается nix-демона: производительность, GC, политики
{ ... }:
{
  # Разрешаем unfree-пакеты (obsidian и т.п.)
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    max-jobs = "auto";
    cores = 0;
    keep-outputs = true;
    keep-derivations = true;
    # Кто имеет право использовать nix/nixos-rebuild
    allowed-users = [ "kasiro" "whitepeach" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Сборка мусора
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Дедупликация store
  nix.optimise.automatic = true;
}
