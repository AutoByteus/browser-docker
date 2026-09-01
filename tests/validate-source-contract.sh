#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local pattern="$1"
  local path="$2"
  grep -Eq -- "$pattern" "$path" || fail "$path does not contain expected pattern: $pattern"
}

assert_not_contains() {
  local pattern="$1"
  shift
  if grep -Ein -- "$pattern" "$@"; then
    fail "active source contains obsolete pattern: $pattern"
  fi
}

first_from="$(awk 'toupper($1) == "FROM" { print $2; exit }' Dockerfile)"
[[ "$first_from" == "ubuntu:24.04" ]] || fail "first effective Dockerfile base is '$first_from', expected ubuntu:24.04"

[[ "$(tr -d '\r\n' < VERSION)" == "1.4.0" ]] || fail "VERSION must be 1.4.0"

assert_not_contains 'ubuntu:22\.04|Ubuntu 22\.04|python3\.11|deadsnakes' \
  Dockerfile base.conf entrypoint.sh README.md build-multi-arch.sh

assert_contains 'python3-dev' Dockerfile
assert_contains 'python3-pip' Dockerfile
assert_contains 'python3-venv' Dockerfile
assert_contains 'python-is-python3' Dockerfile
assert_contains 'python3 -m venv /opt/browser-tools' Dockerfile
assert_contains '/opt/browser-tools/bin/python -m pip install websockify uv' Dockerfile
assert_contains 'ln -s /opt/browser-tools/bin/websockify /usr/local/bin/websockify' Dockerfile
assert_contains 'ln -s /opt/browser-tools/bin/uv /usr/local/bin/uv' Dockerfile
assert_contains '/usr/local/share/websockify' Dockerfile
assert_contains 'websockify --web=/usr/local/share/websockify 6080 localhost:5900' base.conf

assert_contains 'ENV XDG_RUNTIME_DIR=/run/user/\$\{USER_UID\}' Dockerfile
assert_contains 'XDG_RUNTIME_DIR="%\(ENV_XDG_RUNTIME_DIR\)s"' base.conf
assert_contains 'DBUS_SESSION_BUS_ADDRESS="unix:path=%\(ENV_XDG_RUNTIME_DIR\)s/bus"' base.conf
assert_contains 'XDG_RUNTIME_DIR:-/run/user/\$\{USER_UID:-1000\}' entrypoint.sh

assert_contains 'PLATFORMS="linux/amd64,linux/arm64"' build-multi-arch.sh
assert_contains 'arm64\|aarch64\)' build-multi-arch.sh
assert_contains 'TAG_PRIMARY="\$IMAGE_NAME:\$VERSION"' build-multi-arch.sh
assert_contains 'TAG_SECONDARY="\$IMAGE_NAME:latest"' build-multi-arch.sh
assert_contains 'TAG_PRIMARY="\$IMAGE_NAME:\$\{VERSION\}-\$\{VARIANT\}"' build-multi-arch.sh
assert_contains 'TAG_SECONDARY="\$IMAGE_NAME:\$VARIANT"' build-multi-arch.sh
assert_contains 'EXPOSE 5900 6080 9223' Dockerfile

assert_contains "Canonical's official minimal Ubuntu 24\.04 LTS OCI base" README.md
assert_contains 'Ubuntu-native Python 3\.12, Node\.js 22, and Yarn' README.md
assert_contains 'default \(English\) image and a `zh` variant' README.md
assert_contains 'linux/amd64' build-multi-arch.sh
assert_contains 'linux/arm64' build-multi-arch.sh

printf 'PASS: source, build, release, runtime-path, port, and documentation contracts are consistent.\n'
