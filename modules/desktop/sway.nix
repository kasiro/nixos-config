# Sway — лёгкий тайловый WM на Wayland
{ pkgs, ... }:
{
  # Сам Sway + XWayland для старых X11-приложений
  programs.sway = {
    enable = true;
    xwayland.enable = true;
    wrapperFeatures.gtk = true; # Корректная работа GTK-приложений
  };

  # GDM уже включён в gnome.nix — он увидит sway-сессию автоматически.
  # Если GNOME больше не нужен, закомментируй services.desktopManager.gnome.enable
  # в modules/desktop/gnome.nix.

  # Пакеты, которые нужны для полноценной работы Sway
  environment.systemPackages = with pkgs; [
    # Утилиты sway
    swaylock # Блокировка экрана
    swayidle # Управление питанием/блокировкой
    swaybg # Обои
    mako # Лёгкий нотификейшн-демон (замена dunst)
    waybar # Панель (альтернатива встроенной, красивая)
    wofi # Лаунчер приложений (аналог rofi для Wayland)
    grim # Скриншоты
    slurp # Выбор области для скриншота
    wl-clipboard # Буфер обмена (уже есть в systemPackages, но на всякий)
    brightnessctl # Яркость
    playerctl # Управление медиа
    pamixer # Громкость из CLI
    foot # Сверхлёгкий терминал для Wayland
    alacritty # Запасной терминал
    kitty # Ещё один вариант
  ];

  # Переменные окружения для NVIDIA legacy_580 + GTX 950
  environment.sessionVariables = {
    # Критично для старых NVIDIA на wlroots — иначе курсор мерцает/пропадает
    WLR_NO_HARDWARE_CURSORS = "1";
    # Рендер через OpenGL (для Maxwell стабильнее, чем Vulkan)
    WLR_RENDERER = "gl";
    # Для Electron-приложений (Chromium, Obsidian, Happ, Lantern)
    NIXOS_OZONE_WL = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # polkit-агент для GUI-запросов прав (нужен в sway, т.к. нет GNOME)
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome = {
    description = "Polkit GNOME agent for Sway";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
