#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: tests/validate-running-container.sh CONTAINER [default|zh] [EXPECTED_UID]

The named container must be running the image's normal entrypoint.
EOF
  exit 2
}

container="${1:-}"
variant="${2:-default}"
expected_uid="${3:-1000}"

[[ -n "$container" ]] || usage
[[ "$variant" == "default" || "$variant" == "zh" ]] || usage
[[ "$expected_uid" =~ ^[0-9]+$ ]] || usage

docker inspect -f '{{.State.Running}}' "$container" | grep -qx true

deadline=$((SECONDS + 120))
while (( SECONDS < deadline )); do
  status="$(docker exec "$container" supervisorctl status 2>&1 || true)"
  if for program in dbus tigervnc xfce fcitx copyq chrome socat websockify; do
       grep -Eq "^${program}[[:space:]]+RUNNING" <<<"$status" || exit 1
     done; then
    break
  fi
  sleep 2
done

printf '%s\n' "$status"
for program in dbus tigervnc xfce fcitx copyq chrome socat websockify; do
  grep -Eq "^${program}[[:space:]]+RUNNING" <<<"$status" || {
    docker logs "$container" >&2 || true
    printf 'FAIL: Supervisor program %s did not reach RUNNING.\n' "$program" >&2
    exit 1
  }
done

docker exec -e EXPECTED_VARIANT="$variant" -e EXPECTED_UID="$expected_uid" "$container" /bin/bash -s <<'CONTAINER_CHECKS'
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ "$(id -u vncuser)" == "$EXPECTED_UID" ]] || fail "runtime vncuser UID mismatch"
[[ "$XDG_RUNTIME_DIR" == "/run/user/$EXPECTED_UID" ]] || fail "runtime XDG_RUNTIME_DIR mismatch: $XDG_RUNTIME_DIR"
[[ -S "/run/user/$EXPECTED_UID/bus" ]] || fail "DBus session socket missing from configured UID path"
[[ "$(stat -c %u "/run/user/$EXPECTED_UID")" == "$EXPECTED_UID" ]] || fail "runtime path ownership mismatch"

pgrep -u vncuser -x Xvnc >/dev/null || fail "Xvnc process missing"
pgrep -u vncuser -x dbus-daemon >/dev/null || fail "session DBus process missing"
pgrep -u vncuser -f '/usr/lib/chromium/chromium.*--remote-debugging-port=9222' >/dev/null || fail "Chromium process missing"
pgrep -u vncuser -f 'socat TCP-LISTEN:9223' >/dev/null || fail "socat debugging proxy missing"
pgrep -u vncuser -f 'websockify.*6080 localhost:5900' >/dev/null || fail "websockify process missing"
if [[ "$EXPECTED_VARIANT" == "zh" ]]; then
  pgrep -u vncuser -x fcitx5 >/dev/null || fail "fcitx5 process missing in zh image"
else
  ! pgrep -u vncuser -x fcitx5 >/dev/null || fail "fcitx5 unexpectedly runs in default image"
fi

vnc_banner="$(timeout 3 bash -c 'exec 3<>/dev/tcp/127.0.0.1/5900; head -c 12 <&3')"
[[ "$vnc_banner" == RFB\ 003.* ]] || fail "unexpected VNC banner: $vnc_banner"
curl --fail --silent --show-error --max-time 5 http://127.0.0.1:6080/ | grep -q 'Directory listing for /' || fail "websockify HTTP asset surface unavailable"
curl --fail --silent --show-error --max-time 5 http://127.0.0.1:9223/json/version | grep -q 'webSocketDebuggerUrl' || fail "Chromium remote-debugging proxy unavailable"

python3 - <<'PY'
import base64
import os
import socket

sock = socket.create_connection(("127.0.0.1", 6080), timeout=5)
key = base64.b64encode(os.urandom(16)).decode()
request = (
    "GET /websockify HTTP/1.1\r\n"
    "Host: 127.0.0.1:6080\r\n"
    "Upgrade: websocket\r\n"
    "Connection: Upgrade\r\n"
    f"Sec-WebSocket-Key: {key}\r\n"
    "Sec-WebSocket-Version: 13\r\n"
    "Sec-WebSocket-Protocol: binary\r\n\r\n"
)
sock.sendall(request.encode())
response = sock.recv(4096)
sock.close()
assert response.startswith(b"HTTP/1.1 101"), response.decode(errors="replace")
PY

su -s /bin/bash vncuser -c 'test -w /home/vncuser/.config/chromium && printf runtime-write-ok > /home/vncuser/.config/chromium/api-e2e-runtime-marker'
[[ "$(stat -c %u /home/vncuser/.config/chromium/api-e2e-runtime-marker)" == "$EXPECTED_UID" ]] || fail "profile write ownership mismatch"

printf 'PASS: Supervisor, process, UID/XDG/DBus, VNC, websockify, DevTools and profile-write contracts validated.\n'
CONTAINER_CHECKS

# Drive the existing Chromium instance over its real DevTools WebSocket and
# assert semantic DOM state rather than treating a screenshot as the sole proof.
docker exec "$container" node <<'NODE'
const http = require('http');

function getJson(path) {
  return new Promise((resolve, reject) => {
    http.get({host: '127.0.0.1', port: 9223, path}, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        if (res.statusCode !== 200) return reject(new Error(`HTTP ${res.statusCode}: ${body}`));
        try { resolve(JSON.parse(body)); } catch (error) { reject(error); }
      });
    }).on('error', reject);
  });
}

(async () => {
  let pages = await getJson('/json/list');
  if (!pages.length) throw new Error('No Chromium DevTools page target is available');
  const ws = new WebSocket(pages[0].webSocketDebuggerUrl);
  const pending = new Map();
  let nextId = 1;
  ws.onmessage = ({data}) => {
    const message = JSON.parse(data);
    if (message.id && pending.has(message.id)) {
      const {resolve, reject} = pending.get(message.id);
      pending.delete(message.id);
      message.error ? reject(new Error(JSON.stringify(message.error))) : resolve(message.result);
    }
  };
  await new Promise((resolve, reject) => {
    ws.onopen = resolve;
    ws.onerror = reject;
  });
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, {resolve, reject});
    ws.send(JSON.stringify({id, method, params}));
  });
  await send('Page.enable');
  const html = '<!doctype html><title>BRD-UBUNTU24-001</title><h1 id="evidence">Noble browser render passed</h1>';
  await send('Page.navigate', {url: `data:text/html,${encodeURIComponent(html)}`});
  await new Promise(resolve => setTimeout(resolve, 1000));
  const result = await send('Runtime.evaluate', {
    expression: 'JSON.stringify({title: document.title, evidence: document.querySelector("#evidence")?.textContent})',
    returnByValue: true,
  });
  const observed = JSON.parse(result.result.value);
  if (observed.title !== 'BRD-UBUNTU24-001' || observed.evidence !== 'Noble browser render passed') {
    throw new Error(`Unexpected rendered DOM: ${JSON.stringify(observed)}`);
  }
  process.stdout.write(`PASS: Chromium rendered semantic DOM through DevTools: ${JSON.stringify(observed)}\n`);
  ws.close();
})().catch(error => {
  console.error(`FAIL: Chromium DevTools render probe: ${error.stack || error}`);
  process.exit(1);
});
NODE
