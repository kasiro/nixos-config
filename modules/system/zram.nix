# zram swap (основной swap системы)
{ ... }:
{
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
    priority = 5;
  };

  # Для работы lz4 в zram необходим systemd в initrd
  boot.initrd.systemd.enable = true;

  # Оптимизация ядра под zram
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };
}
