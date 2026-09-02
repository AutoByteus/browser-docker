# Docs Sync Report

## Scope

- Ticket: `BRD-UBUNTU24-001`
- Trigger: Delivery re-entry after requirements `RER-007`, architecture `ARCH-REV-002`, implementation `IR-005`, source review `CRR-006`, API/E2E `API-REV-005`/`API-REV-006`, and durable-test review `CRR-008` passed.
- Bootstrap base reference: `2bc0b4a26c87bdf6903e4977679849e5f7ee0bef` (`main` at the original ticket branch point).
- Integrated base reference used for docs sync: current `origin/main` `fb0f59372254b853e85c69046aa921f1d59d96c7`, already present as an ancestor of integrated source commit `f902e80771b304916858314fa9484cab8f6f1843` through merge commit `cc30abff0769553c84fb1ebb453c28e6123f4218`.
- Post-integration verification reference: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/delivery-dr004-integration-refresh.log`; current integrated executable evidence is recorded in `api-e2e-execution-coverage-report.md` and its round-5/round-6 evidence inventory.

## Why Docs Were Updated

- Summary: The README now documents the durable split between the public Python 3.13 developer commands and Noble's OS-owned Python 3.12, plus the single isolated Python 3.13 owner for Supervisor 4.3.0, websockify, and `uv`. Pre-publication release notes for `1.4.0`/`1.4.0-zh` were created.
- Why this should live in long-lived project docs: The public-versus-OS Python boundary and sole operational-tool environment prevent future maintainers from repointing `/usr/bin/python3`, mixing Supervisor providers, or reintroducing Python-version-specific tool paths. These are durable runtime ownership rules, not ticket-only implementation details.

## Long-Lived Docs Reviewed

| Doc Path | Why It Was Reviewed | Result (`Updated`/`No change`/`Needs follow-up`) | Notes |
| --- | --- | --- | --- |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/README.md` | Confirm Ubuntu, Python, Supervisor, architecture/variant, build, runtime, locale/input, and persistence claims against the integrated checked implementation. | `Updated` | Added the public Python 3.13 versus OS Python 3.12 ownership boundary and `/opt/browser-tools` operational-tool topology. Existing Ubuntu 24.04, Supervisor 4.3.0, GitHub CLI, Node.js 22, variant, build, and runtime instructions remain accurate. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/VERSION` | Confirm the immutable publication identity used by the build script and release notes. | `No change` | Already `1.4.0`, matching approved requirements and planned default/`zh` tags. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tickets/done/ubuntu-24-minimal-base/release-notes.md` | Prepare the required release record before user verification. | `Updated` | Created with accurate pre-publication status and the integrated release delta. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | Confirm downstream sequencing after publication. | `No change` | Current RER-007-aligned follow-up remains explicitly deferred until verified `1.4.0`/`1.4.0-zh` publication. |

## Docs Updated

| Doc Path | Type Of Update | What Changed | Why |
| --- | --- | --- | --- |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/README.md` | Durable runtime documentation | Added the supported public Python selectors, preserved OS interpreter, and isolated Supervisor/websockify/`uv` owner and paths. | Keep maintenance and troubleshooting guidance aligned with the reviewed Noble/Python 3.13 design. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tickets/done/ubuntu-24-minimal-base/release-notes.md` | Release record | Added the `1.4.0`/`1.4.0-zh` change summary and truthful pending-publication status. | Provide the pre-verification artifact required for later repository finalization and Docker Hub publication. |

## Durable Design / Runtime Knowledge Promoted

| Topic | What Future Readers Need To Understand | Source Ticket Artifact(s) | Target Long-Lived Doc |
| --- | --- | --- | --- |
| Python ownership | `/usr/local/bin/python3` and `/usr/local/bin/python` select Python 3.13, while Noble's `/usr/bin/python3` remains distribution-owned Python 3.12. | `design-spec.md`; `implementation-handoff.md`; `api-e2e-execution-coverage-report.md` | `README.md` |
| Operational-tool owner | Supervisor 4.3.0, websockify, and `uv` share `/opt/browser-tools` and stable `/usr/local` commands/assets; mixed or OS-owned Supervisor providers are not the supported topology. | `design-spec.md`; `implementation-handoff.md`; `api-e2e-execution-coverage-report.md` | `README.md` |

## Removed / Replaced Components Recorded

| Old Component / Path / Concept | What Replaced It | Where The New Truth Is Documented |
| --- | --- | --- |
| Ubuntu 22.04 image baseline | Canonical official minimal Ubuntu 24.04 LTS OCI base | `README.md`; `tickets/done/ubuntu-24-minimal-base/release-notes.md` |
| Global/mixed Python tool ownership and version-specific websockify asset path | One Python 3.13 `/opt/browser-tools` environment with stable `/usr/local` commands/assets | `README.md`; `tickets/done/ubuntu-24-minimal-base/release-notes.md` |

## Delivery Continuation

- Result: `Pass` for docs sync; overall release `Blocked` after repository finalization.
- Next delivery action: `/implementation_engineer` corrects the supported publication wrapper's Docker login preflight, followed by focused review/API-E2E and Delivery publication re-entry.
- Notes: Repository finalization completed at `01a07b203472049695e870b2865fcd5df9ec5844`. The first `./build-multi-arch.sh --push` attempt exited before BuildX because Docker Desktop 29 omits the `Username` field despite a successful `docker login`. No Docker Hub or server-repository mutation occurred, and no additional long-lived docs change is needed to describe this delivery-local blocker.

## Blocked Or Escalated Follow-Up

None. Docs sync is complete; only the explicit user-verification/finalization gate remains.
