{ config, pkgs, ... }:

let
  lantern = pkgs.callPackage ./lantern-module.nix { };
in
{
  system.activationScripts.lanternSymlink = ''
    if [ ! -L /usr/lib/lantern ] || [ "$(readlink /usr/lib/lantern)" != "${lantern}/lib/lantern" ]; then
      mkdir -p /usr/lib
      rm -rf /usr/lib/lantern
      ln -sfn ${lantern}/lib/lantern /usr/lib/lantern
    fi
  '';

  systemd.services.lanternd = {
    description = "Lantern Daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "/usr/lib/lantern/lanternd run";
      Restart = "on-failure";
      RestartSec = "5s";

      User = "root";
      Group = "root";

      StateDirectory = "lantern";
      StateDirectoryMode = "0755";
      RuntimeDirectory = "lantern";
      RuntimeDirectoryMode = "0777";
    };
  };

  environment.systemPackages = [ lantern ];
}
