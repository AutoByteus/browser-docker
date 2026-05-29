# API/E2E Testing

## Executable Validation Results

| ID | Covers | Command | Result | Evidence |
| --- | --- | --- | --- | --- |
| AV-001 | AC-003, AC-004 | `bash -n run-container.sh && bash -n entrypoint.sh` | Passed | Shell syntax accepted. |
| AV-002 | AC-001, AC-004 | `docker compose -f docker-compose.yml config` | Passed | Rendered volume target `/home/vncuser/.config/chromium`; existing ports preserved. |
| AV-003 | AC-002, AC-004 | `docker compose -f docker-compose.chrome-vnc.yml config` | Passed | Rendered volume target `/home/vncuser/.config/chromium`; env-backed volume name rendered as `chrome-vnc-chromium-profile`. |
| AV-004 | AC-003, AC-004 | Stubbed `docker` function while sourcing `run-container.sh --name test-vnc --profile-volume test-profile-volume --vnc-port 5911 --debug-port 9231` | Passed | Rendered command included `-v test-profile-volume:/home/vncuser/.config/chromium` and preserved port mappings. |
| AV-005 | AC-003 | Static entrypoint validation | Passed | `entrypoint.sh` creates `/home/vncuser/.config/chromium`, assigns ownership to `vncuser:vncuser`, and sets mode `700` before Supervisor starts. |

## Notes

- `docker compose -f docker-compose.yml config` emitted Docker Compose's existing warning that the top-level `version` attribute is obsolete. This is unrelated to the profile persistence change.
- No live container was started for validation; the run script command path was exercised with a stubbed `docker` function to avoid disrupting active VNC/LLM containers.
