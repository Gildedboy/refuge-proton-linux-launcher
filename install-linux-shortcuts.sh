#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$APP_DIR"

desktop_quote() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//\`/\\\`}"
    value="${value//\$/\\\$}"
    printf '"%s"' "$value"
}

GAME_EXEC="$(desktop_quote "$GAME_DIR/refuge.sh")"
SETTINGS_EXEC="$(desktop_quote "$GAME_DIR/refuge-settings.sh")"
GAME_ICON="$GAME_DIR/icons/return-to-morroc-refuge.png"
SETTINGS_ICON="$GAME_DIR/icons/return-to-morroc-refuge-settings.png"
[[ -f "$GAME_ICON" ]] || GAME_ICON="applications-games"
[[ -f "$SETTINGS_ICON" ]] || SETTINGS_ICON="preferences-system"

cat >"$APP_DIR/return-to-morroc-refuge.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Return to Morroc: Refuge
Comment=Actualizar e iniciar Return to Morroc: Refuge con Proton
Exec=$GAME_EXEC
Path=$GAME_DIR
Icon=$GAME_ICON
Terminal=false
Categories=Game;
EOF

cat >"$APP_DIR/return-to-morroc-refuge-settings.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Return to Morroc: Refuge — Settings
Comment=Configurar gráficos y resolución
Exec=$SETTINGS_EXEC
Path=$GAME_DIR
Icon=$SETTINGS_ICON
Terminal=false
Categories=Game;
EOF

chmod +x "$APP_DIR/return-to-morroc-refuge.desktop" \
    "$APP_DIR/return-to-morroc-refuge-settings.desktop"

printf 'Accesos instalados en %s\n' "$APP_DIR"
