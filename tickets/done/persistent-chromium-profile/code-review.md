# Code Review

## Round 1

Decision: Fail

Finding:

- Severity: Medium
- Files: `docker-compose.yml`, `docker-compose.chrome-vnc.yml`, `run-container.sh`
- Issue: The implementation mounts a Docker volume at `/home/vncuser/.config/chromium`, but no startup step guarantees that a fresh mounted profile directory is writable by `vncuser`. Chromium runs as `vncuser`; if the mounted volume path is root-owned, Chromium may fail to persist cookies/profile state.
- Classification: Local Fix
- Required return path: Stage 6 -> Stage 7 -> Stage 8

Checks completed:

- Changed source line count is well below the workflow hard limit.
- Existing launch behavior and port mappings are preserved.
- No unnecessary abstraction introduced.
- Validation evidence is relevant, but it must be rerun after the ownership fix.

## Round 2

Decision: Pass

Checks:

- Effective changed source lines: 38 insertions across five files, below the workflow hard limit.
- Runtime ownership: `entrypoint.sh` now creates and assigns `/home/vncuser/.config/chromium` to `vncuser:vncuser` before Supervisor starts Chromium.
- Compose entry points: both Compose files mount a named volume at the current Chromium user data directory.
- Script entry point: `run-container.sh` mounts a per-container default volume and supports `--profile-volume` override.
- Existing behavior: VNC, debug ports, image/tag defaults, and automatic Chromium startup remain unchanged.
- Duplication: the mount path is intentionally repeated only at entry-point boundaries; no new abstraction is warranted for this small shell/YAML scope.
- Validation sufficiency: shell syntax, Compose rendering, and stubbed script execution cover the changed behavior without disrupting active containers.

Residual risk:

- Google can still force account re-authentication despite profile persistence. This is documented and outside local Docker control.
