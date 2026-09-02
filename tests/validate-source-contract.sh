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

assert_literal_line() {
  local expected_line="$1"
  local path="$2"
  grep -Fqx -- "$expected_line" "$path" || fail "$path does not contain expected literal line: $expected_line"
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

assert_not_contains 'ubuntu:22\.04|Ubuntu 22\.04|python3\.11' \
  Dockerfile base.conf entrypoint.sh README.md build-multi-arch.sh

assert_contains 'add-apt-repository -y ppa:deadsnakes/ppa' Dockerfile
assert_literal_line "    python3.13 \\" Dockerfile
assert_literal_line "    python3.13-dev \\" Dockerfile
assert_literal_line "    python3.13-venv \\" Dockerfile
assert_contains '^[[:space:]]+gh[[:space:]]' Dockerfile
assert_literal_line "RUN ln -s /usr/bin/python3.13 /usr/local/bin/python3 && \\" Dockerfile
assert_literal_line "    ln -s /usr/bin/python3.13 /usr/local/bin/python && \\" Dockerfile
assert_contains '/usr/bin/python3\.13 -m venv /opt/browser-tools' Dockerfile
assert_contains '/opt/browser-tools/bin/python -m pip install supervisor==4\.3\.0 websockify uv' Dockerfile
assert_contains 'ln -s /opt/browser-tools/bin/supervisord /usr/local/bin/supervisord' Dockerfile
assert_contains 'ln -s /opt/browser-tools/bin/supervisorctl /usr/local/bin/supervisorctl' Dockerfile
assert_contains 'ln -s /opt/browser-tools/bin/websockify /usr/local/bin/websockify' Dockerfile
assert_contains 'ln -s /opt/browser-tools/bin/uv /usr/local/bin/uv' Dockerfile
assert_contains '/usr/local/share/websockify' Dockerfile
assert_contains 'websockify --web=/usr/local/share/websockify 6080 localhost:5900' base.conf
assert_contains 'exec /usr/local/bin/supervisord -n -c /etc/supervisor/supervisord\.conf' entrypoint.sh

assert_not_contains 'python3\.12-dev|python3\.12-venv|python3-pip|python3-dev|python3-venv|python-is-python3' Dockerfile
assert_not_contains 'update-alternatives|/usr/bin/supervisord|python3 -m pip|pip3 install' \
  Dockerfile entrypoint.sh base.conf
assert_not_contains '^[[:space:]]+supervisor([[:space:]\\]|$)' Dockerfile
assert_not_contains '/usr/local/(lib|share)/python3\.[0-9]+' Dockerfile base.conf entrypoint.sh

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
assert_contains 'Python 3\.13 developer runtime, Supervisor 4\.3\.0' README.md
assert_contains 'GitHub CLI, Node\.js 22, and Yarn' README.md
assert_contains 'default \(English\) image and a `zh` variant' README.md
assert_contains 'linux/amd64' build-multi-arch.sh
assert_contains 'linux/arm64' build-multi-arch.sh

printf 'PASS: source, build, release, runtime-path, port, and documentation contracts are consistent.\n'
