# qBittorrent (демон с веб-мордой)
{ ... }:
{
  services.qbittorrent = {
    enable = true;
    user = "kasiro";
    group = "users";
    openFirewall = true;
    # webuiPort = 8080;
    # torrentPort = 6881;
  };
}
