#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: tests/validate-restart-recovery.sh CONTAINER [default|zh] [EXPECTED_UID]

Proves that the desktop recovers after a root X server in the container has taken
over the X socket directory /tmp/.X11-unix: after a Supervisor restart of Xvnc,
after `docker restart`, and after a kill and start. It restarts and kills the
container, so the container must be a throwaway test container labelled
chrome-vnc.test=throwaway and running the image's normal entrypoint. Each step
runs whatever an earlier one found; every failure prints `FAIL: <step>: ...` and
the script exits 1.
EOF
  exit 2
}

container="${1:-}"
variant="${2:-default}"
expected_uid="${3:-1000}"

[[ -n "$container" ]] || usage
[[ "$variant" == "default" || "$variant" == "zh" ]] || usage
[[ "$expected_uid" =~ ^[0-9]+$ ]] || usage

label="$(docker inspect -f '{{index .Config.Labels "chrome-vnc.test"}}' "$container")"
if [[ "$label" != "throwaway" ]]; then
  printf 'Refusing: container %s is not labelled chrome-vnc.test=throwaway; this check restarts and kills it.\n' "$container" >&2
  exit 2
fi
docker inspect -f '{{.State.Running}}' "$container" | grep -qx true

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
x11_dir=/tmp/.X11-unix
failures=()

fail_step() {
  printf 'FAIL: %s\n' "$*" >&2
  failures+=("$*")
}

x11_state() {
  docker exec -u root "$container" stat -c '%U %G %a' "$x11_dir"
}

expect_x11_state() {
  local step="$1"
  local state
  state="$(x11_state)"
  [[ "$state" == "root root 1777" ]] || fail_step "$step: $x11_dir is '$state', expected 'root root 1777'"
}

# A root X server on its own display, as an agent's xvfb-run or Xvnc would start.
take_over() {
  local step="$1"
  local display_num="$2"
  docker exec -u root -d "$container" Xvnc ":$display_num" -SecurityTypes=None -rfbport "$((5800 + display_num))"
  for _ in $(seq 1 40); do
    docker exec -u root "$container" test -S "$x11_dir/X$display_num" && break
    sleep 0.5
  done
  if ! docker exec -u root "$container" test -S "$x11_dir/X$display_num"; then
    fail_step "$step: root Xvnc :$display_num did not start"
    return
  fi
  local owner
  owner="$(x11_state | cut -d' ' -f1,2)"
  [[ "$owner" == "root root" ]] || fail_step "$step: $x11_dir is '$owner' after a root X server started, expected 'root root'"
  printf 'Root Xvnc :%s runs; %s is %s.\n' "$display_num" "$x11_dir" "$(x11_state)"
}

validate_desktop() {
  local step="$1"
  if ! "$script_dir/validate-running-container.sh" "$container" "$variant" "$expected_uid"; then
    fail_step "$step: the desktop did not recover (validate-running-container.sh failed)"
  fi
}

printf '== Step 1: fresh start\n'
expect_x11_state "fresh start"

printf '== Step 2: a root X server takes over %s\n' "$x11_dir"
take_over "takeover" 150

printf '== Step 3: Supervisor restarts Xvnc :99 in the running container\n'
old_pid="$(docker exec "$container" supervisorctl pid tigervnc || true)"
docker exec -u root "$container" pkill -u vncuser -x Xvnc || true
in_life_state=""
new_pid=""
deadline=$((SECONDS + 120))
while (( SECONDS < deadline )); do
  in_life_state="$(docker exec "$container" supervisorctl status tigervnc 2>&1 || true)"
  new_pid="$(docker exec "$container" supervisorctl pid tigervnc 2>/dev/null || true)"
  if grep -Eq '^tigervnc[[:space:]]+RUNNING' <<<"$in_life_state" && [[ "$new_pid" != "$old_pid" && "$new_pid" != "0" ]]; then
    break
  fi
  grep -Eq '^tigervnc[[:space:]]+FATAL' <<<"$in_life_state" && break
  sleep 2
done
printf '%s\n' "$in_life_state"
if grep -Eq '^tigervnc[[:space:]]+RUNNING' <<<"$in_life_state" && [[ "$new_pid" != "$old_pid" ]]; then
  validate_desktop "in-life restart"
else
  fail_step "in-life restart: tigervnc did not come back RUNNING with a new PID: $in_life_state"
fi

printf '== Step 4: root X server again, then docker restart\n'
take_over "restart takeover" 151
docker restart "$container" >/dev/null
validate_desktop "docker restart"
expect_x11_state "docker restart"
chmod_failures="$(docker exec -u root "$container" grep -c "changing permissions of '$x11_dir'" /var/log/supervisor/supervisord.log || true)"
[[ "${chmod_failures:-0}" == "0" ]] ||
  fail_step "docker restart: supervisord.log has $chmod_failures 'changing permissions of '$x11_dir'' lines"

printf '== Step 5: root X server again, then kill and start\n'
take_over "kill/start takeover" 152
docker kill -s KILL "$container" >/dev/null
docker start "$container" >/dev/null
validate_desktop "kill/start"
expect_x11_state "kill/start"

if (( ${#failures[@]} > 0 )); then
  printf 'FAIL: %s step check(s) failed:\n' "${#failures[@]}" >&2
  printf '  - %s\n' "${failures[@]}" >&2
  exit 1
fi
printf 'PASS: after a root X server took over %s, the desktop recovered after a Supervisor restart of Xvnc, docker restart, and kill/start; %s stayed root root 1777.\n' "$x11_dir" "$x11_dir"
