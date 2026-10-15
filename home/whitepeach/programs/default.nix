{ lib, ... }:
let
  dir = ./.;

  # Файлы, которые НЕ нужно импортировать
  ignored = [
    "default.nix"
  ];

  entries = builtins.readDir dir;

  modules = lib.filterAttrs
    (name: type:
      type == "regular"
      && lib.hasSuffix ".nix" name
      && !(builtins.elem name ignored))
    entries;
in
{
  imports = map (name: dir + "/${name}") (builtins.attrNames modules);
}
