# Future-State Runtime Call Stack: Chromium Profile Lock Recovery

## Normal Container Startup With Clean Profile

1. Docker starts the browser image or a downstream image based on it.
2. `/entrypoint.sh` runs as root.
3. `entrypoint.sh` creates and owns `/home/vncuser/.config/chromium` for `vncuser`.
4. `entrypoint.sh` calls the Chromium profile lock recovery helper.
5. Helper finds no lock artifacts and exits without modifying profile data.
6. `entrypoint.sh` clears stale DBus/X artifacts as before.
7. Supervisor starts DBus, VNC, XFCE, optional fcitx, and Chromium.
8. Chromium opens `/home/vncuser/.config/chromium` normally.

## Recreated Container With Stale Chromium Locks

1. User runs the supported destroy/recreate flow while preserving the Chromium profile volume.
2. Docker mounts the existing volume at `/home/vncuser/.config/chromium`.
3. `/entrypoint.sh` normalizes ownership.
4. Lock recovery helper sees `SingletonLock`.
5. Helper resolves the lock target text and extracts the trailing PID when available.
6. `/proc/<pid>` does not exist in the new container, or the lock target is malformed/unresolvable.
7. Helper removes only known Chromium lock artifacts:
   - top-level `SingletonLock`, `SingletonSocket`, `SingletonCookie`
   - profile lock files `Default/LOCK`, `Default/.org.chromium.Chromium.*`
8. Supervisor starts Chromium.
9. Chromium recreates its own valid singleton lock files and uses the existing profile data.

## Same Container With Live Chromium Lock

1. `/entrypoint.sh` calls lock recovery helper.
2. Helper sees `SingletonLock` and extracts trailing PID.
3. `/proc/<pid>` exists in the current container.
4. Helper checks the process command name/cmdline.
5. The process appears to be Chromium/Chrome.
6. Helper logs that the lock appears live and skips cleanup.
7. Startup continues without deleting an active profile lock.

## Lock Points At Non-Chromium Live PID

1. `/entrypoint.sh` calls lock recovery helper.
2. Helper sees `SingletonLock` and extracts trailing PID.
3. `/proc/<pid>` exists, but the process command is not Chromium/Chrome.
4. Helper treats the lock as stale and removes only known lock artifacts.
5. Supervisor starts Chromium and Chromium recreates valid lock files.

## Boundaries

- `entrypoint.sh` owns profile preparation and recovery.
- Supervisor still owns process lifecycle.
- Chromium still owns the actual browser profile format and lock regeneration.
- Docker volumes still own persistence across container recreation.
