#!/usr/bin/env bash

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

    export STEAM_COMPAT_DATA_PATH="${STEAM_COMPAT_DATA_PATH:-$GAME_DIR/.protonprefix}"
    export STEAM_COMPAT_APP_ID="${STEAM_COMPAT_APP_ID:-0}"
    export PROTON_D7VK_DDRAW=1
}

refuge_set_registry_path() {
    local windows_path
    windows_path="$("$REFUGE_PROTON_RUNNER" getcompatpath "$GAME_DIR")"

    "$REFUGE_PROTON_RUNNER" runinprefix reg add 'HKCU\Software\Gravity\RagnarokOnline' \
        /ve /t REG_SZ /d "${windows_path}\\" /f >/dev/null
    "$REFUGE_PROTON_RUNNER" runinprefix reg add 'HKCU\Software\Gravity\RagnarokOnline' \
        /v RagPath /t REG_SZ /d "${windows_path}\\" /f >/dev/null
    "$REFUGE_PROTON_RUNNER" runinprefix reg add 'HKCU\Software\Gravity\RagnarokOnline' \
        /v SakrayPath /t REG_SZ /d "${windows_path}\\" /f >/dev/null
}
