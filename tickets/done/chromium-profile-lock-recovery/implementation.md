# Implementation: Chromium Profile Lock Recovery

## Solution Sketch

Add a small startup helper in `entrypoint.sh` before Supervisor starts. The helper owns only Chromium profile lock recovery for the mounted profile directory:

```text
/home/vncuser/.config/chromium
```

The helper will:

1. Ensure the profile directory exists and remains owned by `vncuser`.
2. Inspect `${CHROMIUM_PROFILE_DIR}/SingletonLock` when present.
3. Preserve the lock and skip cleanup only if the lock target ends in `-<pid>`, `/proc/<pid>` exists in the current container, and the process command appears to be Chromium/Chrome.
4. Otherwise remove only known Chromium lock artifacts:
   - `SingletonLock`
   - `SingletonSocket`
   - `SingletonCookie`
   - `Default/LOCK`
   - `Default/.org.chromium.Chromium.*`
5. Leave all browser data directories and files intact.

This belongs in `entrypoint.sh` rather than the wrapper run script because downstream images inherit the base image startup path. The LLM server image will receive the fix after it rebuilds from the updated base image.

Round 1 review tightened the safety condition: PID existence alone is not sufficient because a stale lock can collide with a reused PID. A non-Chromium live PID is treated as stale.

Implementation detail: process identity checks use `/proc/<pid>/comm` plus argv0 basename only. The helper does not scan the full command line, because an unrelated shell or script can contain the word `chromium` in later arguments.

## Validation Plan

- `bash -n entrypoint.sh`
- Run the cleanup helper in a temporary profile directory with a stale `SingletonLock` and assert known lock artifacts are removed while normal profile data remains.
- Run the cleanup helper with `SingletonLock` pointing at a live local Chromium/Chrome PID and assert the lock artifacts are preserved.
- `docker compose -f docker-compose.yml config`
- `docker compose -f docker-compose.chrome-vnc.yml config`

## Execution Tracking

| Step | Status | Evidence |
| --- | --- | --- |
| Add entrypoint lock recovery helper | Completed | `entrypoint.sh` |
| Document automatic recovery | Completed | `README.md` |
| Shell and behavior validation | Passed | `bash -n entrypoint.sh`; extracted-helper shell cases for stale lock cleanup, non-Chromium PID cleanup, and live Chromium preservation; patched-image startup with stale-lock volume |

## Stage 6 Completion Notes

- Source files changed: `entrypoint.sh`, `README.md`.
- No Chromium profile migration was introduced.
- No backwards-compatible legacy path was retained because this is additive startup recovery.
- Changed source file size remains below the Stage 8 hard limit.
