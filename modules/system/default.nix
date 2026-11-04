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
    ./fontconfig-cache.nix
  ];

  programs.nh.clean = {
    enable = true;
    extraArgs = "--keep-since 4d --keep 4";
  };
}
