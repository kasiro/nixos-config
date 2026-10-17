{ pkgs, ... }:
{
  # COSMIC Desktop
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # X11-сессия COSMIC (для legacy NVIDIA)
  # Wayland-сессия тоже будет доступна в GDM
  services.displayManager.defaultSession = "cosmic";

  # Дополнительные пакеты COSMIC (опционально)
  environment.systemPackages = with pkgs; [
    # Ядро сессии и панель — ОБЯЗАТЕЛЬНО в PATH
    cosmic-session
    cosmic-comp
    cosmic-panel
    cosmic-applets
    cosmic-workspaces-epoch

    # Приложения
    cosmic-edit
    cosmic-files
    cosmic-term
    cosmic-launcher
    cosmic-settings
  ];
}
