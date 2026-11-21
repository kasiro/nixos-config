# Ограничение журнала: меньше записи и fsync на HDD
{ ... }:
{
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    Compress=yes
    SyncIntervalSec=15min
  '';
}
