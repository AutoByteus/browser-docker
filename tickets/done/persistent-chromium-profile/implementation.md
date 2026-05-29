# Implementation

## Solution Sketch

Persist Chromium's current effective user data directory:

```text
/home/vncuser/.config/chromium
```

The implementation will add Docker-managed named volumes to the repository-owned launch entry points:

- `docker-compose.yml`
- `docker-compose.chrome-vnc.yml`
- `run-container.sh`

For `run-container.sh`, add a `--profile-volume <name>` option with a stable default. This keeps single-container usage simple while allowing users to run multiple long-lived containers with separate browser sessions.

The Chromium Supervisor command should remain unchanged for this ticket. It already uses `/home/vncuser/.config/chromium` implicitly, and changing `--user-data-dir` would create an unnecessary migration risk.

## Validation Plan

- `bash -n run-container.sh`
- `docker compose -f docker-compose.yml config`
- `docker compose -f docker-compose.chrome-vnc.yml config`
- Inspect the rendered run script or shell trace enough to confirm the volume mount is present.

## Execution Tracking

| Step | Status | Evidence |
| --- | --- | --- |
| Add Compose profile volumes | Completed | `docker-compose.yml`, `docker-compose.chrome-vnc.yml` |
| Add `run-container.sh` profile volume support | Completed | `--profile-volume`, `-v "$PROFILE_VOLUME":/home/vncuser/.config/chromium` |
| Add startup profile ownership normalization | Completed | `entrypoint.sh` creates/chowns `/home/vncuser/.config/chromium` before Supervisor starts |
| Document persistence behavior | Completed | `README.md` |
| Shell syntax check | Passed | `bash -n run-container.sh && bash -n entrypoint.sh` |

Stage 6 source implementation is complete after the Stage 8 local-fix re-entry. No source ownership, dependency, or backward-compatibility issue remains in the changed scope.
