# GNOME-specific systemd сервисы
{ config, pkgs, ... }:
let
  # Агент нужен в Sway/Hyprland (там своего нет), но в GNOME уже работает
  # агент gnome-shell → «An authentication agent already exists». Условие по
  # XDG_CURRENT_DESKTOP через systemd невозможно (нет отрицания значения),
  # поэтому фильтруем в обёртке: в GNOME выходим успешно, иначе запускаем агент.
  polkitAgent = pkgs.writeShellScript "polkit-gnome-agent" ''
    case ":$XDG_CURRENT_DESKTOP:" in
      *:GNOME:*) exit 0 ;;
    esac
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
  '';
in
{
  systemd.user.services = {
    # gnome-keyring НЕ переопределяем: юнит с корректным ExecStart определён
    # в modules/desktop/sway.nix и работает во всех сессиях (Sway, Hyprland,
    # GNOME). Перекрытие без Service.ExecStart давало
    # «Service has no ExecStart= … Refusing».
    #
    # polkit-агент нужен и в Sway/Hyprland (условие по DE — в обёртке выше).
    polkit-gnome = {
      Unit = {
        Description = "PolicyKit GNOME Authentication Agent";
      };
      Service = {
        ExecStart = "${polkitAgent}";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
