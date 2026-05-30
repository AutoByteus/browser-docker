# Handoff Summary

## Summary

Implemented stale Chromium profile lock recovery in the `browser-docker` base image. The fix runs in `/entrypoint.sh` before Supervisor starts Chromium, so downstream images inherit the behavior after they rebuild from this base image.

The startup helper removes only known Chromium lock artifacts when stale. It preserves the lock when it points to a live local Chromium/Chrome process, and it does not delete cookies, preferences, local storage, extensions, or other profile data.

## Validation

- `bash -n entrypoint.sh` passed.
- Extracted helper shell tests passed:
  - stale missing-PID lock cleanup
  - non-Chromium live PID cleanup
  - simulated live Chromium lock preservation
- `docker compose -f docker-compose.yml config` passed, with Docker's existing obsolete `version` warning.
- `docker compose -f docker-compose.chrome-vnc.yml config` passed.
- Built `autobyteus/chrome-vnc:profile-lock-recovery-test` locally, mounted a throwaway profile volume seeded with stale lock artifacts, and verified:
  - entrypoint logged stale lock cleanup
  - `chrome`, `tigervnc`, `xfce`, and `websockify` reached RUNNING
  - Chromium recreated `SingletonLock` pointing to a live local `chromium` PID
  - the profile marker `Default/keep.txt` survived
  - the stale `.org.chromium.Chromium.test` artifact was removed
- Throwaway test container, volume, and local image tag were removed after validation.
- `git diff --check` passed.

## Notes

- The active base-image repo is `/home/ryan-ai/SSD/autobyteus_org_workspace/browser-docker`.
- The old-looking sibling worktree `/home/ryan-ai/SSD/autobyteus_org_workspace/browser-docker-persistent-chromium-profile` is not the current base repo.
- The current LLM server container remains running; this work did not disturb it.
- User explicitly confirmed finalization. Ticket archival, commit/push, merge, and release are now in progress.
