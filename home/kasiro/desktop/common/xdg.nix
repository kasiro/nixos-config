# XDG переменные — общие для всех DE
{ ... }:
{
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  # Принудительная перезапись user-dirs.dirs (если существует)
  xdg.configFile."user-dirs.dirs".force = true;
}
