#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: tests/validate-image.sh IMAGE [default|zh] [EXPECTED_UID] [EXPECTED_GID]

Validates the built image without starting its normal Supervisor entrypoint.
EOF
  exit 2
}

image="${1:-}"
variant="${2:-default}"
expected_uid="${3:-1000}"
expected_gid="${4:-1000}"

[[ -n "$image" ]] || usage
[[ "$variant" == "default" || "$variant" == "zh" ]] || usage
[[ "$expected_uid" =~ ^[0-9]+$ ]] || usage
[[ "$expected_gid" =~ ^[0-9]+$ ]] || usage

docker image inspect "$image" >/dev/null

docker run --rm -i --entrypoint /bin/bash \
  -e EXPECTED_VARIANT="$variant" \
  -e EXPECTED_UID="$expected_uid" \
  -e EXPECTED_GID="$expected_gid" \
  "$image" -s <<'CONTAINER_CHECKS'
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

. /etc/os-release
[[ "$ID" == "ubuntu" ]] || fail "ID is '$ID', expected ubuntu"
[[ "$VERSION_ID" == "24.04" ]] || fail "VERSION_ID is '$VERSION_ID', expected 24.04"
[[ "${VERSION_CODENAME:-}" == "noble" ]] || fail "VERSION_CODENAME is '${VERSION_CODENAME:-}', expected noble"

[[ "$IMAGE_VARIANT" == "$EXPECTED_VARIANT" ]] || fail "IMAGE_VARIANT is '$IMAGE_VARIANT', expected '$EXPECTED_VARIANT'"
[[ "$USER_UID" == "$EXPECTED_UID" ]] || fail "USER_UID is '$USER_UID', expected '$EXPECTED_UID'"
[[ "$USER_GID" == "$EXPECTED_GID" ]] || fail "USER_GID is '$USER_GID', expected '$EXPECTED_GID'"
[[ "$(id -u vncuser)" == "$EXPECTED_UID" ]] || fail "vncuser UID mismatch"
[[ "$(id -g vncuser)" == "$EXPECTED_GID" ]] || fail "vncuser GID mismatch"
[[ "$XDG_RUNTIME_DIR" == "/run/user/$EXPECTED_UID" ]] || fail "XDG_RUNTIME_DIR is '$XDG_RUNTIME_DIR'"
[[ "$(stat -c %u /run/user/$EXPECTED_UID)" == "$EXPECTED_UID" ]] || fail "runtime directory owner UID mismatch"
[[ "$(stat -c %g /run/user/$EXPECTED_UID)" == "$EXPECTED_GID" ]] || fail "runtime directory owner GID mismatch"

python3_version="$(python3 --version 2>&1)"
python_version="$(python --version 2>&1)"
[[ "$python3_version" == Python\ 3.13.* ]] || fail "public python3 is '$python3_version', expected Python 3.13"
[[ "$python_version" == Python\ 3.13.* ]] || fail "public python is '$python_version', expected Python 3.13"
[[ "$(command -v python3)" == "/usr/local/bin/python3" ]] || fail "public python3 command is '$(command -v python3)'"
[[ "$(command -v python)" == "/usr/local/bin/python" ]] || fail "public python command is '$(command -v python)'"
[[ "$(readlink -f /usr/local/bin/python3)" == "/usr/bin/python3.13" ]] || fail "public python3 does not resolve to /usr/bin/python3.13"
[[ "$(readlink -f /usr/local/bin/python)" == "/usr/bin/python3.13" ]] || fail "public python does not resolve to /usr/bin/python3.13"

os_python_version="$(/usr/bin/python3 --version 2>&1)"
[[ "$os_python_version" == Python\ 3.12.* ]] || fail "Noble OS /usr/bin/python3 is '$os_python_version'"
[[ "$(readlink -f /usr/bin/python3)" == "/usr/bin/python3.12" ]] || fail "/usr/bin/python3 no longer resolves to Noble's distribution Python 3.12"
[[ ! -e /usr/bin/python ]] || fail "unexpected /usr/bin/python selector exists"

dpkg-query -W -f='${db:Status-Status}\n' \
  python3 python3.12 python3.13 libpython3.13-stdlib libpython3.13-dev python3.13-dev python3.13-venv | grep -qv '^$'
dpkg-query -S /usr/bin/python3.12 | grep -q '^python3.12-minimal:'
dpkg-query -S /usr/bin/python3.13 | grep -q '^python3.13:'
python313_package_version="$(dpkg-query -W -f='${Version}' python3.13)"
[[ "$python313_package_version" == *noble* ]] || fail "python3.13 package version '$python313_package_version' does not identify Noble"
grep -Rqi 'ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null || fail "Deadsnakes APT source is missing"
deadsnakes_noble_source=false
while IFS= read -r source_file; do
  if grep -qiE 'Suites:[[:space:]]+noble|[[:space:]]noble([[:space:]-]|$)' "$source_file"; then
    deadsnakes_noble_source=true
    break
  fi
done < <(grep -Ril 'ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null)
[[ "$deadsnakes_noble_source" == true ]] || fail "Deadsnakes source is not configured for Noble"
grep -RqiE 'Suites:[[:space:]]+noble|[[:space:]]noble([[:space:]-]|$)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null || fail "Noble Ubuntu APT source not found"

[[ -x /opt/browser-tools/bin/python ]] || fail "isolated browser-tools Python is missing"
[[ "$(/opt/browser-tools/bin/python --version 2>&1)" == Python\ 3.13.* ]] || fail "browser-tools does not use Python 3.13"
[[ "$(command -v supervisord)" == "/usr/local/bin/supervisord" ]] || fail "supervisord public command is not /usr/local/bin/supervisord"
[[ "$(command -v supervisorctl)" == "/usr/local/bin/supervisorctl" ]] || fail "supervisorctl public command is not /usr/local/bin/supervisorctl"
[[ "$(readlink -f /usr/local/bin/supervisord)" == "/opt/browser-tools/bin/supervisord" ]] || fail "supervisord public command is not isolated"
[[ "$(readlink -f /usr/local/bin/supervisorctl)" == "/opt/browser-tools/bin/supervisorctl" ]] || fail "supervisorctl public command is not isolated"
[[ "$(readlink -f /usr/local/bin/websockify)" == "/opt/browser-tools/bin/websockify" ]] || fail "websockify public command is not isolated"
[[ "$(readlink -f /usr/local/bin/uv)" == "/opt/browser-tools/bin/uv" ]] || fail "uv public command is not isolated"
[[ -d "$(readlink -f /usr/local/share/websockify)" ]] || fail "stable websockify data link is broken"
/opt/browser-tools/bin/python -c 'import importlib.metadata, sys, supervisor, uv, websockify; assert sys.prefix == "/opt/browser-tools"; assert sys.version_info[:2] == (3, 13); assert importlib.metadata.version("supervisor") == "4.3.0"; assert importlib.metadata.version("websockify"); assert importlib.metadata.version("uv")'
[[ "$(supervisord --version)" == "4.3.0" ]] || fail "Supervisor is not 4.3.0"
! dpkg-query -W -f='${db:Status-Status}' supervisor 2>/dev/null | grep -q 'installed' || fail "apt Supervisor provider is installed"
! dpkg-query -S /usr/bin/supervisord >/dev/null 2>&1 || fail "/usr/bin/supervisord has a distribution package owner"
websockify --help >/dev/null
uv --version | grep -Eq '^uv [0-9]'

[[ "$(node --version)" == v22.* ]] || fail "Node.js is not major version 22"
yarn --version | grep -Eq '^[0-9]+'
gh --version | head -n 1 | grep -Eq '^gh version [0-9]'
for command_name in chromium Xvnc startxfce4 supervisorctl socat copyq git gh go jq rg xdotool xclip; do
  command -v "$command_name" >/dev/null || fail "documented/preserved utility '$command_name' is unavailable"
done
locale -a | grep -qi '^en_US\.utf8$' || fail "en_US.UTF-8 locale is missing"

if [[ "$EXPECTED_VARIANT" == "zh" ]]; then
  for package_name in fonts-noto-cjk fonts-noto-color-emoji fonts-wqy-zenhei language-pack-zh-hans language-pack-zh-hant fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk3 fcitx5-frontend-qt5 fcitx5-config-qt im-config; do
    dpkg-query -W -f='${db:Status-Status}' "$package_name" 2>/dev/null | grep -q 'installed' || fail "zh package '$package_name' is missing"
  done
  locale -a | grep -qi '^zh_CN\.utf8$' || fail "zh_CN.UTF-8 locale is missing"
  locale -a | grep -qi '^zh_TW\.utf8$' || fail "zh_TW.UTF-8 locale is missing"
  grep -q '^Default Layout=us$' /home/vncuser/.config/fcitx5/profile || fail "US layout is not configured as the default layout"
  grep -A3 '^\[Groups/0/Items/0\]$' /home/vncuser/.config/fcitx5/profile | grep -q '^Default=True$' || fail "English input item is not default"
  grep -A1 '^\[Groups/0/Items/1\]$' /home/vncuser/.config/fcitx5/profile | grep -q '^Name=pinyin$' || fail "Pinyin input item is missing"
else
  ! dpkg-query -W -f='${db:Status-Status}' fcitx5 2>/dev/null | grep -q 'installed' || fail "default image unexpectedly contains fcitx5"
fi

printf 'PASS: image identity, public/OS Python ownership, isolated Supervisor/tool origin, utility, locale, variant, and UID/GID contracts validated.\n'
CONTAINER_CHECKS
