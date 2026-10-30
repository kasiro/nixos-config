{ lib, ... }:
let
  dir = ./.;

  ignored = [
    "default.nix"
    "scripts"
  ];

  entries = builtins.readDir dir;

  # Подхватываем и .nix-файлы, и поддиректории (у них внутри тоже default.nix)
  modules = lib.filterAttrs (
    name: type:
    !(builtins.elem name ignored)
    && (type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name))
  ) entries;
in
{
  imports =
    [
      ../common
    ]
    ++ (map (name: dir + "/${name}") (builtins.attrNames modules));
}
