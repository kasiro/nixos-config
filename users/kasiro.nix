{ pkgs, ... }: {
  users.users.kasiro = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "kasiro";
    hashedPassword = "$y$j9T$b5Hk77A2sE.2U.qmTfO7o0$96GzeLnCLNnsr7Ib8BlJl3z5qsOIuTvdck2ORLbmzZC";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "uinput"
      "adbusers"
    ];
  };
}
