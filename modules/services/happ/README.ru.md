# happ-nixos

[English](README.md) | Русский

> Запуск прокси-клиента [Happ](https://github.com/Happ-proxy/happ-desktop) на NixOS — с нормальной упаковкой и рабочим HWID.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-x86__64--linux-success)

Happ распространяется в виде готового Debian-пакета, который рассчитывает на
обычную FHS-раскладку и доступный для записи `/opt/happ` — ничего из этого на
NixOS нет. Этот модуль переупаковывает клиент для Nix store и настраивает всё
необходимое для его чистой работы, включая **фикс HWID**, который обычный
`.deb` не может обеспечить на современном NixOS.

## Возможности

- 📦 **Нативная упаковка под Nix** — autoPatchelf + обёртка Qt, без FHS-хаков
- 🔑 **Рабочий HWID** — восстанавливает device id, который dbus-broker оставляет пустым
- 🛡️ **Готовность к TUN-режиму** — firewall, модуль `tun` и root-демон управления
- ⚡ **Быстрые пересборки** — `/opt/happ` обновляется только при изменении пакета

## Установка

Склонируйте в `/etc/nixos`:

```bash
cd /etc/nixos
sudo git clone https://github.com/MrShitFox/happ-nixos
