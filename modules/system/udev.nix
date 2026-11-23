# Планировщик I/O для вращающегося диска
{ ... }:
{
  services.udev.extraRules = ''
    # bfq для HDD (отзывчивость десктопа под смешанной нагрузкой)
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
}
