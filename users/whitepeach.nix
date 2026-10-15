{ config, pkgs, lib, ... }: {
  users.users.whitepeach = {
      isNormalUser = true;
      description = "whitepeach";
      extraGroups = [ "networkmanager" "wheel" ];
      hashedPassword = "$y$j9T$3Hb3C3okNXpoNOkfrupNU/$qot2QMsKAVfGhGUF/Z3DF1SdiiHcvkXlLI4sI/ceodD";
  };
}
