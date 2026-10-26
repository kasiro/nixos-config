# AGENTS.md — инструкции для AI-агентов

Репозиторий: декларативная конфигурация NixOS для машины `kasiro`
(хост `nixos`, `x86_64-linux`, Intel i5-4430, NVIDIA GTX 950 / legacy_580, HDD + zram).

## Назначение и стек

- Flake `nixosConfigurations.nixos` на `nixos-26.05`; входы: `home-manager` (release-26.05),
  `nixpkgs-unstable`, `nixGL`, `nix-flatpak`, `chaotic`.
- NixOS-модули (`modules/`) + home-manager для двух пользователей: `kasiro` и `whitepeach`.
- DE/WM: GNOME + GDM, SwayFX (форк `swayfx-enhanced` 0.5.3, собран в `pkgs/`), COSMIC.
  Qtile присутствует, но **отключён** (исключён в `modules/default.nix`).
- Overlay подменяет `opencode` и `cosmic-session` на unstable-версии.
- Секретов в репозитории нет: sops/agenix/disko/impermanence **не используются**.

## Карта репозитория

| Путь | Назначение |
| --- | --- |
| `flake.nix` | Входы и сборка `nixosConfigurations.nixos`; подключение home-manager, overlays |
| `configuration.nix` | Точка входа: только `imports` (`modules`, `users`) и `stateVersion` |
| `modules/` | Системные модули; `default.nix` автоимпортирует всё, кроме `qtile` |
| `modules/desktop/` | GNOME, Sway (пакет/сессия), COSMIC |
| `modules/hardware/` | NVIDIA, audio, bluetooth, `hardware-configuration.nix` (генерируемый) |
| `modules/system/` | Nix-настройки, boot, сеть, locale, пакеты, zram, fish, окружение |
| `modules/security/` | doas (nopass для wheel), PAM, общий security-модуль |
| `modules/services/` | Docker, flatpak, firefox, steam, qbittorrent, ydotool, happ; `lantern`/`system76-scheduler` отключены |
| `modules/qtile/` | Qtile-конфиг на Python; не импортируется |
| `users/` | `kasiro.nix`, `whitepeach.nix`; `users.mutableUsers = false` |
| `home/kasiro/` | HM-конфиг: `desktop/{gnome,sway}`, `programs/`, `shell/`, `fish.nix` |
| `home/whitepeach/` | HM-конфиг второго пользователя |
| `home/common/` | Общие HM-модули: база пользователя, lantern, сброс GNOME-прокси |
| `themes/` | `theme.nix` на пользователя: курсор, акцент, шрифт |
| `pkgs/` | Деривации форков `swayfx-enhanced` и `scenefx-enhanced` |
| `overlays/` | `swayfx-enhanced.nix` — подключает оба форка |
| `scripts/` | `rebuild.py`, `hash-sync.py`/`hash-build.py` (SRI), `info.py`, `cache.json` |
| `.opencode/` | Локальные настройки OpenCode (`package.json`, `memory/`) |
| `install.sh` | Разворачивание на новой машине (клон, генерация hardware-config, switch) |

## Команды

```bash
# Синтаксис одного файла (быстро, без eval)
nix-instantiate --parse modules/system/nix-settings.nix

# Проверка существования опций (eval, без сборки)
nix flake check --no-build

# Пересборка — ТОЛЬКО так, без флагов
python scripts/rebuild.py

# Проверка SRI-хешей в pkgs/ и прочих nix-файлах
python scripts/hash-sync.py --check

# Конвертация base32 → SRI (при ошибке длины хеша)
nix hash convert --hash-algo sha256 --to sri <base32>
```

`scripts/rebuild.py` сам делает: commit → `nh os switch . --log-format bar` → push
(push только при успешной сборке). Prehook `flake_check` в нём отключён.

## Правила работы агента

1. Править **только запрошенное**. Никаких «улучшений на всякий случай», рефакторингов
   и переименований соседних файлов.
2. Перед применением опции проверять, что она существует в текущей ветке nixpkgs
   (`nix flake check --no-build`), а не по памяти. В NixOS 26.05 часть опций удалена
   (например, `services.xserver.windowManager.qtile.backend`, `gdm.wayland`).
3. Соблюдать стиль файла: комментарии по-русски, автоимпорт через `default.nix`
   (новый `.nix` в сканируемой папке подхватится сам; `scripts/` и `default.nix` — нет).
4. Новый файл должен быть добавлен в git (`git add`), иначе flake его не увидит.
5. После правки показывать `git diff` и объяснять изменение; rebuild запускает сэр.

## Грабли

- **Nerd-font глифы.** В конфигах есть private-use символы (например `format-icons`
  в `home/kasiro/desktop/sway/waybar/waybar.nix`). При `edit` они могут выпасть из
  строки — всегда проверять `git diff` на изменения соседних строк.
- **`systemd.services.*.serviceConfig`.** Переопределение полей, заданных nixpkgs
  по умолчанию, требует `lib.mkForce` (иначе конфликт типов/значений). Сначала
  смотреть соответствующий модуль nixpkgs.
- **`checkConfig = false`.** В `home/kasiro/desktop/sway/core.nix` отключена проверка
  конфига Sway: невалидные xkb-опции (например `grp:shift_alt_toggle` вместо
  `grp:alt_shift_toggle`) проходят молча, ошибка видна только в рантайме.
- **SRI-хеши.** `length 39 != expected length 32` = base32-хеш с префиксом `sha256-`.
  Чинить через `nix hash convert`, а не пересчётом сети. `scripts/cache.json` кэширует
  URL→hash.
- **`hardware-configuration.nix`** генерируется `nixos-generate-config`; `install.sh`
  его удаляет и создаёт заново. Ручные правки будут потеряны.
- **`modules/default.nix` игнорирует `qtile`**, `modules/services/default.nix` —
  `lantern` и `system76-scheduler.nix`. Включение = правка `ignored` + импорт.
- **flatpak** (`enable = false`) и **docker** (`enableOnBoot = false`) настроены, но
  выключены/не стартуют автоматически — не «чинить» это без запроса.
- **`README.md` в `.gitignore`**, а `AGETNS.md` — пустой файл с опечаткой в имени.
  Не переименовывать и не удалять.

## Что НЕ делать

- Не запускать `nixos-rebuild`, `nh`, `install.sh` — пересборку делает сэр
  (единственное исключение — `python scripts/rebuild.py`).
- Не коммитить и не пушить вручную: это делает `rebuild.py`.
- Не менять `system.stateVersion` / `home.stateVersion` (`26.05`).
- Не включать отключённые модули (qtile, lantern, system76-scheduler, flatpak, docker)
  и не менять `users.mutableUsers = false` без явного запроса.
- Не удалять и не переименовывать `AGETNS.md`, не трогать `.opencode/` и `themes/`
  вне задачи.
- Не добавлять секреты в репозиторий: пароли хранятся только как `hashedPassword`.
