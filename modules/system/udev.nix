# Планировщик I/O и readahead для вращающегося диска
{ ... }:
{
  services.udev.extraRules = ''
    # bfq для HDD (отзывчивость десктопа под смешанной нагрузкой)
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

    # readahead 1024 KB для sda (HDD)
    ACTION=="add|change", KERNEL=="sda", ATTR{queue/read_ahead_kb}="1024"
  '';
}
