#!/usr/bin/env bash
# C09 (API-REV-001, temporary): what the VNC operator sees after startup + navigation.
# Enumerates every X11 window on :99 and audits every session-bus service activation.
# Usage (inside the container, as root): probe-operator-view.sh SCREENSHOT_PATH
set -uo pipefail
shot="${1:-/tmp/c09-root.png}"
vnc_uid="$(id -u vncuser)"
as_vnc=(runuser -u vncuser -- env DISPLAY=:99 XAUTHORITY=/home/vncuser/.Xauthority XDG_RUNTIME_DIR="/run/user/$vnc_uid" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$vnc_uid/bus" HOME=/home/vncuser)
fail_count=0
pass() { printf 'PASS: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; fail_count=$((fail_count + 1)); }

printf 'C09 operator-view probe utc=%s image_variant=%s\n' "$(date -u +%FT%TZ)" "$IMAGE_VARIANT"
printf -- '--- visible top-level windows (xdotool search --onlyvisible) ---\n'
"${as_vnc[@]}" xdotool search --onlyvisible --name '.' 2>/dev/null | while read -r w; do
  printf '  0x%x  class=%s  name=%s\n' "$w" "$("${as_vnc[@]}" xprop -id "$w" WM_CLASS 2>/dev/null | sed 's/^WM_CLASS(STRING) = //')" "$("${as_vnc[@]}" xdotool getwindowname "$w" 2>/dev/null)"
done
keyring_windows="$("${as_vnc[@]}" xwininfo -root -tree 2>/dev/null | grep -iE 'keyring|gcr-prompter|Gcr-prompter|password for new|unlock|passphrase' || true)"
[[ -z "$keyring_windows" ]] && pass "no keyring/prompter/unlock window exists anywhere in the X11 tree (xwininfo -root -tree)" || fail "keyring-related window(s) present: $keyring_windows"
procs="$(pgrep -af 'gcr-prompter|gnome-keyring-daemon|pinentry' || true)"
[[ -z "$procs" ]] && pass "no gcr-prompter / gnome-keyring-daemon / pinentry process" || fail "prompt process(es): $procs"

printf -- '--- every session D-Bus activation since container start (/var/log/supervisor/dbus.err.log) ---\n'
grep -o "Activating service name='[^']*'[^)]*comm=\"[^\"]\{0,40\}" /var/log/supervisor/dbus.err.log 2>/dev/null | sed 's/^/  /' || true
printf -- '--- successful activations ---\n'
grep -o "Successfully activated service '[^']*'" /var/log/supervisor/dbus.err.log 2>/dev/null | sort | uniq -c | sed 's/^/  /' || true
bad="$(grep -E "Activating service name='(org\.freedesktop\.secrets|org\.freedesktop\.impl\.portal\.Secret|org\.gnome\.keyring[^']*|org\.gnome\.evolution\.dataserver\.UserPrompter0)'" /var/log/supervisor/dbus.err.log || true)"
[[ -z "$bad" ]] && pass "no Secret Service, portal Secret backend, gnome-keyring prompter or e-d-s UserPrompter activation" || fail "keyring-related activation: $bad"

"${as_vnc[@]}" scrot -o /tmp/c09-root.png >/dev/null 2>&1 && cp /tmp/c09-root.png "$shot" && printf 'screenshot: %s (%s bytes)\n' "$shot" "$(stat -c %s "$shot")" || fail "scrot failed"
printf 'C09 failures=%s\n' "$fail_count"
(( fail_count == 0 ))
