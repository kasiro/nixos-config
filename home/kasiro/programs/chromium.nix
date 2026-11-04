{pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
    };
    commandLineArgs = [
      "--enable-features=PlatformHEVCDecoderSupport,UseOzonePlatform"
      "--ozone-platform=wayland"
      # Хранилище паролей v10, независимое от gnome-keyring — иначе старые v11-пароли не расшифровываются в Sway
      "--password-store=basic"
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
