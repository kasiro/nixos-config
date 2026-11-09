{inputs, pkgs, ...}: {
  imports = [ inputs.hyprland.nixosModules.default ];
  
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };
  
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  security.polkit.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  # NVIDIA legacy_580 (GTX 950)
  hardware.nvidia = {
    branch = "legacy_580";
    modesetting.enable = true;
    nvidiaSettings = true;
  };
}
