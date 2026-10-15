# Запуск динамически слинкованных бинарников извне nixpkgs
{ ... }:
{
  programs.nix-ld.enable = true;
}
