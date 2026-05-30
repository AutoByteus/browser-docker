# Requirements: Chromium Profile Lock Recovery

## Status

Design-ready

## User Intent

When a user removes and recreates a container that persists `/home/vncuser/.config/chromium`, Chromium can refuse to start because stale profile lock files still point at a process from the removed container. The supported run paths should recover from stale Chromium profile locks automatically so users are not left with a running container whose browser process is dead.

The base image repository is `../browser-docker` (hyphenated path), not `../browser_docker`.

## Requirements

| ID | Requirement |
| --- | --- |
| R-001 | Detect and recover stale Chromium profile lock files before Chromium starts. |
| R-002 | Do not remove profile locks when the lock appears to belong to a live Chromium process in the current container. |
| R-003 | Keep persistent Chromium profile data, cookies, preferences, and user files intact. |
| R-004 | Preserve existing VNC, noVNC, debug-port, profile-volume, and supervisor behavior. |
| R-005 | Document the automatic recovery behavior and manual fallback for unusual cases. |
| R-006 | Keep the fix in the base image startup path so downstream images inherit it after rebuild/release. |

## Acceptance Criteria

| ID | Covers | Acceptance Criterion |
| --- | --- | --- |
| AC-001 | R-001, R-003 | Startup removes only known Chromium lock artifacts from `/home/vncuser/.config/chromium` when they are stale. |
| AC-002 | R-002 | Startup refuses to clear `SingletonLock` when it resolves to a live local Chromium/Chrome PID. |
| AC-003 | R-004 | Existing supervisor process layout and run script defaults remain compatible. |
| AC-004 | R-005 | README explains profile-lock recovery and the safety boundary. |
| AC-005 | R-006 | The change is implemented in `entrypoint.sh`, before Supervisor starts Chromium. |
| AC-006 | R-001, R-002 | Validation covers both stale-lock cleanup and live-lock preservation without requiring a destructive browser-profile reset. |

## Out Of Scope

- Solving Google account re-authentication policies.
- Deleting or resetting user browser profile data.
- Changing the Chromium user-data directory.

## Coverage Map

| Requirement | Acceptance Criteria |
| --- | --- |
| R-001 | AC-001, AC-006 |
| R-002 | AC-002, AC-006 |
| R-003 | AC-001 |
| R-004 | AC-003 |
| R-005 | AC-004 |
| R-006 | AC-005 |
