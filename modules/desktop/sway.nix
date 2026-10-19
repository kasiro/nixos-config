# Sway — лёгкий тайловый WM на Wayland
# Исправлено 2026-10-19:
# - GDM запускал .desktop из store-пакета без флага → Nvidia блокировала sway
#   (3 неудачных входа подряд, логи sway/server.c:175)
# - Фикс: overlay на swayfx-unwrapped подменяет Exec на 'sway --unsupported-gpu'
#   + programs.sway.extraOptions как второй уровень защиты
# - Удалён невалидный WLR_RENDERER=gl (wlroots 0.17+ его не знает)
{ config, pkgs, ... }:
let
  theme = import ../../themes/kasiro/theme.nix;
in
{
  # Overlay: подменяем .desktop чтобы GDM запускал sway с обходом Nvidia.
  # NOTE: патчим swayfx-unwrapped (stdenv.mkDerivation+meson), а НЕ pkgs.swayfx —
  # pkgs.swayfx это symlinkJoin-обёртка без фазы postInstall, её postInstall игнорируется.
  # .desktop финального пакета — симлинк на swayfx-unwrapped, правка подхватится.
  nixpkgs.overlays = [
    (final: prev: {
      swayfx-unwrapped = prev.swayfx-unwrapped.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/wayland-sessions/sway.desktop \
            --replace-fail 'Exec=sway' 'Exec=sway --unsupported-gpu'
        '';
      });
    })
  ];

  # Сам Sway + XWayland для старых X11-приложений
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    xwayland.enable = true;
    wrapperFeatures.gtk = true; # Корректная работа GTK-приложений
    # Обёртка sway добавит флаг в Exec=sway .desktop-файла сессии,
    # который GDM читает из services.displayManager.sessionPackages
    # (store-пакет), а НЕ из /etc/wayland-sessions
    extraOptions = [ "--unsupported-gpu" ]; # NVIDIA proprietary (GTX 950)
  };

  # Пакеты, которые нужны для полноценной работы Sway
  environment.systemPackages = with pkgs; [
    # NOTE: сам swayfx уже ставится модулем programs.sway (обёрнутый с extraOptions),
    # сырой пакет здесь конфликтовал бы по bin/sway
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
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    SWAY_UNSUPPORTED_GPU = "true";  # Убирает warning о NVIDIA
    XCURSOR_THEME = theme.cursorTheme;
    XCURSOR_SIZE = toString theme.cursorSize;
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
