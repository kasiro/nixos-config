# Опции монтирования корня: меньше записей и реже fsync на HDD
#
# Без lib.mkForce: в modules/hardware/hardware-configuration.nix для "/"
# заданы только device и fsType, атрибут options отсутствует, поэтому
# объявление options здесь не конфликтует (это единственное место, где
# options для "/" задаётся; /boot не трогаем).
{ ... }:
{
  fileSystems."/".options = [ "rw" "noatime" "commit=60" ];
}
