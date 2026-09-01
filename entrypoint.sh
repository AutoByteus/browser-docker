#!/bin/bash
set -eo pipefail

# Create required directories with root
mkdir -p /var/run/supervisor
chmod 755 /var/run/supervisor
chown vncuser:vncuser /var/run/supervisor

# Set runtime directory from the image's configured UID.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${USER_UID:-1000}}"
mkdir -p "${XDG_RUNTIME_DIR}"
mkdir -p "${XDG_RUNTIME_DIR}/dconf"
chown -R vncuser:vncuser "${XDG_RUNTIME_DIR}"
chmod -R 700 "${XDG_RUNTIME_DIR}"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# Ensure mounted Chromium profile volumes are writable by the browser user.
CHROMIUM_PROFILE_DIR="/home/vncuser/.config/chromium"
mkdir -p "${CHROMIUM_PROFILE_DIR}"
chown vncuser:vncuser /home/vncuser/.config
chown -R vncuser:vncuser "${CHROMIUM_PROFILE_DIR}"
chmod 700 "${CHROMIUM_PROFILE_DIR}"

process_appears_to_be_chromium() {
    local pid="$1"
    local proc_comm=""
    local proc_arg0=""
    local proc_arg0_base=""

    [ -d "/proc/${pid}" ] || return 1

    proc_comm="$(cat "/proc/${pid}/comm" 2>/dev/null || true)"
    proc_arg0="$(tr '\0' '\n' < "/proc/${pid}/cmdline" 2>/dev/null | head -n 1 || true)"
    proc_arg0_base="${proc_arg0##*/}"

    case "${proc_comm} ${proc_arg0_base}" in
        *chromium*|*chrome*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

clear_stale_chromium_profile_locks() {
    local singleton_lock="${CHROMIUM_PROFILE_DIR}/SingletonLock"
    local default_profile_dir="${CHROMIUM_PROFILE_DIR}/Default"
    local singleton_target=""
    local singleton_pid=""
    local has_lock_artifacts=false

    if [ -e "${singleton_lock}" ] || [ -L "${singleton_lock}" ]; then
        has_lock_artifacts=true
        singleton_target="$(readlink "${singleton_lock}" 2>/dev/null || true)"
        if [ -z "${singleton_target}" ] && [ -f "${singleton_lock}" ]; then
            singleton_target="$(cat "${singleton_lock}" 2>/dev/null || true)"
        fi

        if [[ "${singleton_target}" =~ -([0-9]+)$ ]]; then
            singleton_pid="${BASH_REMATCH[1]}"
            if process_appears_to_be_chromium "${singleton_pid}"; then
                echo "Chromium profile lock appears owned by live Chromium process ${singleton_pid}; preserving lock files."
                return 0
            fi
        fi
    fi

    if [ -e "${default_profile_dir}/LOCK" ] || compgen -G "${default_profile_dir}/.org.chromium.Chromium.*" >/dev/null; then
        has_lock_artifacts=true
    fi

    if [ "${has_lock_artifacts}" = true ]; then
        echo "Clearing stale Chromium profile lock artifacts from ${CHROMIUM_PROFILE_DIR}."
        rm -f \
            "${CHROMIUM_PROFILE_DIR}/SingletonLock" \
            "${CHROMIUM_PROFILE_DIR}/SingletonSocket" \
            "${CHROMIUM_PROFILE_DIR}/SingletonCookie" \
            "${default_profile_dir}/LOCK" \
            "${default_profile_dir}"/.org.chromium.Chromium.*
    fi
}

clear_stale_chromium_profile_locks

# DBus configuration
mkdir -p /var/run/dbus
chown messagebus:messagebus /var/run/dbus
chmod 755 /var/run/dbus

# FIX: Clear potential stale PID file before starting supervisord/dbus
rm -f /run/dbus/pid

# Clear stale X display artifacts left by abrupt container shutdown.
DISPLAY_NUM="${DISPLAY:-:99}"
DISPLAY_NUM="${DISPLAY_NUM#:}"
rm -f "/tmp/.X${DISPLAY_NUM}-lock" "/tmp/.X11-unix/X${DISPLAY_NUM}"

# Create supervisor socket directory
mkdir -p "$(dirname /var/run/supervisor.sock)"
chown vncuser:vncuser "$(dirname /var/run/supervisor.sock)"

# Start Noble's Python 3.12-compatible distribution Supervisor as root.
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
