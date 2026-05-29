# Investigation Notes

## Scope Triage

Scope: Small

Reasoning: The browser launch path is centralized in `base.conf`, and the direct run paths are limited to two Compose files plus `run-container.sh`. No application data model or cross-service API change is required.

## Current Behavior

- Chromium is started automatically by Supervisor in `base.conf`.
- Current launch command has no explicit `--user-data-dir`, so Chromium uses its default Linux user data directory for `vncuser`: `/home/vncuser/.config/chromium`.
- The default browser profile exists under `/home/vncuser/.config/chromium/Default` once Chromium starts.
- `docker-compose.yml`, `docker-compose.chrome-vnc.yml`, and `run-container.sh` do not mount that user data directory.
- `run-container.sh` removes any existing same-name container before starting a replacement, which deletes the unmounted Chromium profile.

## Runtime Evidence

Live container checks before this ticket showed:

- `llm-server-0` had `/home/vncuser/.config/chromium/Default`, but `docker inspect` reported no mounts.
- Docker events showed `llm-server-0` was destroyed and recreated on `2026-05-29`.
- Browser logs did not show clear cookie decryption failures.

## Root Cause

The base image does create and use a Chromium profile, but the supported run paths do not persist that profile outside the container filesystem. Container recreation therefore produces a fresh profile that looks like a Google logout.

Google may still force re-authentication for account-security reasons even with a persisted profile, but without profile persistence the system cannot distinguish Google session invalidation from local profile loss.

## Implementation Direction

- Persist `/home/vncuser/.config/chromium`, the current effective Chromium user data directory, rather than moving users to a new path.
- Add a named Docker volume to both Compose entry points.
- Add a default named Docker volume to `run-container.sh`, with an override flag for multi-instance usage.
- Document that downstream images based on this browser image must also mount the same path or configure their own equivalent persistent user-data directory.

