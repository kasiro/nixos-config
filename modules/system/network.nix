# Сеть: NetworkManager, hostname, DNS
{ ... }:
{
  networking.networkmanager.enable = true;

  # NetworkManager connectivity check — чинит иконку "?" после перелогина
  environment.etc."NetworkManager/conf.d/20-connectivity.conf".text = ''
    [connectivity]
    uri=http://nmcheck.gnome.org/check_network_status.txt
  '';

  networking.hostName = "nixos";
  networking.nameservers = [ "185.236.104.104" "45.90.28.0" "1.1.1.1" "8.8.8.8" ];
}
