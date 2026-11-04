{pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
    };
    commandLineArgs = [
      "--ozone-platform=wayland"      # Нативный Wayland (не XWayland)
      "--password-store=basic"         # Хранилище паролей v10, независимо от keyring
    ];
    extensions = [
      { id = "majdfhpaihoncoakbjgbdhglocklcgno"; } # vpn
      { id = "hkgfoiooedgoejojocmhlaklaeopbecg"; } # picture in picture
      { id = "gighmmpiobklfepjocnamgkkbiglidom"; } # adblock
    ];
  };
}
#
