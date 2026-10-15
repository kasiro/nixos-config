#!/usr/bin/env bash
# install.sh — разворачивает NixOS-конфиг и запускает nixos-rebuild switch.
# Запускать ОТ ОБЫЧНОГО ПОЛЬЗОВАТЕЛЯ (не через sudo) — pkexec сам поднимет права.
set -euo pipefail

# ------------------------------- настройки -------------------------------
# ⚠️ поменяй на свой реальный репозиторий (или передавай через env REPO_URL=...)
REPO_URL="${REPO_URL:-https://github.com:kasiro/nixos-config}"
TARGET_DIR="${TARGET_DIR:-$HOME/nixos-config}"
FLAKE_ATTR="${FLAKE_ATTR:-nixos}"
HWD_REL="modules/hardware/hardware-configuration.nix"
# -------------------------------------------------------------------------

echo "==> Repo URL:   $REPO_URL"
echo "==> Target dir: $TARGET_DIR"
echo "==> Flake attr: $FLAKE_ATTR"
echo

# --- 1. Клонирование конфига ---------------------------------
if [ -d "$TARGET_DIR/.git" ]; then
  echo "==> [$TARGET_DIR] уже существует, пропускаю..."
else
  echo "==> Клонирую $REPO_URL -> $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"

# --- 2. Удаление старого hardware-configuration.nix -----------------------
HWD_PATH="$TARGET_DIR/$HWD_REL"
if [ -f "$HWD_PATH" ]; then
  echo "==> Удаляю старый $HWD_REL"
  rm -f "$HWD_PATH"
fi

# --- 3. Генерация нового hardware-configuration.nix -----------------------
echo "==> Генерирую новый $HWD_REL"
nix-shell -p nixos-install-tools --run "nixos-generate-config --show-hardware-config" > "$HWD_PATH"

# Флейки видят только те файлы, что добавлены в git — иначе nixos-rebuild
# скажет "path '...' is not tracked by Git".
git add .

# --- 4. Установка ---------------------------------------------------------
echo
echo "==> nixos-rebuild switch (flake: $TARGET_DIR#$FLAKE_ATTR)"
echo

# exec — чтобы pkexec получил stdin/stdout напрямую и мы видели весь вывод
exec nix-shell -p pkexec --run "pkexec nixos-rebuild switch --flake $TARGET_DIR#$FLAKE_ATTR --show-trace"
