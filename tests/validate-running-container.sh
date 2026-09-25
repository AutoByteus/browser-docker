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
  all_running=true
  for program in dbus tigervnc xfce fcitx copyq chrome socat websockify; do
    if ! grep -Eq "^${program}[[:space:]]+RUNNING" <<<"$status"; then
      all_running=false
      break
    fi
  done
  if "$all_running"; then
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

docker exec -i -e EXPECTED_VARIANT="$variant" -e EXPECTED_UID="$expected_uid" "$container" /bin/bash -s <<'CONTAINER_CHECKS'
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

process_uses_browser_tools_python313() {
  local pid="$1"
  local token=""

  while IFS= read -r token; do
    if [[ "$token" == "/opt/browser-tools/bin/python" ]] &&
       [[ "$(readlink -f "$token")" == "/usr/bin/python3.13" ]]; then
      return 0
    fi
  done < <(tr '\0' '\n' < "/proc/$pid/cmdline")

  return 1
}

[[ "$(id -u vncuser)" == "$EXPECTED_UID" ]] || fail "runtime vncuser UID mismatch"
[[ "$XDG_RUNTIME_DIR" == "/run/user/$EXPECTED_UID" ]] || fail "runtime XDG_RUNTIME_DIR mismatch: $XDG_RUNTIME_DIR"
[[ -S "/run/user/$EXPECTED_UID/bus" ]] || fail "DBus session socket missing from configured UID path"
[[ "$(stat -c %u "/run/user/$EXPECTED_UID")" == "$EXPECTED_UID" ]] || fail "runtime path ownership mismatch"

[[ "$(command -v supervisord)" == "/usr/local/bin/supervisord" ]] || fail "runtime supervisord command is not /usr/local/bin/supervisord"
[[ "$(command -v supervisorctl)" == "/usr/local/bin/supervisorctl" ]] || fail "runtime supervisorctl command is not /usr/local/bin/supervisorctl"
[[ "$(readlink -f /usr/local/bin/supervisord)" == "/opt/browser-tools/bin/supervisord" ]] || fail "runtime supervisord provider is not /opt/browser-tools"
[[ "$(readlink -f /usr/local/bin/supervisorctl)" == "/opt/browser-tools/bin/supervisorctl" ]] || fail "runtime supervisorctl provider is not /opt/browser-tools"
[[ "$(supervisord --version)" == "4.3.0" ]] || fail "runtime Supervisor is not 4.3.0"
[[ "$(supervisorctl version)" == "4.3.0" ]] || fail "running Supervisor control API is not 4.3.0"
[[ "$(supervisorctl pid)" == "1" ]] || fail "Supervisor is not container PID 1"
process_uses_browser_tools_python313 1 || fail "PID 1 command line does not use the isolated Python 3.13 interpreter"
tr '\0' ' ' < /proc/1/cmdline | grep -Fq '/usr/local/bin/supervisord' || fail "PID 1 command line does not contain the sole public Supervisor path"
/opt/browser-tools/bin/python -c 'import importlib.metadata, sys, supervisor; assert sys.prefix == "/opt/browser-tools"; assert sys.version_info[:2] == (3, 13); assert importlib.metadata.version("supervisor") == "4.3.0"'
! grep -RqiE 'pkgutil\.ImpImporter|AttributeError.*ImpImporter' /var/log/supervisor /var/log/supervisor* 2>/dev/null || fail "prior Python compatibility traceback is present"

pgrep -u vncuser -x Xvnc >/dev/null || fail "Xvnc process missing"
pgrep -u vncuser -x dbus-daemon >/dev/null || fail "session DBus process missing"
pgrep -u vncuser -f '/usr/lib/chromium/chromium.*--remote-debugging-port=9222' >/dev/null || fail "Chromium process missing"
# Chromium may rewrite its process title into one space-joined string, and an
# emulator may prefix the command line, so match space-delimited flags anywhere.
chromium_main_pid=""
chromium_main_cmdline=""
while IFS= read -r pid; do
  cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline")"
  if [[ " $cmdline " != *" --type="* ]]; then
    chromium_main_pid="$pid"
    chromium_main_cmdline="$cmdline"
    break
  fi
done < <(pgrep -u vncuser -f '/usr/lib/chromium/chromium ')
[[ -n "$chromium_main_pid" ]] || fail "Chromium main browser process missing"
[[ " $chromium_main_cmdline " == *" --password-store=basic "* ]] ||
  fail "Chromium main process $chromium_main_pid does not carry --password-store=basic: $chromium_main_cmdline"
pgrep -u vncuser -f 'socat TCP-LISTEN:9223' >/dev/null || fail "socat debugging proxy missing"
pgrep -u vncuser -f 'websockify.*6080 localhost:5900' >/dev/null || fail "websockify process missing"
[[ "$(readlink -f /usr/local/bin/websockify)" == "/opt/browser-tools/bin/websockify" ]] || fail "runtime websockify provider is not /opt/browser-tools"
[[ "$(readlink -f /usr/local/bin/uv)" == "/opt/browser-tools/bin/uv" ]] || fail "runtime uv provider is not /opt/browser-tools"
websockify_pid="$(pgrep -u vncuser -f 'websockify.*6080 localhost:5900' | head -n 1)"
process_uses_browser_tools_python313 "$websockify_pid" || fail "websockify command line does not use the isolated Python 3.13 interpreter"
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

printf 'PASS: isolated Supervisor 4.3.0, Python 3.13 process ownership, UID/XDG/DBus, VNC, websockify, DevTools, Chromium password-store and profile-write contracts validated.\n'
CONTAINER_CHECKS

# Drive the existing Chromium instance over its real DevTools WebSocket and
# assert semantic DOM state rather than treating a screenshot as the sole proof.
docker exec -i "$container" node <<'NODE'
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

  // An http:// page needs Chromium's cookie store, which an OS keyring prompt
  // blocks; the local websockify listing avoids any internet dependency.
  const httpUrl = 'http://127.0.0.1:6080/';
  const expectedTitle = 'Directory listing for /';
  const navigationTimeoutMs = 30000;
  const startedAt = Date.now();
  let timer;
  const httpNavigation = (async () => {
    await send('Page.navigate', {url: httpUrl});
    for (;;) {
      try {
        const state = await send('Runtime.evaluate', {
          expression: 'JSON.stringify({url: location.href, readyState: document.readyState, title: document.title})',
          returnByValue: true,
        });
        const page = JSON.parse(state.result.value);
        if (page.url === httpUrl && page.readyState === 'complete' && page.title === expectedTitle) return page;
      } catch (error) {
        // The execution context is replaced while the navigation commits; poll again.
      }
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  })();
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(
      () => reject(new Error(`${httpUrl} did not render '${expectedTitle}' within ${navigationTimeoutMs} ms`)),
      navigationTimeoutMs,
    );
  });
  const rendered = await Promise.race([httpNavigation, timeout]);
  clearTimeout(timer);
  process.stdout.write(`PASS: Chromium loaded ${httpUrl} unattended in ${Date.now() - startedAt} ms: ${JSON.stringify(rendered)}\n`);
  ws.close();
})().catch(error => {
  console.error(`FAIL: Chromium DevTools render probe: ${error.stack || error}`);
  process.exit(1);
});
NODE

# After startup and navigation, nothing may have asked for or provided an OS
# keyring, and a Secret Service request from the desktop user must fail fast.
docker exec -i "$container" /bin/bash -s <<'KEYRING_CHECKS'
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

keyring_processes="$(pgrep -af 'gcr-prompter|gnome-keyring-daemon' || true)"
[[ -z "$keyring_processes" ]] || fail "keyring processes are running: $keyring_processes"

dbus_log=/var/log/supervisor/dbus.err.log
[[ -f "$dbus_log" ]] || fail "session D-Bus log $dbus_log is missing"
secrets_activation="$(grep -F "Activating service name='org.freedesktop.secrets'" "$dbus_log" || true)"
[[ -z "$secrets_activation" ]] || fail "session D-Bus activated the Secret Service: $secrets_activation"

started_ns="$(date +%s%N)"
secret_status=0
secret_output="$(su -s /bin/bash vncuser -c 'DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus" timeout 5 dbus-send --session --print-reply --dest=org.freedesktop.secrets /org/freedesktop/secrets org.freedesktop.DBus.Peer.Ping' 2>&1)" || secret_status=$?
elapsed_ms=$(( ($(date +%s%N) - started_ns) / 1000000 ))
(( secret_status != 0 )) || fail "Secret Service request succeeded: $secret_output"
[[ "$secret_output" == *ServiceUnknown* || "$secret_output" == *"not provided by any .service files"* ]] ||
  fail "Secret Service request failed for an unexpected reason (status $secret_status): $secret_output"
(( elapsed_ms <= 2000 )) || fail "Secret Service request took ${elapsed_ms} ms, expected <= 2000 ms"

printf 'PASS: no keyring prompt/provider process or Secret Service activation; vncuser Secret Service request failed in %s ms: %s\n' "$elapsed_ms" "$secret_output"
KEYRING_CHECKS
