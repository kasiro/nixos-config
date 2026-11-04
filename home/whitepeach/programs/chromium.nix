{pkgs, ... }: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium.override {
      enableWideVine = true;
    };
    commandLineArgs = [
      "--enable-features=AcceleratedVideoEncoder,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
      "--enable-features=PlatformHEVCDecoderSupport"
      "--enable-features=UseMultiPlaneFormatForHardwareVideo"
      "--ignore-gpu-blocklist"
      "--enable-zero-copy"
      "--password-store=basic"
    ];
    extensions = [
      { id = "majdfhpaihoncoakbjgbdhglocklcgno"; } # vpn
      { id = "hkgfoiooedgoejojocmhlaklaeopbecg"; } # picture in picture
      { id = "gighmmpiobklfepjocnamgkkbiglidom"; } # adblock
    ];
  };
}
#
