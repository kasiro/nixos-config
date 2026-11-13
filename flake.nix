{
  description = "Kasiro's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    chaotic.url = "github:chaotic-cx/nyx/main";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # HM-модуль noctalia (programs.noctalia, settings → TOML)
    noctalia.url = "github:noctalia-dev/noctalia";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      chaotic,
      hermes-agent,
      hyprland,
      hyprland-plugins,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          chaotic.nixosModules.default
          {
            _module.args.pkgs-unstable = pkgs-unstable;
            nixpkgs.overlays = [
              (final: prev: {
                opencode = pkgs-unstable.opencode;
              })
            ];
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.kasiro = import ./home/kasiro;
            home-manager.users.whitepeach = import ./home/whitepeach;
          }
        ];
      };
    };
}