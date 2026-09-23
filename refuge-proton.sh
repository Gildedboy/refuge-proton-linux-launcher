#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$GAME_DIR/refuge-proton-common.sh" ]]; then
    printf 'Falta el helper de Proton: %s\n' "$GAME_DIR/refuge-proton-common.sh" >&2
    exit 1
fi
source "$GAME_DIR/refuge-proton-common.sh"
refuge_require_files "$GAME_DIR/PRM.exe" "$GAME_DIR/prm-laa.py"
if [[ ! -w "$GAME_DIR" ]]; then
    printf 'No tengo permiso para escribir en la carpeta del cliente: %s\n' "$GAME_DIR" >&2
    exit 1
fi
if [[ ! -w "$GAME_DIR/PRM.exe" ]]; then
    printf 'No tengo permiso para actualizar PRM.exe: %s\n' "$GAME_DIR/PRM.exe" >&2
    exit 1
fi
refuge_prepare_proton
refuge_set_registry_path

cd "$GAME_DIR"
python3 "$GAME_DIR/prm-laa.py" "$GAME_DIR/PRM.exe"
exec "$REFUGE_PROTON_RUNNER" run "$GAME_DIR/PRM.exe" 1rag1 "$@"
