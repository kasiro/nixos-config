{pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
    };
    commandLineArgs = [
      # Оставить только Vaapi для видео + Wayland
      "--enable-features=VaapiOnNvidiaGPUs,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseOzonePlatform"
      "--ozone-platform=wayland"
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
