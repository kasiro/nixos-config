# Blur My Shell
{ ... }:
{
  dconf.settings."org/gnome/shell/extensions/blur-my-shell" = {
    # --- Общие настройки ---
    brightness = 0.60;
    noise-amount = 0;
    sigma = 30;
    color = "rgba(0,0,0,0.5)";

    # --- Приложения ---
    applications = true;
    applications-mode = "whitelist";
    applications-list = [
      "org.gnome.Console"
      "dev.zed.Zed"
      "chromium-browser"
    ];
    applications-opacity = 0.6;

    # --- Панель ---
    panel = true;
    panel-customize = true;
    panel-brightness = 0.6;
    panel-sigma = 30;
    panel-static-blur = false;

    # --- Обзор ---
    overview = true;
    overview-customize = true;
    overview-brightness = 0.6;
    overview-sigma = 40;
    overview-blur-on-overview = true;

    # --- Dash to Dock ---
    dash-to-dock = true;
    dash-to-dock-customize = true;
    dash-to-dock-brightness = 0.6;
    dash-to-dock-sigma = 30;
    dash-to-dock-static-blur = false;

    # --- Popup ---
    popup = true;
    popup-customize = true;
    popup-brightness = 0.6;
    popup-sigma = 20;

    # --- Дополнительно ---
    debug = false;
    hacks-level = 0;
  };
}
