# Writable fontconfig cache: /var/cache/fontconfig
# GDM greeter падает с "Fontconfig error: No writable cache directories" —
# каталога нет в системе, а $HOME/.cache/fontconfig у gdm-greeter недоступен.
# cachedir уже объявлен в дефолтном fonts.conf пакета fontconfig — дубль не нужен.
{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/cache/fontconfig 1777 root root -"
  ];
}
