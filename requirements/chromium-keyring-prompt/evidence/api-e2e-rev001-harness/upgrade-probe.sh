#!/usr/bin/env bash
# C11 (API-REV-001, temporary): approved persisted-data outcome for the Chromium profile volume.
#   chain a: 1.3.8 (built-in v10 cookie) -> 1.4.0 (dialog left pending) -> fixed image
#   chain b: 1.4.0 with a keyring password typed into the real dialog (keyring-encrypted v11
#            cookie) -> container re-created on the fixed image -> restart
# Usage: upgrade-probe.sh a|b
set -uo pipefail
chain="$1"
WT=/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt
FIXED=autobyteus/chrome-vnc:api-e2e-keyring-arm64-default
V="api-e2e-keyring-upg-$chain-profile"
CDP="node /tmp/api-e2e-keyring/cdp.js"
cd "$WT"
run_node() {  # name image
  docker rm -f "$1" >/dev/null 2>&1
  docker run -d --name "$1" --platform linux/arm64 --cap-add SYS_ADMIN --security-opt seccomp=unconfined -p 127.0.0.1::9223 -v "$V":/home/vncuser/.config/chromium "$2" >/dev/null
  echo "started $1 from $2 ($(docker image inspect -f '{{.Id}}' "$2" | cut -c1-19)) on volume $V"
}
hp() { docker port "$1" 9223/tcp | head -n 1; }
db_inspect() {  # read the profile volume with the fixed image's OS Python (read-only mount)
  docker run --rm --entrypoint /usr/bin/python3 -v "$V":/p:ro "$FIXED" -c '
import glob, json, sqlite3
for db in glob.glob("/p/Default/Cookies") + glob.glob("/p/Default/Network/Cookies"):
    con = sqlite3.connect(f"file:{db}?mode=ro&immutable=1", uri=True)
    rows = con.execute("SELECT host_key, name, substr(encrypted_value,1,3), length(encrypted_value), value FROM cookies WHERE name LIKE \"apie2e%\" ORDER BY name").fetchall()
    print(f"DB {db}: apie2e rows = " + json.dumps([{"host": h, "name": n, "enc_prefix": p.decode(errors="replace") if isinstance(p, bytes) else p, "enc_len": l, "plain_value": v} for h, n, p, l, v in rows]))
try:
    ls = json.load(open("/p/Local State"))
    print("Local State os_crypt keys:", sorted((ls.get("os_crypt") or {}).keys()))
except Exception as e:
    print("Local State:", e)
'
}
keyring_state() { docker exec "$1" bash -c 'echo "keyring procs(exact comm): $(ps -eo comm= | grep -cE "^(gcr-prompter|gnome-keyring-d)"); secrets activations: $(grep -c "name=.org.freedesktop.secrets." /var/log/supervisor/dbus.err.log); keyrings dir: $(ls -A /home/vncuser/.local/share/keyrings 2>/dev/null | tr "\n" " ")"'; }
echo "C11 chain $chain start_utc=$(date -u +%FT%TZ)"
docker volume rm "$V" >/dev/null 2>&1

if [[ "$chain" == a ]]; then
  echo "=== a1: 1.3.8 creates the profile and a cookie (no provider on 22.04 -> built-in v10) ==="
  run_node api-e2e-keyring-upg-a1 autobyteus/chrome-vnc:1.3.8-arm64; H=$(hp api-e2e-keyring-upg-a1)
  docker exec api-e2e-keyring-upg-a1 chromium --version
  $CDP "$H" wait && $CDP "$H" nav http://127.0.0.1:6080/ 'Directory listing for /' && $CDP "$H" setcookie apie2e_138 v10-from-1.3.8 && $CDP "$H" cookies
  echo "waiting 40 s for Chromium's periodic cookie-store commit (30 s)"; sleep 40; echo "pre-stop DB state:"; db_inspect
  keyring_state api-e2e-keyring-upg-a1
  docker stop -t 30 api-e2e-keyring-upg-a1 >/dev/null; docker rm api-e2e-keyring-upg-a1 >/dev/null; echo "a1 stopped gracefully and removed"
  db_inspect
  echo "=== a2: 1.4.0 runs on the same profile; keyring dialog left pending (the common field state) ==="
  run_node api-e2e-keyring-upg-a2 autobyteus/chrome-vnc:1.4.0
  for i in $(seq 1 60); do docker exec api-e2e-keyring-upg-a2 pgrep -x gcr-prompter >/dev/null 2>&1 && break; sleep 1; done
  echo "gcr-prompter pending after ~${i}s: $(docker exec api-e2e-keyring-upg-a2 pgrep -a -x gcr-prompter)"; sleep 10
  keyring_state api-e2e-keyring-upg-a2
  docker stop -t 30 api-e2e-keyring-upg-a2 >/dev/null; docker rm api-e2e-keyring-upg-a2 >/dev/null; echo "a2 stopped and removed (container re-create, volume kept)"
  db_inspect
  echo "=== a3: fixed image re-created on the same profile volume ==="
  run_node api-e2e-keyring-upg-a3 "$FIXED"; H=$(hp api-e2e-keyring-upg-a3)
  echo "\$ tests/validate-running-container.sh api-e2e-keyring-upg-a3 default"
  tests/validate-running-container.sh api-e2e-keyring-upg-a3 default 2>&1 | grep -E '^(PASS|FAIL)'; echo "runtime contract exit=${PIPESTATUS[0]}"
  $CDP "$H" nav http://127.0.0.1:6080/ 'Directory listing for /'; $CDP "$H" doccookie; $CDP "$H" cookies
  if $CDP "$H" doccookie | grep -q 'apie2e_138=v10-from-1.3.8'; then echo "PASS: cookie written by 1.3.8 is readable on the fixed image (profile directly usable)"; else echo "FAIL: 1.3.8 cookie not readable on the fixed image"; fi
  keyring_state api-e2e-keyring-upg-a3
  docker cp /tmp/api-e2e-keyring/probe-operator-view.sh api-e2e-keyring-upg-a3:/tmp/ >/dev/null
  docker exec api-e2e-keyring-upg-a3 /tmp/probe-operator-view.sh /tmp/c11a.png | grep -E '^(PASS|FAIL)'
  docker cp api-e2e-keyring-upg-a3:/tmp/c11a.png "$WT/requirements/chromium-keyring-prompt/evidence/api-e2e-rev001-upgrade-a-fixed-operator-view.png" >/dev/null && echo "screenshot: api-e2e-rev001-upgrade-a-fixed-operator-view.png"
  docker rm -f api-e2e-keyring-upg-a3 >/dev/null
else
  echo "=== b1: 1.4.0; operator types a keyring password into the real dialog (xdotool) ==="
  run_node api-e2e-keyring-upg-b1 autobyteus/chrome-vnc:1.4.0; H=$(hp api-e2e-keyring-upg-b1)
  for i in $(seq 1 60); do docker exec api-e2e-keyring-upg-b1 pgrep -x gcr-prompter >/dev/null 2>&1 && break; sleep 1; done; sleep 3
  echo "gcr-prompter pending after ~${i}s"
  docker exec api-e2e-keyring-upg-b1 runuser -u vncuser -- env DISPLAY=:99 XAUTHORITY=/home/vncuser/.Xauthority bash -c '
    w=$(xdotool search --onlyvisible --class gcr-prompter | tail -n 1); echo "dialog window: $w $(xwininfo -id $w | grep -E "Width|Height" | tr -s " " | tr "\n" " ")"
    xdotool windowactivate --sync "$w"; sleep 0.5
    xdotool type --delay 40 "apie2e-keyring-pass"; xdotool key Tab; xdotool type --delay 40 "apie2e-keyring-pass"; sleep 0.3; xdotool key Return'
  for i in $(seq 1 30); do docker exec api-e2e-keyring-upg-b1 pgrep -x gcr-prompter >/dev/null 2>&1 || break; sleep 1; done
  keyring_state api-e2e-keyring-upg-b1
  $CDP "$H" nav http://127.0.0.1:6080/ 'Directory listing for /' && $CDP "$H" setcookie apie2e_140 v11-from-typed-keyring && $CDP "$H" cookies
  echo "waiting 40 s for Chromium's periodic cookie-store commit (30 s)"; sleep 40; echo "pre-stop DB state:"; db_inspect
  docker stop -t 30 api-e2e-keyring-upg-b1 >/dev/null; echo "b1 stopped gracefully"
  db_inspect
  docker rm api-e2e-keyring-upg-b1 >/dev/null; echo "b1 removed (its container-layer keyring is gone, as on a real re-create)"
  echo "=== b2: fixed image re-created on the same profile volume ==="
  run_node api-e2e-keyring-upg-b2 "$FIXED"; H=$(hp api-e2e-keyring-upg-b2)
  echo "\$ tests/validate-running-container.sh api-e2e-keyring-upg-b2 default"
  tests/validate-running-container.sh api-e2e-keyring-upg-b2 default 2>&1 | grep -E '^(PASS|FAIL)'; echo "runtime contract exit=${PIPESTATUS[0]}"
  $CDP "$H" nav http://127.0.0.1:6080/ 'Directory listing for /'; $CDP "$H" doccookie; $CDP "$H" cookies
  if $CDP "$H" doccookie | grep -q 'apie2e_140='; then echo "OBSERVED: keyring-encrypted cookie still readable (no loss)"; else echo "OBSERVED: keyring-encrypted cookie apie2e_140 is not readable (approved one-time re-login, DEC-003)"; fi
  keyring_state api-e2e-keyring-upg-b2
  docker cp /tmp/api-e2e-keyring/probe-operator-view.sh api-e2e-keyring-upg-b2:/tmp/ >/dev/null
  docker exec api-e2e-keyring-upg-b2 /tmp/probe-operator-view.sh /tmp/c11b.png | grep -E '^(PASS|FAIL)'
  docker cp api-e2e-keyring-upg-b2:/tmp/c11b.png "$WT/requirements/chromium-keyring-prompt/evidence/api-e2e-rev001-upgrade-b-fixed-operator-view.png" >/dev/null && echo "screenshot: api-e2e-rev001-upgrade-b-fixed-operator-view.png"
  echo "=== b3: re-login equivalent - a new cookie on the fixed image persists across docker restart ==="
  $CDP "$H" setcookie apie2e_141 v10-after-upgrade
  echo "waiting 40 s for Chromium's periodic cookie-store commit (30 s)"; sleep 40; echo "pre-stop DB state:"; db_inspect
  docker restart -t 30 api-e2e-keyring-upg-b2 >/dev/null; H=$(hp api-e2e-keyring-upg-b2); $CDP "$H" wait
  $CDP "$H" nav http://127.0.0.1:6080/ 'Directory listing for /'; $CDP "$H" doccookie
  if $CDP "$H" doccookie | grep -q 'apie2e_141=v10-after-upgrade'; then echo "PASS: cookie written by the fixed image persists across restart"; else echo "FAIL: new cookie lost across restart"; fi
  keyring_state api-e2e-keyring-upg-b2
  docker stop -t 30 api-e2e-keyring-upg-b2 >/dev/null; db_inspect; docker rm api-e2e-keyring-upg-b2 >/dev/null
fi
docker volume rm "$V" >/dev/null && echo "volume $V removed"
echo "C11 chain $chain end_utc=$(date -u +%FT%TZ)"
