#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$GAME_DIR/refuge-proton-common.sh"
refuge_prepare_proton
refuge_set_registry_path

cd "$GAME_DIR"
python3 "$GAME_DIR/prm-laa.py" "$GAME_DIR/PRM.exe"
exec "$REFUGE_PROTON_RUNNER" run "$GAME_DIR/PRM.exe" 1rag1 "$@"
