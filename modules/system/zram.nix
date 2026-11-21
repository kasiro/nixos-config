# zram swap (основной swap системы)
{ ... }:
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 75;
    priority = 100;
  };

  # Для работы zram в initrd необходим systemd
  boot.initrd.systemd.enable = true;

  # Оптимизация ядра под zram + медленный HDD
  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    # Dirty ratio tuning: меньше длинных stall при flush на HDD
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 15;
    "vm.dirty_expire_centisecs" = 3000;
  };
}
