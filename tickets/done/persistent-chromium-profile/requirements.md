# Persistent Chromium Profile

Status: Design-ready

## Intent

Chromium login state should survive normal container recreation and image refresh workflows for Chrome-VNC based containers. The current default Chromium profile is created, but it lives only inside the container filesystem unless users manually add a mount.

## Requirements

| ID | Requirement |
| --- | --- |
| R-001 | Provide a project-supported way to persist Chromium profile data for all checked-in container launch entry points. |
| R-002 | Keep Chromium's automatic startup behavior intact. |
| R-003 | Persist the current effective Chromium user data path `/home/vncuser/.config/chromium` to avoid forcing a profile migration. |
| R-004 | Preserve existing VNC, web VNC, and Chrome debugging behavior and default ports. |
| R-005 | Let users override the `run-container.sh` profile volume name for multiple long-lived browser instances. |
| R-006 | Document profile persistence behavior and the residual possibility that Google can still require re-authentication. |

## Acceptance Criteria

| ID | Covers | Acceptance Criterion |
| --- | --- | --- |
| AC-001 | R-001, R-003 | `docker-compose.yml` mounts a named volume at `/home/vncuser/.config/chromium`. |
| AC-002 | R-001, R-003 | `docker-compose.chrome-vnc.yml` mounts a named volume at `/home/vncuser/.config/chromium`. |
| AC-003 | R-001, R-003, R-005 | `run-container.sh` mounts a persistent volume at `/home/vncuser/.config/chromium` by default and exposes a volume-name override. |
| AC-004 | R-002, R-004 | The existing Chromium command and exposed VNC/debug ports remain compatible. |
| AC-005 | R-006 | README instructions explain the persistent profile volume and downstream image requirement. |
| AC-006 | R-001-R-006 | Validation covers shell syntax and Docker Compose configuration rendering. |

## Out Of Scope

- Guaranteeing that Google never asks for password or two-factor authentication again.
- Migrating existing profile data from already-created disposable containers.
- Changing downstream LLM server repositories in this ticket.
