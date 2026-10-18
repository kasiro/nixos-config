{ ... }:
{
  imports = [
    ./nix-settings.nix
    ./environment.nix
    ./locale.nix
    ./network.nix
    ./packages.nix
    ./zram.nix
    ./boot.nix
    ./fish.nix
  ];

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
    flake = "/home/kasiro/nixos-config";
  };
}
