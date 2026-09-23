#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$GAME_DIR/refuge-proton-common.sh"
refuge_prepare_proton
refuge_set_registry_path

cd "$GAME_DIR"

LOG="$GAME_DIR/linux-launch.log"
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
