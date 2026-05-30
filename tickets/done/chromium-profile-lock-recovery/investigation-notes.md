# Investigation Notes: Chromium Profile Lock Recovery

## Repository / Base Image

- Correct base-image repository: `/home/ryan-ai/SSD/autobyteus_org_workspace/browser-docker`.
- The underscore path `../browser_docker` does not exist in this workspace.
- `../browser-docker-persistent-chromium-profile` exists as an older ticket worktree for the prior persistent-profile change, but the active base repo is `../browser-docker`.

## Current Startup Path

- `Dockerfile` installs `chromium`, `supervisor`, VNC, XFCE, and optional `fcitx5` for the `zh` variant.
- `entrypoint.sh` runs as root, prepares runtime directories, normalizes `/home/vncuser/.config/chromium` ownership, clears stale DBus and X display artifacts, then starts Supervisor.
- `base.conf` starts Chromium through Supervisor as `vncuser` with Chromium's default user data directory, which is `/home/vncuser/.config/chromium`.
- Persistent-profile support from the previous ticket mounts a Docker volume at `/home/vncuser/.config/chromium` for Compose and `run-container.sh`.

## Reproduced / Observed Failure

During the local LLM server update from `v1.0.13` to `v1.0.14`, the recreated downstream container mounted the same Chromium profile volume. Chromium failed with:

```text
The profile appears to be in use by another Chromium process (...) on another computer (...)
```

Observed stale artifacts in the mounted profile:

```text
/home/vncuser/.config/chromium/SingletonLock -> <old-container-hostname>-<old-pid>
/home/vncuser/.config/chromium/SingletonSocket -> /tmp/org.chromium.Chromium.../SingletonSocket
/home/vncuser/.config/chromium/SingletonCookie
/home/vncuser/.config/chromium/Default/LOCK
/home/vncuser/.config/chromium/Default/.org.chromium.Chromium.*
```

After removing those lock artifacts and recreating the container, Chromium started successfully with the same persisted profile.

## Ownership / Safety Boundary

- The owning layer is the base image entrypoint, because all downstream images inherit the Chromium startup behavior.
- The cleanup must run before Supervisor starts Chromium.
- It is safe to remove Chromium lock artifacts when no live Chromium/Chrome PID owns the `SingletonLock`.
- It is not safe to remove `SingletonLock` when it points to a live Chromium/Chrome PID in the current container, because that can corrupt an actually active profile.
- The cleanup must not delete profile data such as `Default/`, cookies, preferences, cache, local storage, or extension data.

## Scope Triage

Scope: Small.

Reasoning: This is a focused startup guard in `entrypoint.sh` plus documentation and lightweight shell validation. It does not change Docker image architecture, profile path, supervisor ownership, or browser launch semantics.
