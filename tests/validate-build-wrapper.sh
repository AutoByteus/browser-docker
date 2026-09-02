#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local expected="$1"
  local actual="$2"
  [[ "$actual" == *"$expected"* ]] || fail "output does not contain expected text: $expected"
}

assert_not_contains() {
  local rejected="$1"
  local actual="$2"
  [[ "$actual" != *"$rejected"* ]] || fail "output unexpectedly contains: $rejected"
}

fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/build-wrapper-test.XXXXXX")"
fake_bin="$fixture_root/bin"
mkdir -p "$fake_bin"

cat > "$fake_bin/docker" <<'DOCKER_EOF'
#!/usr/bin/env bash
set -u

printf 'CALL' >> "$DOCKER_CALL_LOG"
printf '\t%s' "$@" >> "$DOCKER_CALL_LOG"
printf '\n' >> "$DOCKER_CALL_LOG"

if [[ "${1:-}" == "info" ]]; then
  cat <<'INFO_EOF'
Client: Docker Engine - Community
 Context: desktop-linux
Server:
 Containers: 0
INFO_EOF
  exit 0
fi

if [[ "${1:-}" != "buildx" ]]; then
  printf 'unexpected docker command: %s\n' "$*" >&2
  exit 97
fi

case "${2:-}" in
  version|inspect|use|create)
    exit 0
    ;;
  build)
    if [[ "${FAKE_BUILDX_BUILD_EXIT:-0}" -ne 0 ]]; then
      printf 'simulated BuildX registry push failure\n' >&2
      exit "$FAKE_BUILDX_BUILD_EXIT"
    fi
    exit 0
    ;;
  *)
    printf 'unexpected buildx command: %s\n' "$*" >&2
    exit 98
    ;;
esac
DOCKER_EOF
chmod +x "$fake_bin/docker"

success_log="$fixture_root/push-success.calls"
success_output="$(
  DOCKER_CALL_LOG="$success_log" \
  PATH="$fake_bin:$PATH" \
  ./build-multi-arch.sh --push 2>&1
)"

assert_contains "Image will be pushed to Docker Hub" "$success_output"
assert_contains "Docker BuildX will report any registry authentication or authorization error." "$success_output"
assert_contains "Build completed successfully!" "$success_output"
assert_contains "Multi-architecture image pushed to Docker Hub" "$success_output"
if grep -Fq $'CALL\tinfo' "$success_log"; then
  fail "push path must not parse docker info presentation"
fi
expected_success_call=$'CALL\tbuildx\tbuild\t--push\t--platform\tlinux/amd64,linux/arm64\t--tag\tautobyteus/chrome-vnc:1.4.0\t--tag\tautobyteus/chrome-vnc:latest\t--build-arg\tIMAGE_VARIANT=default\t.'
grep -Fqx -- "$expected_success_call" "$success_log" || fail "successful push did not preserve the default multi-platform BuildX command"

failure_log="$fixture_root/push-failure.calls"
set +e
failure_output="$(
  DOCKER_CALL_LOG="$failure_log" \
  FAKE_BUILDX_BUILD_EXIT=23 \
  PATH="$fake_bin:$PATH" \
  ./build-multi-arch.sh --push --variant zh --no-cache 2>&1
)"
failure_status=$?
set -e

[[ "$failure_status" -eq 23 ]] || fail "wrapper returned $failure_status instead of the BuildX failure status 23"
assert_contains "simulated BuildX registry push failure" "$failure_output"
assert_not_contains "Build completed successfully!" "$failure_output"
assert_not_contains "Multi-architecture image pushed to Docker Hub" "$failure_output"
if grep -Fq $'CALL\tinfo' "$failure_log"; then
  fail "failing push path must not parse docker info presentation"
fi
expected_failure_call=$'CALL\tbuildx\tbuild\t--push\t--no-cache\t--platform\tlinux/amd64,linux/arm64\t--tag\tautobyteus/chrome-vnc:1.4.0-zh\t--tag\tautobyteus/chrome-vnc:zh\t--build-arg\tIMAGE_VARIANT=zh\t.'
grep -Fqx -- "$expected_failure_call" "$failure_log" || fail "failing push did not preserve the zh/no-cache multi-platform BuildX command"

printf 'PASS: modern credential-helper push sessions reach BuildX and BuildX failures propagate without false success.\n'
