#!/usr/bin/env bash

refuge_require_files() {
    local file
    for file in "$@"; do
        if [[ ! -f "$file" ]]; then
            printf 'Falta un archivo necesario: %s\n' "$file" >&2
            return 1
        fi
    done
}

refuge_find_proton_runner() {
    local candidate

    if [[ -n "${REFUGE_PROTON_RUNNER:-}" ]]; then
        if [[ -x "$REFUGE_PROTON_RUNNER" ]]; then
            printf '%s\n' "$REFUGE_PROTON_RUNNER"
            return 0
        fi
        printf 'REFUGE_PROTON_RUNNER no es ejecutable: %s\n' "$REFUGE_PROTON_RUNNER" >&2
        return 1
    fi

    for candidate in \
        /usr/share/steam/compatibilitytools.d/proton-cachyos-slr/proton \
        "$HOME/.local/share/Steam/compatibilitytools.d/proton-cachyos-slr/proton" \
        "$HOME/.steam/root/compatibilitytools.d/proton-cachyos-slr/proton" \
        "$HOME/.steam/steam/compatibilitytools.d/proton-cachyos-slr/proton"; do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    cat >&2 <<'EOF'
No encontré Proton CachyOS SLR. Instálalo con Steam/CachyOS o define
REFUGE_PROTON_RUNNER con la ruta al ejecutable proton de esa herramienta.
EOF
    return 1
}

refuge_prepare_proton() {
    local writable_parent
    if [[ -z "${GAME_DIR:-}" || ! -d "$GAME_DIR" ]]; then
        printf 'No existe la carpeta del cliente: %s\n' "${GAME_DIR:-<no definida>}" >&2
        return 1
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        printf 'Falta Python 3. Instálalo antes de iniciar Refuge.\n' >&2
        return 1
    fi

    REFUGE_PROTON_RUNNER="$(refuge_find_proton_runner)"
    export REFUGE_PROTON_RUNNER

    if [[ -z "${STEAM_COMPAT_CLIENT_INSTALL_PATH:-}" ]]; then
        local steam_root
        for steam_root in \
            "$HOME/.local/share/Steam" \
            "$HOME/.steam/root" \
            "$HOME/.steam/steam"; do
            if [[ -d "$steam_root/steamapps" ]]; then
                export STEAM_COMPAT_CLIENT_INSTALL_PATH="$steam_root"
                break
            fi
        done
    fi

    if [[ -z "${STEAM_COMPAT_CLIENT_INSTALL_PATH:-}" ]]; then
        printf 'No encontré la biblioteca de Steam; define STEAM_COMPAT_CLIENT_INSTALL_PATH.\n' >&2
        return 1
    fi
    if [[ ! -d "$STEAM_COMPAT_CLIENT_INSTALL_PATH/steamapps" ]]; then
        printf 'La ruta de Steam no contiene steamapps: %s\n' "$STEAM_COMPAT_CLIENT_INSTALL_PATH" >&2
        return 1
    fi

    export STEAM_COMPAT_DATA_PATH="${STEAM_COMPAT_DATA_PATH:-$GAME_DIR/.protonprefix}"
    export STEAM_COMPAT_APP_ID="${STEAM_COMPAT_APP_ID:-0}"
    export PROTON_D7VK_DDRAW=1

    if [[ -e "$STEAM_COMPAT_DATA_PATH" ]]; then
        if [[ ! -d "$STEAM_COMPAT_DATA_PATH" || ! -w "$STEAM_COMPAT_DATA_PATH" ]]; then
            printf 'La ruta del prefijo existe pero no es una carpeta escribible: %s\n' \
                "$STEAM_COMPAT_DATA_PATH" >&2
            return 1
        fi
    else
        writable_parent="$(dirname -- "$STEAM_COMPAT_DATA_PATH")"
        while [[ ! -d "$writable_parent" ]]; do
            local next_parent
            next_parent="$(dirname -- "$writable_parent")"
            if [[ "$next_parent" == "$writable_parent" ]]; then
                break
            fi
            writable_parent="$next_parent"
        done
        if [[ ! -w "$writable_parent" ]]; then
            printf 'No tengo permiso para crear el prefijo Proton en: %s\n' \
                "$STEAM_COMPAT_DATA_PATH" >&2
            return 1
        fi
    fi
}

refuge_set_registry_path() {
    local windows_path
    refuge_require_files "$GAME_DIR/PRM.exe" "$GAME_DIR/_RefugePatcher.exe" "$GAME_DIR/opensetup.exe"
    if [[ ! -x "$REFUGE_PROTON_RUNNER" ]]; then
        printf 'El ejecutable Proton ya no está disponible: %s\n' "$REFUGE_PROTON_RUNNER" >&2
        return 1
    fi
    windows_path="$("$REFUGE_PROTON_RUNNER" getcompatpath "$GAME_DIR")"
    if [[ -z "$windows_path" ]]; then
        printf 'Proton no pudo convertir la ruta del cliente a una ruta Windows.\n' >&2
        return 1
    fi

    "$REFUGE_PROTON_RUNNER" runinprefix reg add 'HKCU\Software\Gravity\RagnarokOnline' \
        /ve /t REG_SZ /d "${windows_path}\\" /f >/dev/null
    "$REFUGE_PROTON_RUNNER" runinprefix reg add 'HKCU\Software\Gravity\RagnarokOnline' \
        /v RagPath /t REG_SZ /d "${windows_path}\\" /f >/dev/null
    "$REFUGE_PROTON_RUNNER" runinprefix reg add 'HKCU\Software\Gravity\RagnarokOnline' \
        /v SakrayPath /t REG_SZ /d "${windows_path}\\" /f >/dev/null
}
