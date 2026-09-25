#!/usr/bin/env bash
# Usage: run-matrix-target.sh TARGET PLATFORM VARIANT UID GID
# C04 image contract + C05 runtime contract for one built image, using the repository scripts unchanged.
set -uo pipefail
target="$1"; platform="$2"; variant="$3"; uid="$4"; gid="$5"
WT=/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt
EV=$WT/requirements/chromium-keyring-prompt/evidence
image="autobyteus/chrome-vnc:api-e2e-keyring-$target"
container="api-e2e-keyring-$target"
volume="$container-profile"
cd "$WT"
{
  echo "target=$target platform=$platform variant=$variant uid=$uid gid=$gid image=$image id=$(docker image inspect -f '{{.Id}} arch={{.Architecture}}' "$image")"
  echo "tests sha256: validate-image.sh=$(shasum -a 256 tests/validate-image.sh | cut -c1-16) validate-running-container.sh=$(shasum -a 256 tests/validate-running-container.sh | cut -c1-16)"
  echo "=== C04 \$ tests/validate-image.sh $image $variant $uid $gid   start_utc=$(date -u +%FT%TZ)"
  start=$SECONDS; tests/validate-image.sh "$image" "$variant" "$uid" "$gid"; echo "exit=$? elapsed_s=$((SECONDS-start))"
} > "$EV/api-e2e-rev001-image-$target.log" 2>&1
{
  echo "target=$target platform=$platform variant=$variant uid=$uid image=$image"
  docker rm -f "$container" >/dev/null 2>&1; docker volume rm "$volume" >/dev/null 2>&1
  echo "\$ docker run -d --name $container --platform $platform --cap-add SYS_ADMIN --security-opt seccomp=unconfined -v $volume:/home/vncuser/.config/chromium $image   start_utc=$(date -u +%FT%TZ)"
  docker run -d --name "$container" --platform "$platform" --cap-add SYS_ADMIN --security-opt seccomp=unconfined -v "$volume":/home/vncuser/.config/chromium "$image"
  echo "=== C05 \$ tests/validate-running-container.sh $container $variant $uid"
  start=$SECONDS; tests/validate-running-container.sh "$container" "$variant" "$uid"; echo "exit=$? elapsed_s=$((SECONDS-start))"
  echo "chromium: $(docker exec "$container" chromium --version 2>/dev/null)"
  echo "end_utc=$(date -u +%FT%TZ)"
} > "$EV/api-e2e-rev001-runtime-$target.log" 2>&1
grep -hE '^(PASS|FAIL|exit=)' "$EV/api-e2e-rev001-image-$target.log" "$EV/api-e2e-rev001-runtime-$target.log"
