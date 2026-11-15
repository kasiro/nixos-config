#!/usr/bin/env bash
# install.sh — разворачивает NixOS-конфиг и переключает систему.
# Запускать от обычного пользователя; права поднимает sudo/doas.
set -euo pipefail

[ -f /etc/NIXOS ] || { echo "❌ Это не NixOS"; exit 1; }

REPO_URL="${REPO_URL:-https://github.com/kasiro/nixos-config}"
TARGET_DIR="${TARGET_DIR:-$HOME/nixos-config}"
FLAKE_ATTR="${FLAKE_ATTR:-nixos}"
HWD_PATH="$TARGET_DIR/modules/hardware/hardware-configuration.nix"

# Флейки нужны ДО первого switch — в конфиге они включатся только после.
FLAKES="experimental-features = nix-command flakes"

# Чем поднимать права: pkexec из nix-shell не setuid, на него не полагаемся.
if [ "$(id -u)" -eq 0 ]; then
  ROOT=(env)
elif command -v sudo >/dev/null 2>&1; then
  ROOT=(sudo env)
elif command -v doas >/dev/null 2>&1; then
  ROOT=(doas env)
else
  echo "❌ Нет ни sudo, ни doas — запусти от root"; exit 1
fi

# --- 1. Репозиторий -------------------------------------------------------
if [ -d "$TARGET_DIR/.git" ]; then
  echo "==> [$TARGET_DIR] уже репозиторий, пропускаю клон"
elif [ -e "$TARGET_DIR" ]; then
  echo "❌ $TARGET_DIR существует и не является git-репозиторием"; exit 1
else
  git clone "$REPO_URL" "$TARGET_DIR"
fi
cd "$TARGET_DIR"

# --- 2. hardware-configuration -------------------------------------------
# Генерим во временный файл: прямой `> "$HWD_PATH"` обрезал бы старый конфиг
# ещё до запуска генератора, и при ошибке остался бы пустышка без fileSystems.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

"${ROOT[@]}" NIX_CONFIG="$FLAKES" \
  nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#nixos-install-tools \
  -c nixos-generate-config --show-hardware-config > "$tmp"

[ -s "$tmp" ] || { echo "❌ генератор вернул пустой hardware-config"; exit 1; }
grep -q 'fileSystems' "$tmp" || { echo "❌ в hardware-config нет fileSystems"; exit 1; }

mv "$tmp" "$HWD_PATH"
trap - EXIT
echo "==> $HWD_PATH обновлён"

# Флейки видят только отслеживаемые файлы.
git add .

# --- 3. Проверка ДО переключения -----------------------------------------
# Полный eval: ловит несуществующие опции за минуты, а не на середине сборки.
echo "==> eval конфигурации"
nix --extra-experimental-features 'nix-command flakes' \
  eval ".#nixosConfigurations.$FLAKE_ATTR.config.system.build.toplevel.drvPath" \
  --raw >/dev/null

# --- 4. Переключение ------------------------------------------------------
exec "${ROOT[@]}" NIX_CONFIG="$FLAKES" nixos-rebuild switch --flake "$TARGET_DIR#$FLAKE_ATTR" --show-trace
