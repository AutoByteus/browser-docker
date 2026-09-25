#!/usr/bin/env bash
# Usage: verify-server.sh VARIANT IMAGE_REF
# Runs one published AutoByteus server image on a throwaway container (launcher-like env/volumes),
# then checks AC-001/002/003/007 with the base repository runtime contract and the API/E2E probes.
set -uo pipefail
variant="$1"; image="$2"
name="dr002-server-$variant"
prefix="$name-vol"
MAIN=/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base-main-finalize
H=$MAIN/requirements/chromium-keyring-prompt/evidence/api-e2e-rev001-harness
OUT=/tmp/brd-keyring-release
cd "$MAIN"
cleanup() { docker rm -f "$name" >/dev/null 2>&1; for v in workspace data root-home chromium-profile; do docker volume rm "$prefix-$v" >/dev/null 2>&1; done; }
cleanup
echo "=== server $variant $image start_utc=$(date -u +%FT%TZ)"
docker pull -q "$image" >/dev/null || { echo "exit=1 pull failed"; exit 1; }
echo "image: $(docker image inspect -f '{{.Id}} arch={{.Architecture}} created={{.Created}}' "$image")"
echo "\$ docker run -d --name $name (launcher env/volumes, SYS_ADMIN, seccomp=unconfined) $image"
docker run -d --name "$name" \
  -e AUTOBYTEUS_WORKSPACE_ROOT=/app -e AUTOBYTEUS_DATA_DIR=/home/autobyteus/data \
  -e AUTOBYTEUS_BIND_HOST=0.0.0.0 -e AUTOBYTEUS_SERVER_PORT=8000 \
  -e AUTOBYTEUS_SERVER_HOST=http://localhost:8000 -e AUTOBYTEUS_VNC_SERVER_HOSTS=localhost:6080 \
  -e APP_ENV=production -e DB_TYPE=sqlite -e LOG_LEVEL=INFO -e AUTOBYTEUS_SKIP_SYNC=1 \
  -v "$prefix-workspace":/app/autobyteus-server-ts/workspace -v "$prefix-data":/home/autobyteus/data \
  -v "$prefix-root-home":/root -v "$prefix-chromium-profile":/home/vncuser/.config/chromium \
  --cap-add SYS_ADMIN --security-opt seccomp=unconfined "$image" >/dev/null || { echo "exit=1 run failed"; exit 1; }
rc=0
echo "\$ tests/validate-running-container.sh $name $variant"
s=$SECONDS; tests/validate-running-container.sh "$name" "$variant"; r=$?; echo "exit=$r elapsed_s=$((SECONDS-s))"; ((r)) && rc=1
echo "--- supervisorctl status"; docker exec "$name" supervisorctl status
echo "--- server HTTP (in-container) :8000 -> $(docker exec "$name" sh -c 'curl -s -o /dev/null -w %{http_code} --max-time 10 http://127.0.0.1:8000/ || true')"
echo "keyring packages: $(docker exec "$name" sh -c 'dpkg-query -W -f="\${Package} \${Status}\n" gnome-keyring libpam-gnome-keyring evolution-data-server 2>&1 | tr "\n" ";"')"
echo "drop-in: $(docker exec "$name" sh -c 'ls -l /etc/chromium.d/autobyteus-password-store; tail -1 /etc/chromium.d/autobyteus-password-store' | tr '\n' ' ')"
echo "other --password-store in image config: $(docker exec "$name" sh -c 'grep -rl -- "--password-store" /etc/chromium.d /usr/local/bin /etc/supervisor 2>/dev/null | tr "\n" " "')"
for p in probe-operator-view.sh probe-keyring-clients.sh probe-launch-paths.sh; do docker cp "$H/$p" "$name:/tmp/$p" >/dev/null; docker exec "$name" chmod 0755 "/tmp/$p"; done
echo "===== C07 launch paths (real server bridge /usr/local/bin/open-vnc-browser-url.sh shipped in the image) ====="
docker exec "$name" /tmp/probe-launch-paths.sh; r=$?; echo "exit=$r"; ((r)) && rc=1
echo "===== C09 operator view ====="
docker exec "$name" /tmp/probe-operator-view.sh /tmp/dr002-operator-view.png; r=$?; echo "exit=$r"; ((r)) && rc=1
docker cp "$name:/tmp/dr002-operator-view.png" "$OUT/delivery-dr002-server-$variant-operator-view.png" >/dev/null 2>&1 && echo "screenshot copied: delivery-dr002-server-$variant-operator-view.png"
echo "===== C10 keyring clients ====="
docker exec "$name" /tmp/probe-keyring-clients.sh; r=$?; echo "exit=$r"; ((r)) && rc=1
cleanup
echo "RESULT server $variant rc=$rc end_utc=$(date -u +%FT%TZ)"
exit $rc
