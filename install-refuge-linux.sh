#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

if [[ $# -ne 1 ]]; then
    printf 'Uso: %s /ruta/a/Refuge-Linux\n' "$0" >&2
    exit 2
fi

if [[ ! -d "$1" ]]; then
    printf 'No existe la carpeta indicada: %s\n' "$1" >&2
    exit 1
fi
GAME_DIR="$(cd -- "$1" && pwd -P)"
for required in PRM.exe _RefugePatcher.exe opensetup.exe; do
    if [[ ! -f "$GAME_DIR/$required" ]]; then
        printf 'No encuentro %s en %s\n' "$required" "$GAME_DIR" >&2
        printf 'Indica la carpeta raíz del cliente Refuge.\n' >&2
        exit 1
    fi
done
if [[ ! -w "$GAME_DIR" ]]; then
    printf 'No tengo permiso para instalar scripts en: %s\n' "$GAME_DIR" >&2
    exit 1
fi

files=(
    refuge.sh
    refuge-patch.sh
    refuge-settings.sh
    refuge-proton.sh
    refuge-proton-common.sh
    install-linux-shortcuts.sh
    prm-laa.py
)

for file in "${files[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
        printf 'El paquete está incompleto; falta %s. No hice cambios.\n' "$file" >&2
        exit 1
    fi
    if [[ -e "$GAME_DIR/$file" && ! -f "$GAME_DIR/$file" ]]; then
        printf 'No puedo instalar porque el destino existe y no es un archivo: %s\n' \
            "$GAME_DIR/$file" >&2
        exit 1
    fi
    destination="$GAME_DIR/$file"
    backup="$destination.before-refuge-proton"
    if [[ -f "$destination" && ! -e "$backup" && ! -r "$destination" ]]; then
        printf 'No puedo respaldar el script existente: %s\n' "$destination" >&2
        exit 1
    fi
    if [[ -e "$backup" && ! -f "$backup" ]]; then
        printf 'La copia de seguridad existente no es un archivo: %s\n' "$backup" >&2
        exit 1
    fi
done

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
APP_WRITABLE="$APP_DIR"
while [[ ! -d "$APP_WRITABLE" ]]; do
    APP_PARENT="$(dirname -- "$APP_WRITABLE")"
    if [[ "$APP_PARENT" == "$APP_WRITABLE" ]]; then
        break
    fi
    APP_WRITABLE="$APP_PARENT"
done
if [[ ! -w "$APP_WRITABLE" ]]; then
    printf 'No tengo permiso para crear accesos en: %s\n' "$APP_WRITABLE" >&2
    exit 1
fi
for desktop_name in return-to-morroc-refuge.desktop return-to-morroc-refuge-settings.desktop; do
    desktop_file="$APP_DIR/$desktop_name"
    if [[ -e "$desktop_file" && ! -f "$desktop_file" ]]; then
        printf 'El destino del acceso no es un archivo regular: %s\n' "$desktop_file" >&2
        exit 1
    fi
    if [[ -f "$desktop_file" && ! -w "$desktop_file" ]]; then
        printf 'No tengo permiso para actualizar el acceso: %s\n' "$desktop_file" >&2
        exit 1
    fi
    backup="$desktop_file.before-refuge-proton"
    if [[ -f "$desktop_file" && ! -r "$desktop_file" && ! -e "$backup" ]]; then
        printf 'No puedo respaldar el acceso existente: %s\n' "$desktop_file" >&2
        exit 1
    fi
    if [[ -e "$backup" && ! -f "$backup" ]]; then
        printf 'La copia de seguridad del acceso no es un archivo: %s\n' "$backup" >&2
        exit 1
    fi
done

for command_name in install cp chmod dirname mkdir; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Falta el comando necesario: %s. No hice cambios.\n' "$command_name" >&2
        exit 1
    fi
done

source "$SCRIPT_DIR/refuge-proton-common.sh"
refuge_prepare_proton

mkdir -p "$APP_DIR"
for desktop_name in return-to-morroc-refuge.desktop return-to-morroc-refuge-settings.desktop; do
    desktop_file="$APP_DIR/$desktop_name"
    backup="$desktop_file.before-refuge-proton"
    if [[ -f "$desktop_file" && ! -e "$backup" ]]; then
        cp -p -- "$desktop_file" "$backup"
    fi
done

for file in "${files[@]}"; do
    destination="$GAME_DIR/$file"
    backup="$destination.before-refuge-proton"
    if [[ -f "$destination" && ! -e "$backup" ]]; then
        cp -p -- "$destination" "$backup"
    fi
done

for file in "${files[@]}"; do
    install -m 0644 "$SCRIPT_DIR/$file" "$GAME_DIR/$file"
done

chmod +x \
    "$GAME_DIR/refuge.sh" \
    "$GAME_DIR/refuge-patch.sh" \
    "$GAME_DIR/refuge-settings.sh" \
    "$GAME_DIR/refuge-proton.sh" \
    "$GAME_DIR/install-linux-shortcuts.sh"

bash "$GAME_DIR/install-linux-shortcuts.sh"
printf 'Instalación lista. Abre “Return to Morroc: Refuge” desde Aplicaciones.\n'
