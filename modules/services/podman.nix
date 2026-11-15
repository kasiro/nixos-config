# Podman вместо Docker: без демона, rootless, docker-совместимый CLI и сокет
{ pkgs, ... }:
{
  virtualisation.containers.enable = true;

  virtualisation.podman = {
    enable = true;
    # Алиас docker → podman. С virtualisation.docker.enable не уживается
    # (в nixpkgs есть assertion), поэтому docker.nix удаляем.
    dockerCompat = true;
    # Docker-совместимый сокет для клиентов, умеющих только Docker API
    # (docker-compose, IDE, testcontainers). Socket-activation: сервис
    # поднимается на первое обращение, в простое не висит ничего.
    dockerSocket.enable = false;
    # DNS между контейнерами в rootless-сетях (aardvark-dns)
    defaultNetwork.settings.dns_enabled = true;
    # Чистка неиспользуемых образов — на HDD это заметно
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  environment.systemPackages = with pkgs; [ podman-compose ];
}

