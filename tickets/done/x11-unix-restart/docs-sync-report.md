# Docs Sync Report

## Scope

- Ticket: `x11-unix-restart` (Project Task `autobyteus-596`), repository `AutoByteus/browser-docker`. `task_size: Small`, `architectural_risk: Low`, direct route (architecture, code and test-code review `Not Applicable`).
- Trigger: API/E2E handoff (API-REV-001 Pass, 95%), 2026-11-21.
- Bootstrap base reference: `origin/main` @ `ef63a4670e`.
- Integrated base reference used for docs sync: `origin/main` @ `ef63a4670e` (unchanged; the branch was current).
- Post-integration verification reference: not rerun (no new base commits); `release-deployment-report.md`.

## Why Docs Were Updated

- Summary: the ticket already documents the X socket directory state, the launcher's ownership test, the recovery command and `VERSION` 1.4.2 (`README.md`). It also created `DESIGN.md` (Solution Designer, with design case DC-001) and `TESTING.md` (API/E2E). The repository had no release guide, so delivery created `RELEASE.md` from this delivery and the repository's earlier releases (1.3.7, 1.4.0, 1.4.1). It carries DEC-003's condition: the image and container checks run for both variants on both architectures, because `build-multi-arch.sh` runs none.
- Why this should live in long-lived project docs: who owns `/tmp/.X11-unix` and how the launcher treats it is a rule every future launcher change follows; how a release is cut and checked is needed by every release.

## Long-Lived Docs Reviewed

| Doc Path | Why It Was Reviewed | Result (`Updated`/`No change`/`Needs follow-up`) | Notes |
| --- | --- | --- | --- |
| `README.md` | the directory's state, the launcher, the recovery command for older images | No change (updated by implementation) | matches `entrypoint.sh`, `start-vnc.sh` and the Dockerfile line; the recovery command is proven by V-11 |
| `DESIGN.md` (created in this ticket) | "Root prepares, `vncuser` runs"; the X socket directory rule; DC-001 | No change | matches the final code |
| `TESTING.md` (created in this ticket) | layers, the restart-recovery check, the rules for throwaway containers | No change | its "Before a release, run the image check and the running-container check for each variant on each architecture" is now a step of `RELEASE.md` |
| `RELEASE.md` | missing | Created | see below |
| `tickets/in-progress/x11-unix-restart/release-notes.md` | release notes for 1.4.2 | No change | ready for the founder's release; publication fields are filled at publication |

## Docs Updated

| Doc Path | Type Of Update | What Changed | Why |
| --- | --- | --- | --- |
| `RELEASE.md` | created (release guide template) | finalization target and fast-forward order with the two source checks; release decision (founder's word); cutting with `build-multi-arch.sh --push`; checks per variant and architecture by child digest; the downstream server digest bump; rollback of rolling tags; no deployment | the repository had none (`project-documents.md`); DEC-003 relies on release-time checks that no file stated as a release step |

## Durable Design / Runtime Knowledge Promoted

| Topic | What Future Readers Need To Understand | Source Ticket Artifact(s) | Target Long-Lived Doc |
| --- | --- | --- | --- |
| X socket directory | `root:root 1777`, set at build and every start; launchers change only what `vncuser` owns, and check the rest | `design-spec.md`, `requirements-doc.md` DEC-001 | `DESIGN.md`, `README.md` |
| releasing the base image | checks per variant and architecture, then the server digest bump | DEC-003, DEC-004; the 1.4.1 record (`requirements/chromium-keyring-prompt/release-deployment-report.md`) | `RELEASE.md` |

## Removed / Replaced Components Recorded

| Old Component / Path / Concept | What Replaced It | Where The New Truth Is Documented |
| --- | --- | --- |
| `start-vnc.sh`'s unconditional `chmod 1777 /tmp/.X11-unix`; the directory owned by `vncuser` | ownership test plus usability check; the directory `root:root 1777` | `README.md`, `DESIGN.md` |

## Open Decision Named

- `RELEASE.md` follows the 1.4.1 practice: the per-architecture checks run against the published child digests. The rolling tags `latest` and `zh` move at push, so a failing check leaves them pointing at a bad image until they are pointed back (Rollback). Building and checking each architecture before pushing would close that window but is not established here. This is the founder's decision.

## Delivery Continuation

- Result: `Pass`
- Next delivery action: archive the ticket, finalize onto `main` per `RELEASE.md`. No release.
