#!/usr/bin/env bash
set -euo pipefail

GAME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
for required in PRM.exe _RefugePatcher.exe opensetup.exe refuge.sh refuge-settings.sh; do
    if [[ ! -f "$GAME_DIR/$required" ]]; then
        printf 'No instalé los accesos: falta %s en %s\n' "$required" "$GAME_DIR" >&2
        exit 1
    fi
done
for launcher in refuge.sh refuge-settings.sh; do
    if [[ ! -x "$GAME_DIR/$launcher" ]]; then
        printf 'No instalé los accesos: %s no es ejecutable. Ejecuta chmod +x %s\n' \
            "$GAME_DIR/$launcher" "$GAME_DIR/$launcher" >&2
        exit 1
    fi
done

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
if [[ -e "$APP_DIR" && ! -d "$APP_DIR" ]]; then
    printf 'La ruta de aplicaciones existe y no es una carpeta: %s\n' "$APP_DIR" >&2
    exit 1
fi
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

desktop_files=(
    "$APP_DIR/return-to-morroc-refuge.desktop"
    "$APP_DIR/return-to-morroc-refuge-settings.desktop"
)
for desktop_file in "${desktop_files[@]}"; do
    if [[ -e "$desktop_file" && ! -f "$desktop_file" ]]; then
        printf 'No puedo reemplazar el acceso porque no es un archivo regular: %s\n' \
            "$desktop_file" >&2
        exit 1
    fi
    if [[ -f "$desktop_file" && ! -w "$desktop_file" ]]; then
        printf 'No tengo permiso para reemplazar el acceso: %s\n' "$desktop_file" >&2
        exit 1
    fi
    if [[ -f "$desktop_file" && ! -r "$desktop_file" && ! -e "$desktop_file.before-refuge-proton" ]]; then
        printf 'No puedo respaldar el acceso existente: %s\n' "$desktop_file" >&2
        exit 1
    fi
    if [[ -e "$desktop_file.before-refuge-proton" && ! -f "$desktop_file.before-refuge-proton" ]]; then
        printf 'La copia de seguridad del acceso no es un archivo regular: %s\n' \
            "$desktop_file.before-refuge-proton" >&2
        exit 1
    fi
done

mkdir -p "$APP_DIR"
for desktop_file in "${desktop_files[@]}"; do
    if [[ -f "$desktop_file" && ! -e "$desktop_file.before-refuge-proton" ]]; then
        cp -p -- "$desktop_file" "$desktop_file.before-refuge-proton"
    fi
done

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
