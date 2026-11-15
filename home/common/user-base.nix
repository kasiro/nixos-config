{ config, ... }:
{
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";
  xdg.enable = true;
  xdg.mime.enable = true;

  # nixpkgs.config здесь НЕ задаём: при useGlobalPkgs игнорируется.
  # allowUnfree разрешён системно в modules/system/nix-settings.nix.

  # Man выключен на обоих этажах: системном (nix-settings.nix) и здесь.
  # programs.man по умолчанию true → man-db в home-path + mandb при активации.
  programs.man = {
    enable = false;
    generateCaches = false;
  };
  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
