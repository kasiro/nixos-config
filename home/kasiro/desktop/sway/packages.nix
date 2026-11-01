{ pkgs, ... }:

let
  waycal = pkgs.rustPlatform.buildRustPackage {
    pname = "waycal";
    version = "0.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "ForrestKnight";
      repo = "waycal";
      rev = "v0.2.1";
      hash = "sha256-+B/fJWDJatWY9Mw5SmLboOfQARTTzHtTah/SSaM6Cx0=";
    };

    cargoHash = "sha256-brC1igJxiX5JB0BfpZqpQf88JEZFfQcGnWtW3QElrvE=";

    nativeBuilds = with pkgs; [
      pkg-config
    ];
    
    buildInputs = with pkgs; [
      gtk4
      glib
      gtk4-layer-shell
    ];
  };
in
{
  home.packages = [ waycal ];
}
