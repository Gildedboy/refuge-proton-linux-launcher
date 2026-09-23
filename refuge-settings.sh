#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$GAME_DIR/refuge-proton-common.sh" ]]; then
    printf 'Falta el helper de Proton: %s\n' "$GAME_DIR/refuge-proton-common.sh" >&2
    exit 1
fi
source "$GAME_DIR/refuge-proton-common.sh"
refuge_require_files "$GAME_DIR/opensetup.exe" "$GAME_DIR/savedata/OptionInfo.lua"
if [[ ! -d "$GAME_DIR/savedata" || ! -w "$GAME_DIR/savedata" ]]; then
    printf 'No existe savedata o no tengo permiso para guardar las opciones: %s\n' \
        "$GAME_DIR/savedata" >&2
    exit 1
fi
refuge_prepare_proton
refuge_set_registry_path

cd "$GAME_DIR"
exec "$REFUGE_PROTON_RUNNER" run "$GAME_DIR/opensetup.exe" "$@"
