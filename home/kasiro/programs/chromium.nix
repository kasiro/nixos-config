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
      { id = "omghfjlpggmjjaagoclmmobgdodcjboh"; } # vpn
      { id = "nbhcbdghjpllgmfilhnhkllmkecfmpld"; } # js and css inject
      { id = "hkgfoiooedgoejojocmhlaklaeopbecg"; } # picture in picture
      { id = "jephanpkonkmnkekmlkcijdjgniikppl"; } # vknext
      { id = "gighmmpiobklfepjocnamgkkbiglidom"; } # adblock
    ];
  };
}
#
