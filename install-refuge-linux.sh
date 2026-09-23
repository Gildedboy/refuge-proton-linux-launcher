#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -ne 1 ]]; then
    printf 'Uso: %s /ruta/a/Refuge-Linux\n' "$0" >&2
    exit 2
fi

GAME_DIR="$(realpath -e -- "$1")"
for required in PRM.exe _RefugePatcher.exe opensetup.exe; do
    if [[ ! -f "$GAME_DIR/$required" ]]; then
        printf 'No encuentro %s en %s\n' "$required" "$GAME_DIR" >&2
        printf 'Indica la carpeta raíz del cliente Refuge.\n' >&2
        exit 1
    fi
done

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
