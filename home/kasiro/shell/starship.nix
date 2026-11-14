# Starship — промпт
#
# ВАЖНО: programs.starship.settings намеренно НЕ задаётся. HM при непустых
# settings генерирует ~/.config/starship.toml как симлинк в /nix/store,
# из-за чего шаблон noctalia «starship» не может писать в файл в рантайме.
# При settings = {} HM файл не генерирует вообще
# (hasGeneratedConfig = settings != {} || presets != []), поэтому базовый
# конфиг сеет активация starshipSeed ниже: она гарантирует, что после
# переключения ~/.config/starship.toml — обычный файл, но не перезатирает
# его содержимое (в том числе правки шаблона noctalia) после первого сидирования.
# Starship — промпт под управлением Nix
# Конфиг задаётся в home/kasiro/desktop/hyprland.nix
{ ... }:
{
  # Пустой файл — конфигурация перенесена в hyprland.nix
}
