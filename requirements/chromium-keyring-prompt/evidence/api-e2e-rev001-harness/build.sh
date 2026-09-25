#!/usr/bin/env bash
# Usage: build.sh PLATFORM VARIANT TAGSUFFIX [UID GID]
set -uo pipefail
platform="$1"; variant="$2"; suffix="$3"; uid="${4:-}"; gid="${5:-}"
SRC=/tmp/api-e2e-keyring-src-6d4aa75
EV=/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/evidence
tag="autobyteus/chrome-vnc:api-e2e-keyring-$suffix"
log="$EV/api-e2e-rev001-build-$suffix.log"
extra=()
[[ -n "$uid" ]] && extra+=(--build-arg "USER_UID=$uid" --build-arg "USER_GID=$gid")
{
  echo "purpose=API-REV-001 independent clean build from source commit 6d4aa757b16279449e5c7e2b3ca198789b0f9deb (git archive -> $SRC)"
  echo "start_utc=$(date -u +%FT%TZ) platform=$platform variant=$variant tag=$tag extra=${extra[*]:-none}"
  echo "\$ docker buildx build --builder multi-platform-builder --load --no-cache --progress=plain --platform $platform --tag $tag --build-arg IMAGE_VARIANT=$variant ${extra[*]:-} $SRC"
  start=$SECONDS
  docker buildx build --builder multi-platform-builder --load --no-cache --progress=plain \
    --platform "$platform" --tag "$tag" --build-arg IMAGE_VARIANT="$variant" ${extra[@]+"${extra[@]}"} "$SRC" 2>&1
  rc=$?
  echo "exit=$rc elapsed_s=$((SECONDS-start))"
  docker image inspect "$tag" --format 'image_id={{.Id}} arch={{.Architecture}} created={{.Created}}' 2>&1
  echo "end_utc=$(date -u +%FT%TZ)"
} > "$log" 2>&1
echo "$suffix exit=$rc" >> /tmp/api-e2e-keyring/build-status.txt
