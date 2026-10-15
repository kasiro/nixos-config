# doas вместо sudo
{ pkgs, ... }:
{
  security.doas.enable = true;
  security.doas.extraConfig = ''
    permit nopass keepenv :wheel
  '';
  security.wrappers.doas = {
    source = "${pkgs.doas}/bin/doas";
    owner = "root";
    group = "root";
    setuid = true;
    permissions = "u+rx,g+x,o+x";
  };
}
