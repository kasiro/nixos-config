{ config, ... }:
{
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";
  # Man выключен на обоих этажах: системном (nix-settings.nix) и здесь.
  # programs.man по умолчанию true → man-db в home-path + mandb при активации.
  programs.man = {
    enable = false;
    generateCaches = false;   # в HM опция ещё не переименована
  };
  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
