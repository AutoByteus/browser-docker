#!/usr/bin/env bash
# Reproduction probe for autobyteus-596 (investigation, 2026-11-21).
# Usage: x11-takeover-restart-probe.sh IMAGE CONTAINER_NAME
# Starts a THROWAWAY container (label autobyteus-596=throwaway) with the run flags of
# run-container.sh / the server compose file, lets a root X server (Xvnc :102) take
# over /tmp/.X11-unix, then checks (1) in-life: Supervisor restarting Xvnc :99 and
# (2) `docker restart`. Never point it at a founder container; it removes CONTAINER_NAME first.
set -u
IMG=$1; C=$2
case "$C" in autobyteus-server-*) echo "refusing: $C looks like a real node" >&2; exit 2 ;; esac
docker rm -f "$C" >/dev/null 2>&1
docker run -d --name "$C" --label autobyteus-596=throwaway --cap-add SYS_ADMIN --security-opt seccomp=unconfined "$IMG" >/dev/null
wait_all() {
  for i in $(seq 1 60); do
    s=$(docker exec "$C" supervisorctl status 2>/dev/null); ok=1
    for p in tigervnc xfce copyq chrome websockify; do grep -Eq "^$p +RUNNING" <<<"$s" || ok=0; done
    [ $ok = 1 ] && { echo "ALL RUNNING after ${i}x2s"; return 0; }
    sleep 2
  done
  echo "NOT ALL RUNNING:"; grep -E "tigervnc|xfce|copyq|chrome" <<<"$s"; return 1
}
echo "== fresh start"; wait_all; docker exec "$C" ls -ld /tmp/.X11-unix
echo "== root Xvnc :102 takes the dir"
docker exec "$C" bash -c 'Xvnc :102 -SecurityTypes=None -rfbport 5902 >/tmp/x102.log 2>&1 & sleep 3; ls -ld /tmp/.X11-unix'
echo "== in-life: kill Xvnc :99, Supervisor restarts it"
docker exec "$C" pkill -u vncuser -x Xvnc; sleep 3
for i in $(seq 1 15); do docker exec "$C" supervisorctl status tigervnc | grep -q RUNNING && break; sleep 2; done
docker exec "$C" supervisorctl status tigervnc
echo "== container restart"; docker restart "$C" >/dev/null; wait_all; docker exec "$C" ls -ld /tmp/.X11-unix
echo -n "X11-unix chmod failures in supervisord.log: "
docker exec "$C" grep -c "changing permissions of '/tmp/.X11-unix'" /var/log/supervisor/supervisord.log
