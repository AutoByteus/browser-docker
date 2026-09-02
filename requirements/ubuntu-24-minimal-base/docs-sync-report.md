# Docs Sync Report

## Scope

- Ticket: `BRD-UBUNTU24-001`
- Current delivery revision: `DR-006`
- Integrated release source: `18bb92e2c9784a4222ff734ffd47d89d877b5c59` on `main`.
- Upstream gates: `RER-007`, `ARCH-REV-002`, `IR-006`/`IR-007`, `CRR-010`, `API-REV-007`, and `CRR-011` (`Not Applicable` because API/E2E made no later durable-test edit).
- Delivery integration evidence: `requirements/ubuntu-24-minimal-base/evidence/delivery-dr006-integration-refresh.log`.

## Why Docs Were Updated

The durable project documentation was already aligned to Ubuntu 24.04, public Python 3.13, Noble's OS-owned Python 3.12, and the isolated Supervisor 4.3.0 tool environment. Delivery therefore preserved `README.md` and updated the release-facing records from the historical DR-005 wrapper blocker to the completed Docker Hub publication and verified immutable identities.

## Long-Lived Docs Reviewed

| Doc Path | Result | Notes |
| --- | --- | --- |
| `README.md` | `No change` | Current Ubuntu, Python ownership, Supervisor/tooling, BuildX, platform, variant, and run guidance matches the published image. |
| `VERSION` | `No change` | Remains `1.4.0`, matching the immutable default and `zh` tags. |
| `tickets/done/ubuntu-24-minimal-base/release-notes.md` | `Updated` | Records completed publication and exact index/platform digests. |
| `requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | `No change` | Remains a separate ticket; its publication dependency is now satisfied by the exact DR-006 identities. |

## Docs Updated

| Doc Path | Type | Update |
| --- | --- | --- |
| `tickets/done/ubuntu-24-minimal-base/release-notes.md` | Release record | Replaced the DR-005 blocked status with completed four-tag publication and exact default/`zh` identities. |
| `requirements/ubuntu-24-minimal-base/handoff-summary.md` | Delivery handoff | Records successful finalization, publication, verification, and remaining scope boundary. |
| `requirements/ubuntu-24-minimal-base/release-deployment-report.md` | Release/rollout record | Records commands, manifests, runtime checks, rollback visibility, and cleanup state. |
| `requirements/ubuntu-24-minimal-base/delivery-revision-record.md` | Delivery history | Adds terminal delivery result `DR-006`. |

## Durable Design / Runtime Knowledge

No new runtime-design rule was introduced during DR-006. The existing `README.md` remains authoritative for:

- public `/usr/local/bin/python3` and `/usr/local/bin/python` selecting Python 3.13;
- Noble's `/usr/bin/python3` remaining Python 3.12 and distribution-owned;
- Supervisor 4.3.0, websockify, and `uv` being owned by `/opt/browser-tools`;
- supported `linux/amd64` and `linux/arm64` default/`zh` variants.

## Delivery Continuation

- Docs sync: `Pass`.
- Docker Hub publication: `Completed`.
- AC-011: `Pass` — all four tags resolve to the expected indexes, both platforms are present, and all four exact child digests report Ubuntu 24.04, Python 3.13, and Supervisor 4.3.0 at runtime.
- AutoByteus server source: not accessed or modified. Server adoption remains a separate follow-up ticket using the published identities.

## Blocked Or Escalated Follow-Up

None for this browser-image release. The earlier Docker Desktop login-preflight compatibility defect was a repository wrapper-code issue, fixed at `24a61a8`, validated through the current gates, and proven by both real publication commands.
