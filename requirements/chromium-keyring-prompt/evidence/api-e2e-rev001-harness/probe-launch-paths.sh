#!/usr/bin/env bash
# C07 (API-REV-001, temporary): every Chromium launch path carries --password-store=basic
# and loads a page without any keyring activity. Runs as root inside a container started
# with the image's normal entrypoint. The server bridge script is copied in beforehand at
# /usr/local/bin/open-vnc-browser-url.sh (from the superrepo, unchanged).
set -uo pipefail
fail_count=0
note() { printf '%s\n' "$*"; }
pass() { printf 'PASS: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; fail_count=$((fail_count + 1)); }

vnc_uid="$(id -u vncuser)"
as_vnc_env=(env DISPLAY=:99 XAUTHORITY=/home/vncuser/.Xauthority XDG_RUNTIME_DIR="/run/user/$vnc_uid" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$vnc_uid/bus" HOME=/home/vncuser)
dbus_log=/var/log/supervisor/dbus.err.log

main_pids() {  # Chromium browser (non --type=) processes of vncuser
  local pid cmd
  for pid in $(pgrep -u vncuser -f '/usr/lib/chromium/chromium ' || true); do
    cmd="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
    [[ -n "$cmd" && " $cmd " != *" --type="* ]] && printf '%s\n' "$pid"
  done
}
cmdline_of() { tr '\0' ' ' < "/proc/$1/cmdline" 2>/dev/null; }
ancestry_of() {  # comm chain up to PID 1
  local pid="$1" out=""
  while [[ -n "$pid" && "$pid" != 0 ]]; do
    out+="$(cat /proc/$pid/comm 2>/dev/null)[$pid] <- "
    [[ "$pid" == 1 ]] && break
    pid="$(awk '/^PPid:/{print $2}' /proc/$pid/status 2>/dev/null)"
  done
  printf '%s' "${out% <- }"
}
wait_for_window_title() {  # $1 = substring, $2 = timeout seconds
  local deadline=$((SECONDS + $2)) name
  while (( SECONDS < deadline )); do
    name="$(runuser -u vncuser -- "${as_vnc_env[@]}" xdotool search --onlyvisible --name "$1" getwindowname %@ 2>/dev/null | head -n 1 || true)"
    [[ -n "$name" ]] && { printf '%s' "$name"; return 0; }
    sleep 0.5
  done
  return 1
}
keyring_state() {
  local procs act
  procs="$(pgrep -af 'gcr-prompter|gnome-keyring-daemon' || true)"
  act="$(grep -E "Activating service name='(org\.freedesktop\.secrets|org\.freedesktop\.impl\.portal\.Secret|org\.gnome\.keyring[^']*)'" "$dbus_log" || true)"
  if [[ -z "$procs" && -z "$act" ]]; then pass "$1: no keyring/prompter process and no secrets/keyring/portal D-Bus activation"; else fail "$1: keyring activity: procs=[$procs] activations=[$act]"; fi
}
stop_all_chromium() {
  supervisorctl stop chrome >/dev/null 2>&1 || true
  pkill -TERM -u vncuser -f '/usr/lib/chromium/chromium ' 2>/dev/null || true
  local deadline=$((SECONDS + 20))
  while (( SECONDS < deadline )) && pgrep -u vncuser -f '/usr/lib/chromium/chromium ' >/dev/null; do sleep 0.5; done
  pkill -KILL -u vncuser -f '/usr/lib/chromium/chromium ' 2>/dev/null || true
  sleep 1
  pgrep -u vncuser -f '/usr/lib/chromium/chromium ' >/dev/null && fail "Chromium did not stop" || true
}
check_cold_launch() {  # $1 label, $2 url marker, rest = launch command (run as given)
  local label="$1" marker="$2"; shift 2
  stop_all_chromium
  note "--- $label: cold launch (Supervisor chrome STOPPED, no Chromium running) ---"
  note "\$ $*"
  local started=$SECONDS
  ( setsid "$@" >"/tmp/c07-$marker.out" 2>&1 & )
  local deadline=$((SECONDS + 60)) pid=""
  while (( SECONDS < deadline )); do pid="$(main_pids | head -n 1)"; [[ -n "$pid" ]] && break; sleep 0.5; done
  if [[ -z "$pid" ]]; then fail "$label: no Chromium browser process started; launcher output: $(cat /tmp/c07-$marker.out)"; return; fi
  local cmd; cmd="$(cmdline_of "$pid")"
  note "main pid=$pid ancestry: $(ancestry_of "$pid")"
  note "main cmdline: $cmd"
  if [[ " $cmd " == *" --password-store=basic "* ]]; then pass "$label: new Chromium main process carries --password-store=basic"; else fail "$label: flag missing"; fi
  if [[ " $cmd " == *" --remote-debugging-port="* ]]; then fail "$label: unexpectedly launched via start-chrome.sh (has remote-debugging flag)"; else pass "$label: process did not come from start-chrome.sh (no remote-debugging flag)"; fi
  local title
  if title="$(wait_for_window_title "Directory listing for /" 30)"; then
    pass "$label: page rendered unattended in $((SECONDS - started)) s; window title: $title"
  else
    fail "$label: no 'Directory listing for /' window within 30 s; visible windows: $(runuser -u vncuser -- "${as_vnc_env[@]}" xdotool search --onlyvisible --name . getwindowname %@ 2>/dev/null | tr '\n' '|')"
  fi
  keyring_state "$label"
}

note "C07 launch-path probe start_utc=$(date -u +%FT%TZ) image_variant=$IMAGE_VARIANT vnc_uid=$vnc_uid chromium=$(chromium --version 2>/dev/null)"
note "xdg-mime http default: $(runuser -u vncuser -- "${as_vnc_env[@]}" xdg-mime query default x-scheme-handler/http)"
note "xfce WebBrowser helper: $(grep -h '^WebBrowser=' /etc/xdg/xfce4/helpers.rc /home/vncuser/.config/xfce4/helpers.rc 2>/dev/null | tr '\n' ' ') ; x-www-browser -> $(readlink -f /etc/alternatives/x-www-browser); sensible-browser=$(command -v sensible-browser)"

# 1. Warm server bridge: Supervisor Chromium running, URL handed over by the root bridge.
note "--- server bridge (warm): root -> open-vnc-browser-url.sh -> runuser vncuser xdg-open ---"
[[ -x /usr/local/bin/open-vnc-browser-url.sh ]] || fail "bridge script not installed in the test container"
warm_pid_before="$(main_pids | head -n 1)"
started=$SECONDS
( setsid /usr/local/bin/open-vnc-browser-url.sh 'http://127.0.0.1:6080/?c07=warm-bridge' >/tmp/c07-warm.out 2>&1 & )
found=""
deadline=$((SECONDS + 30))
while (( SECONDS < deadline )); do
  if curl -fsS --max-time 3 http://127.0.0.1:9222/json/list 2>/dev/null | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const t=JSON.parse(s).find(p=>p.url.includes("c07=warm-bridge")&&p.title==="Directory listing for /");process.exit(t?0:1)})'; then found=yes; break; fi
  sleep 0.5
done
[[ -n "$found" ]] && pass "server bridge (warm): tab c07=warm-bridge rendered 'Directory listing for /' in $((SECONDS - started)) s via DevTools /json/list" || fail "server bridge (warm): tab not rendered within 30 s; bridge output: $(cat /tmp/c07-warm.out)"
[[ "$(main_pids | head -n 1)" == "$warm_pid_before" ]] && pass "server bridge (warm): URL was handed to the existing Supervisor Chromium (pid $warm_pid_before)" || note "note: main pid changed from $warm_pid_before to $(main_pids | head -n 1)"
keyring_state "server bridge (warm)"

# 2. Cold server bridge (the path the AutoByteus server uses when Chromium is not running).
check_cold_launch "server bridge (cold)" cold-bridge /usr/local/bin/open-vnc-browser-url.sh 'http://127.0.0.1:6080/?c07=cold-bridge'
# 3. Cold XFCE preferred web browser (panel/menu "Web Browser").
check_cold_launch "XFCE exo-open --launch WebBrowser (cold)" cold-exo runuser -u vncuser -- "${as_vnc_env[@]}" /usr/bin/exo-open --launch WebBrowser 'http://127.0.0.1:6080/?c07=cold-exo'
# 4. Cold desktop entry (menu item / .desktop activation).
check_cold_launch "desktop entry gtk-launch chromium (cold)" cold-gtk runuser -u vncuser -- "${as_vnc_env[@]}" /usr/bin/gtk-launch chromium 'http://127.0.0.1:6080/?c07=cold-gtk'

# Restore the Supervisor-managed browser and confirm it carries the flag again.
stop_all_chromium
supervisorctl start chrome >/dev/null 2>&1 || true
deadline=$((SECONDS + 60)); pid=""
while (( SECONDS < deadline )); do pid="$(main_pids | head -n 1)"; [[ -n "$pid" ]] && curl -fsS --max-time 2 http://127.0.0.1:9222/json/version >/dev/null 2>&1 && break; sleep 1; done
if [[ -n "$pid" && " $(cmdline_of "$pid") " == *" --password-store=basic "* && " $(cmdline_of "$pid") " == *" --remote-debugging-port=9222 "* ]]; then
  pass "restored Supervisor Chromium (pid $pid) carries --password-store=basic and DevTools 9222"
else
  fail "Supervisor Chromium not restored correctly: pid=$pid cmd=$( [[ -n "$pid" ]] && cmdline_of "$pid")"
fi
note "supervisorctl status chrome: $(supervisorctl status chrome)"
note "C07 end_utc=$(date -u +%FT%TZ) failures=$fail_count"
(( fail_count == 0 ))
