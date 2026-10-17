{ pkgs, ... }:
{
  # COSMIC Desktop
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # X11-сессия COSMIC (для legacy NVIDIA)
  # Wayland-сессия тоже будет доступна в GDM
  # services.displayManager.defaultSession = "cosmic";

  # Дополнительные пакеты COSMIC (опционально)
  environment.systemPackages = with pkgs; [
    cosmic-edit       # текстовый редактор
    cosmic-files      # файловый менеджер
    cosmic-term       # терминал
    cosmic-launcher   # лаунчер приложений
    cosmic-settings   # настройки
  ];
}
