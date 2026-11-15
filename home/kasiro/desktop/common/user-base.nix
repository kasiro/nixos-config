{
  programs.man = {
    enable = false;          # man-db в home-path не ставим
    generateCaches = false;  # mandb при активации не гоняем
  };
  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
