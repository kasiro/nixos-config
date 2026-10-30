{ lib, ... }:
let
  dir = ./.;

  ignored = [
    "default.nix"
  ];

  entries = builtins.readDir dir;

  modules = lib.filterAttrs (
    name: type:
    !(builtins.elem name ignored)
    && (type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name))
  ) entries;
in
{
  imports = map (name: dir + "/${name}") (builtins.attrNames modules);
}
