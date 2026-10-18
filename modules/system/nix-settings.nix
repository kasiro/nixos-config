# Всё, что касается nix-демона: производительность, GC, политики
{ ... }:
{
  # Разрешаем unfree-пакеты (obsidian и т.п.)
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    # Параллелизм (HDD + 8GB RAM)
    max-jobs = 2;
    cores = 2;
    
    # Кэширование
    auto-optimise-store = true;
    builders-use-substitutes = true;
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    
    # Прочее
    keep-outputs = true;
    keep-derivations = true;
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
