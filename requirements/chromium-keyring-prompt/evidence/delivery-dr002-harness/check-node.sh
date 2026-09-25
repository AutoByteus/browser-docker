#!/usr/bin/env bash
# Read-only post-upgrade check of one operator node (no navigation, no profile writes).
# Usage: check-node.sh CONTAINER
set -uo pipefail
c="$1"; rc=0
ok() { printf 'PASS %s: %s\n' "$c" "$*"; }
bad() { printf 'FAIL %s: %s\n' "$c" "$*"; rc=1; }
echo "--- $c image=$(docker inspect -f '{{.Config.Image}} {{.Image}}' "$c") state=$(docker inspect -f '{{.State.Status}} started={{.State.StartedAt}}' "$c")"
for i in $(seq 1 40); do docker exec "$c" supervisorctl status chrome 2>/dev/null | grep -q RUNNING && docker exec "$c" supervisorctl status autobyteus_server 2>/dev/null | grep -q RUNNING && break; sleep 3; done
docker exec "$c" supervisorctl status | sed 's/^/  /'
docker exec "$c" dpkg-query -W -f='${Package} ${db:Status-Status}\n' gnome-keyring libpam-gnome-keyring evolution-data-server 2>/dev/null | grep -q ' installed$' && bad "keyring package installed" || ok "gnome-keyring / libpam-gnome-keyring / evolution-data-server not installed"
docker exec "$c" test -f /etc/chromium.d/autobyteus-password-store && ok "drop-in present" || bad "drop-in missing"
main="$(docker exec "$c" sh -c 'for p in $(pgrep -u vncuser -f "/usr/lib/chromium/chromium "); do cmd=$(tr "\0" " " </proc/$p/cmdline); case " $cmd " in *" --type="*) ;; *) echo "$p $cmd";; esac; done' | head -n1)"
[[ " $main " == *" --password-store=basic "* ]] && ok "Chromium main process carries --password-store=basic (pid ${main%% *})" || bad "Chromium main process flag missing: ${main:0:200}"
procs="$(docker exec "$c" sh -c 'ps -eo comm= | grep -E "^(gnome-keyring-d|gcr-prompter)" || true')"
[[ -z "$procs" ]] && ok "no gnome-keyring-daemon / gcr-prompter process" || bad "keyring processes: $procs"
act="$(docker exec "$c" sh -c "grep -E \"Activating service name='(org.freedesktop.secrets|org.gnome.keyring[^']*|org.freedesktop.impl.portal.Secret)'\" /var/log/supervisor/dbus.err.log 2>/dev/null || true")"
[[ -z "$act" ]] && ok "no Secret Service / keyring / portal Secret activation in session D-Bus log" || bad "activation: $act"
uid="$(docker exec "$c" id -u vncuser)"
out="$(docker exec "$c" sh -c "s=\$(date +%s%N); runuser -u vncuser -- env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus timeout 5 dbus-send --session --print-reply --dest=org.freedesktop.secrets /org/freedesktop/secrets org.freedesktop.DBus.Peer.Ping 2>&1; r=\$?; e=\$(date +%s%N); echo \"rc=\$r ms=\$(( (e-s)/1000000 ))\"")"
ms="$(sed -n 's/.*rc=[0-9]* ms=\([0-9]*\).*/\1/p' <<<"$out")"
grep -q 'ServiceUnknown' <<<"$out" && (( ${ms:-9999} <= 2000 )) && ok "vncuser Secret Service request failed fast (${ms} ms, ServiceUnknown)" || bad "Secret Service request: $out"
code="$(docker exec "$c" sh -c 'curl -s -o /dev/null -w %{http_code} --max-time 10 http://127.0.0.1:8000/graphql -H "content-type: application/json" -d "{\"query\":\"{__typename}\"}" || true')"
[[ "$code" == "200" ]] && ok "server GraphQL answered 200" || bad "server GraphQL http=$code"
echo "RESULT $c rc=$rc"
exit $rc
