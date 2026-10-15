{pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
    };
    commandLineArgs = [
      "--enable-features=AcceleratedVideoEncoder,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
      "--enable-features=VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport"
      "--enable-features=UseMultiPlaneFormatForHardwareVideo"
      "--ignore-gpu-blocklist"
      "--enable-zero-copy"
      "--password-store=basic"
    ];
    extensions = [
      { id = "majdfhpaihoncoakbjgbdhglocklcgno"; } # vpn
      # { id = "nbhcbdghjpllgmfilhnhkllmkecfmpld"; } # js and css inject
      { id = "hkgfoiooedgoejojocmhlaklaeopbecg"; } # picture in picture
      # { id = "jephanpkonkmnkekmlkcijdjgniikppl"; } # vknext
      { id = "gighmmpiobklfepjocnamgkkbiglidom"; } # adblock
    ];
  };
}
#
