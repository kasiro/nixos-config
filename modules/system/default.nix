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
      extraArgs = "--keep-since 10d --keep 8";
    };
    flake = "/home/kasiro/nixos-config";
  };
}
