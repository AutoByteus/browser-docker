#!/usr/bin/env bash
# C10 (API-REV-001, temporary): real libsecret clients (the library used by git credential
# helpers, Python keyring's SecretService backend, many OAuth token stores) must fail fast.
# Runs inside the container as root. Usage: probe-keyring-clients.sh [HANG_TIMEOUT_S]
set -uo pipefail
hang_timeout="${1:-20}"
vnc_uid="$(id -u vncuser)"
fail_count=0
pass() { printf 'PASS: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; fail_count=$((fail_count + 1)); }

cat > /tmp/c10-client.py <<'PY'
import sys, time
import gi
gi.require_version("Secret", "1")
from gi.repository import Secret
op = sys.argv[1]
schema = Secret.Schema.new("org.autobyteus.apie2e.Probe", Secret.SchemaFlags.NONE,
                           {"account": Secret.SchemaAttributeType.STRING})
t0 = time.monotonic()
try:
    if op == "store":
        ok = Secret.password_store_sync(schema, {"account": "api-e2e"}, Secret.COLLECTION_DEFAULT,
                                        "api-e2e probe", "not-a-real-secret", None)
        result = f"STORED ok={ok}"
    else:
        result = f"LOOKUP value={Secret.password_lookup_sync(schema, {'account': 'api-e2e'}, None)!r}"
    status = 0
except Exception as exc:  # GLib.Error
    result = f"ERROR {type(exc).__name__}: {exc}"
    status = 3
print(f"{op}: {result} elapsed_ms={int((time.monotonic() - t0) * 1000)}")
sys.exit(status)
PY
chmod 0644 /tmp/c10-client.py

run_client() {  # label, expected-substring-regex, command...
  local label="$1" expect="$2"; shift 2
  local started_ns out rc elapsed_ms
  started_ns="$(date +%s%N)"
  out="$(timeout "$hang_timeout" "$@" 2>&1)"; rc=$?
  elapsed_ms=$(( ($(date +%s%N) - started_ns) / 1000000 ))
  printf '%s: rc=%s wall_ms=%s output=%s\n' "$label" "$rc" "$elapsed_ms" "$(tr '\n' ' ' <<<"$out")"
  if (( rc == 124 )); then fail "$label hung until the ${hang_timeout}s timeout (keyring prompt or provider wait)"; return; fi
  (( rc != 0 )) || { fail "$label succeeded - a keyring provider accepted the request"; return; }
  grep -Eq "$expect" <<<"$out" || { fail "$label failed for an unexpected reason"; return; }
  (( elapsed_ms <= 2000 )) && pass "$label failed fast (${elapsed_ms} ms <= 2000 ms)" || fail "$label took ${elapsed_ms} ms (> 2000 ms)"
}

printf 'C10 keyring-client probe utc=%s image_variant=%s python=%s libsecret=%s\n' "$(date -u +%FT%TZ)" "$IMAGE_VARIANT" "$(/usr/bin/python3 --version 2>&1)" "$(dpkg-query -W -f='${Version}' libsecret-1-0 2>/dev/null)"
vnc_env=(env HOME=/home/vncuser DISPLAY=:99 XDG_RUNTIME_DIR="/run/user/$vnc_uid" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$vnc_uid/bus")
run_client "vncuser libsecret store (desktop user, own session bus)" 'not provided by any \.service files|ServiceUnknown' runuser -u vncuser -- "${vnc_env[@]}" /usr/bin/python3 /tmp/c10-client.py store
run_client "vncuser libsecret lookup" 'not provided by any \.service files|ServiceUnknown' runuser -u vncuser -- "${vnc_env[@]}" /usr/bin/python3 /tmp/c10-client.py lookup
# Root agent tools inherit DBUS_SESSION_BUS_ADDRESS pointing at vncuser's bus (server image PID 1 env).
run_client "root libsecret store (inherited vncuser bus address)" 'closed|not provided by any \.service files|ServiceUnknown|Could not connect|Error' env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$vnc_uid/bus" /usr/bin/python3 /tmp/c10-client.py store
run_client "vncuser dbus-send Secret Service ping" 'ServiceUnknown|not provided by any \.service files' runuser -u vncuser -- "${vnc_env[@]}" dbus-send --session --print-reply --dest=org.freedesktop.secrets /org/freedesktop/secrets org.freedesktop.DBus.Peer.Ping
procs="$(pgrep -af 'gcr-prompter|gnome-keyring-daemon' || true)"
[[ -z "$procs" ]] && pass "no prompt/provider process after the client requests" || fail "prompt/provider process after client requests: $procs"
printf 'C10 failures=%s\n' "$fail_count"
(( fail_count == 0 ))
