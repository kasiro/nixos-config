# Запуск динамически слинкованных бинарников извне nixpkgs
{ ... }:
{
  programs.nix-ld.enable = true;

  # библиотеки для обычных не nix программ если будут нужны или будут ошибки.
  # programs.nix-ld.libraries = [];
}
