# Всё, что касается nix-демона: производительность, GC, политики
{ ... }:
{
  # Разрешаем unfree-пакеты (obsidian и т.п.)
  nixpkgs.config.allowUnfree = true;
  documentation = {
    enable = false;
    man = {
      enable = false;
      cache.enable = false;  # Отключить man-cache (apropos, man -k)
    };
    info.enable = false;
    doc.enable = false;
    nixos.enable = false;
  };

  nix.settings = {
    # Параллелизм (HDD + 8GB RAM)
    max-jobs = 2;
    cores = 2;
    
    # Кэширование — все публичные кэши
    auto-optimise-store = true;
    builders-use-substitutes = true;
    substituters = [
      "https://nyx-cache.chaotic.cx/?priority=5"
      "https://nix-community.cachix.org?priority=10"
      "https://cache.nixos.org?priority=40"
    ];
    trusted-public-keys = [
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    
    # GC для экономии места на HDD
    min-free = 1 * 1024 * 1024 * 1024;   # 1GB минимально
    max-free = 4 * 1024 * 1024 * 1024;   # 4GB целевой запас
    
    # Прочее
    keep-outputs = true;
    keep-derivations = true;
    allowed-users = [ "kasiro" "whitepeach" ];
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Сборка мусора — отключено (nh clean делает это)
  nix.gc.automatic = false;

  # Дедупликация store
  nix.optimise.automatic = true;
}
