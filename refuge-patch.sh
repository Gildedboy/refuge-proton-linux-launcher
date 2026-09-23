#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$GAME_DIR/refuge-proton-common.sh" ]]; then
    printf 'Falta el helper de Proton: %s\n' "$GAME_DIR/refuge-proton-common.sh" >&2
    exit 1
fi
source "$GAME_DIR/refuge-proton-common.sh"
refuge_require_files \
    "$GAME_DIR/PRM.exe" \
    "$GAME_DIR/_RefugePatcher.exe" \
    "$GAME_DIR/prm-laa.py"
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

LOG="$GAME_DIR/linux-launch.log"
if [[ -e "$LOG" && ! -w "$LOG" ]]; then
    printf 'No tengo permiso para escribir el registro: %s\n' "$LOG" >&2
    exit 1
fi
python3 "$GAME_DIR/prm-laa.py" "$GAME_DIR/PRM.exe" >>"$LOG" 2>&1

# Keep LAA enabled if the patcher replaces PRM.exe before launching the client.
"$REFUGE_PROTON_RUNNER" run "$GAME_DIR/_RefugePatcher.exe" "$@" >>"$LOG" 2>&1 &
PATCHER_PID=$!
PREVIOUS=""
STABLE_POLLS=0
LAST_TRIED=""
while kill -0 "$PATCHER_PID" 2>/dev/null; do
    CURRENT="$(stat -c '%i:%s:%Y' "$GAME_DIR/PRM.exe" 2>/dev/null || true)"
    if [[ -n "$CURRENT" && "$CURRENT" == "$PREVIOUS" ]]; then
        STABLE_POLLS=$((STABLE_POLLS + 1))
    else
        STABLE_POLLS=0
        PREVIOUS="$CURRENT"
    fi
    if [[ -n "$CURRENT" && "$STABLE_POLLS" -ge 5 && "$CURRENT" != "$LAST_TRIED" ]]; then
        python3 "$GAME_DIR/prm-laa.py" "$GAME_DIR/PRM.exe" >>"$LOG" 2>&1 || true
        LAST_TRIED="$CURRENT"
    fi
    sleep 0.2
done
wait "$PATCHER_PID" || PATCHER_STATUS=$?
PATCHER_STATUS="${PATCHER_STATUS:-0}"
python3 "$GAME_DIR/prm-laa.py" "$GAME_DIR/PRM.exe" >>"$LOG" 2>&1 || true
exit "$PATCHER_STATUS"
