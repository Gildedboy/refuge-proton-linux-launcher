#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$GAME_DIR/refuge-patch.sh" || ! -x "$GAME_DIR/refuge-patch.sh" ]]; then
    printf 'Falta el lanzador del parcheador o no es ejecutable: %s\n' "$GAME_DIR/refuge-patch.sh" >&2
    exit 1
fi
exec "$GAME_DIR/refuge-patch.sh" "$@"
