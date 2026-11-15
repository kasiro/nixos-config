# Видеокарта NVIDIA GTX 950 (Maxwell)
{ config, pkgs, lib, ... }:
{
  # Графический стек
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Драйвер NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Maxwell старше Turing → открытые модули не поддерживаются
    open = false;
    branch = "legacy_580";

    # Legacy-ветка, последняя с поддержкой Maxwell
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # Modesetting рекомендуется для корректной работы
    modesetting.enable = true;
    nvidiaSettings = true;


    # Управление питанием
    powerManagement.enable = true;
  };

  # Фикс phantom displays: fbdev-бэкенд для nvidia_drm
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
}
