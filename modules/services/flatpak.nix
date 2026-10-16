# Flatpak
{ inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "com.usebottles.bottles"
      # "io.keet.Keet"
    ];
  };
}
