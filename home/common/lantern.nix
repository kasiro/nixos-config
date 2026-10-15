{ pkgs, ... }:

let
  lantern = pkgs.callPackage ../../modules/services/lantern/lantern-module.nix { };
in
{
  home.packages = [ lantern ];

  home.file.".local/share/applications/lantern.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Lantern
    Comment=Proxy client
    Exec=/run/wrappers/bin/doas ${lantern}/bin/lantern
    TryExec=/run/wrappers/bin/doas
    Icon=${lantern}/share/icons/hicolor/128x128/apps/lantern.png
    Categories=Network;
    Terminal=false
    StartupNotify=false
    StartupWMClass=org.getlantern.lantern
  '';
}
