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

[[ "$(tr -d '\r\n' < VERSION)" == "1.4.2" ]] || fail "VERSION must be 1.4.2"

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

# No OS keyring: the package set purges the interactive provider inside the
# install layer, and one /etc/chromium.d drop-in owns Chromium's password store.
password_store_dropin='chromium.d/autobyteus-password-store'
password_store_export='export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --password-store=basic"'
purge_line='    apt-get purge -y gnome-keyring libpam-gnome-keyring && \'
assert_literal_line "$purge_line" Dockerfile
PURGE_LINE="$purge_line" awk '
  $0 == ENVIRON["PURGE_LINE"] { getline next_line; found = 1; exit (next_line == "    apt-get clean && rm -rf /var/lib/apt/lists/*" ? 0 : 1) }
  END { if (!found) exit 1 }
' Dockerfile || fail "keyring purge must directly precede apt-get clean in the package install layer"
assert_literal_line "COPY $password_store_dropin /etc/chromium.d/autobyteus-password-store" Dockerfile
assert_contains 'dos2unix .*/etc/chromium\.d/autobyteus-password-store' Dockerfile
assert_literal_line '    chmod 0644 /etc/chromium.d/autobyteus-password-store' Dockerfile
assert_not_contains 'chmod \+x .*chromium\.d|chown vncuser.*chromium\.d' Dockerfile
[[ "$(grep -Ev '^[[:space:]]*(#|$)' "$password_store_dropin")" == "$password_store_export" ]] ||
  fail "$password_store_dropin must contain only comments and: $password_store_export"
assert_not_contains '--password-store' \
  Dockerfile start-chrome.sh base.conf entrypoint.sh supervisord.conf start-vnc.sh
assert_contains '^exec /usr/bin/chromium ' start-chrome.sh

# The X socket directory is root:root 1777: root sets it at build and at every
# start, and the vncuser launcher changes its mode only when it owns it.
x11_owner_test='if [ -O "$x11_dir" ]; then'
assert_literal_line 'x11_dir="/tmp/.X11-unix"' start-vnc.sh
assert_literal_line "$x11_owner_test" start-vnc.sh
assert_not_contains '^chmod[[:space:]].*(/tmp/\.X11-unix|x11_dir)' start-vnc.sh
X11_OWNER_TEST="$x11_owner_test" awk '
  /chmod/ && /x11_dir|\.X11-unix/ && !/mkdir/ { if (previous != ENVIRON["X11_OWNER_TEST"]) bad = 1; changes++ }
  { previous = $0 }
  END { exit (bad || changes != 1) }
' start-vnc.sh || fail "start-vnc.sh must change the X socket directory mode once, only inside its ownership test"
assert_contains '\[ ! -w "\$x11_dir" \] \|\| \[ ! -k "\$x11_dir" \]' start-vnc.sh
assert_not_contains 'sudo|chown' start-vnc.sh
assert_literal_line 'chown root:root /tmp/.X11-unix' entrypoint.sh
assert_literal_line 'chmod 1777 /tmp/.X11-unix' entrypoint.sh
awk '
  $0 == "chmod 1777 /tmp/.X11-unix" { state = NR }
  /^rm -f .*\/tmp\/\.X11-unix\/X/ { cleanup = NR }
  /^exec \/usr\/local\/bin\/supervisord/ { supervisor = NR }
  END { exit !(state && cleanup && supervisor && state < cleanup && cleanup < supervisor) }
' entrypoint.sh || fail "entrypoint.sh must set the X socket directory state before the stale :99 cleanup and Supervisor"
assert_not_contains 'chown.*\.X11-unix' Dockerfile
assert_contains 'chrome-vnc\.test=throwaway' tests/validate-restart-recovery.sh
awk '/^## Reliable Recovery After Host\/Daemon Restart$/ { in_section = 1; next } /^## / { in_section = 0 } in_section && /\/tmp\/\.X11-unix root:root 1777|`\/tmp\/\.X11-unix` .*root:root/ { found = 1 } END { exit !found }' README.md ||
  fail "README recovery section must state the X socket directory's root:root 1777 state"

assert_contains "Canonical's official minimal Ubuntu 24\.04 LTS OCI base" README.md
assert_contains 'Python 3\.13 developer runtime, Supervisor 4\.3\.0' README.md
assert_contains 'GitHub CLI, Node\.js 22, and Yarn' README.md
assert_contains 'default \(English\) image and a `zh` variant' README.md
assert_contains '^### No OS keyring$' README.md
assert_contains 'gnome-keyring` and `libpam-gnome-keyring' README.md
assert_contains '/etc/chromium\.d/autobyteus-password-store' README.md
assert_contains '--password-store=basic' README.md
assert_contains 'profile volume' README.md
assert_contains 're-login' README.md
assert_contains 'linux/amd64' build-multi-arch.sh
assert_contains 'linux/arm64' build-multi-arch.sh

printf 'PASS: source, build, release, runtime-path, port, no-keyring, X socket directory, and documentation contracts are consistent.\n'
