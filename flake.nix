{
  description = "Kasiro's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-steam.url = "github:NixOS/nixpkgs/2786a2a72088ecf32aea5b3ec52099e6a7cff78f";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL?rev=4306ae1d15adf3d386f1462b330d4f2648404711";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak?rev=02656785ab214fa1c9655f1beaaf0269eeeec2ca";
    chaotic.url = "github:chaotic-cx/nyx/main";
    hermes-agent.url = "github:NousResearch/hermes-agent?rev=31a161a6d2b9169dddf6633c096fe038e6925d0f";
    hyprland.url = "github:hyprwm/Hyprland?rev=423da96907feb3eef7ca4e06dc5cb69e9eec63a8";
    # HM-модуль noctalia (programs.noctalia, settings → TOML)
    noctalia.url = "github:noctalia-dev/noctalia?rev=30daf36c1e7729ac29fa787b48bc2af136689635";
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
      nixpkgs-steam,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      pkgs-steam = import nixpkgs-steam {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs-steam; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          chaotic.nixosModules.default {
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
            home-manager.useGlobalPkgs = true;
          }
        ];
      };
    };
}
