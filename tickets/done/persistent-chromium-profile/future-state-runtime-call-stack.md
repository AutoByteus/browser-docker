# Future-State Runtime Call Stack

## UC-001: Compose Launch Uses Persistent Chromium Profile

1. User runs `docker compose -f docker-compose.yml up -d` or `docker compose -f docker-compose.chrome-vnc.yml up -d`.
2. Docker Compose creates or reuses the named Chromium profile volume.
3. Docker mounts that volume at `/home/vncuser/.config/chromium`.
4. `/entrypoint.sh` starts Supervisor.
5. Supervisor starts Chromium through `base.conf`.
6. Chromium reads and writes its default user data under `/home/vncuser/.config/chromium`.
7. Container removal/recreation no longer deletes that profile because Docker owns the volume separately from the container filesystem.

## UC-002: Script Launch Uses Persistent Chromium Profile

1. User runs `./run-container.sh`.
2. Script parses optional arguments, including `--profile-volume` when provided.
3. Script stops/removes a same-name container if present.
4. Script starts a new container with `-v <profile-volume>:/home/vncuser/.config/chromium`.
5. Chromium starts normally and writes profile state to the mounted volume.
6. Later script reruns reuse the same volume unless the user supplies a different volume name.

## UC-003: Multi-Instance Profile Separation

1. User starts a second long-lived browser container with a separate name.
2. User passes `--profile-volume <unique-volume-name>`.
3. Docker mounts that unique volume at `/home/vncuser/.config/chromium`.
4. Browser sessions remain isolated by volume.

## Boundary Notes

- Docker owns profile persistence, not Chromium.
- Chromium keeps its current implicit profile path.
- Google account re-authentication policy remains external behavior.
- Downstream images based on this image need equivalent mounts in their own launch scripts or Compose files.

