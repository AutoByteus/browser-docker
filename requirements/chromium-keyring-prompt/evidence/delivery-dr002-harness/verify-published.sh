#!/usr/bin/env bash
# Usage: verify-published.sh VARIANT PLATFORM CHILD_DIGEST
# Pulls one exact published child manifest, then runs the repository image and runtime contracts unchanged.
set -uo pipefail
variant="$1"; platform="$2"; digest="$3"
arch="${platform#linux/}"
repo=autobyteus/chrome-vnc
tag="$repo:dr002-published-$variant-$arch"
container="dr002-published-$variant-$arch"
volume="$container-profile"
MAIN=/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base-main-finalize
cd "$MAIN"
echo "=== $variant $platform $repo@$digest  start_utc=$(date -u +%FT%TZ)  main=$(git rev-parse --short HEAD)"
echo "\$ docker pull --platform $platform $repo@$digest"
docker pull -q --platform "$platform" "$repo@$digest" || { echo "exit=1 pull failed"; exit 1; }
docker tag "$repo@$digest" "$tag"
echo "image: $(docker image inspect -f '{{.Id}} os={{.Os}} arch={{.Architecture}}' "$tag")"
echo "\$ tests/validate-image.sh $tag $variant"
s=$SECONDS; tests/validate-image.sh "$tag" "$variant"; rc_img=$?; echo "exit=$rc_img elapsed_s=$((SECONDS-s))"
docker rm -f "$container" >/dev/null 2>&1; docker volume rm "$volume" >/dev/null 2>&1
echo "\$ docker run -d --name $container --platform $platform --cap-add SYS_ADMIN --security-opt seccomp=unconfined -v $volume:/home/vncuser/.config/chromium $tag"
docker run -d --name "$container" --platform "$platform" --cap-add SYS_ADMIN --security-opt seccomp=unconfined -v "$volume":/home/vncuser/.config/chromium "$tag" >/dev/null
echo "\$ tests/validate-running-container.sh $container $variant"
s=$SECONDS; tests/validate-running-container.sh "$container" "$variant"; rc_run=$?; echo "exit=$rc_run elapsed_s=$((SECONDS-s))"
echo "chromium: $(docker exec "$container" chromium --version 2>/dev/null)"
echo "keyring packages: $(docker exec "$container" sh -c 'dpkg-query -W -f="\${Package} \${Status}\n" gnome-keyring libpam-gnome-keyring evolution-data-server 2>&1 | tr "\n" ";"')"
echo "drop-in: $(docker exec "$container" cat /etc/chromium.d/autobyteus-password-store | tail -1)"
docker rm -f "$container" >/dev/null 2>&1; docker volume rm "$volume" >/dev/null 2>&1
echo "RESULT $variant $platform image=$rc_img runtime=$rc_run end_utc=$(date -u +%FT%TZ)"
[[ $rc_img -eq 0 && $rc_run -eq 0 ]]
