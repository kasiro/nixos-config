{ lib, ... }:
let
  dir = ./.;

  ignored = [
    "default.nix"
    "common"
    "gnome"
    "sway"
    "cosmic"
  ];

  entries = builtins.readDir dir;

  # Подхватываем только дополнительные модули вне common/gnome/sway/cosmic
  modules = lib.filterAttrs (
    name: type:
    !(builtins.elem name ignored)
    && (type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name))
  ) entries;
in
{
  imports =
    [
      ./common
    ]
    ++ (map (name: dir + "/${name}") (builtins.attrNames modules));
}
