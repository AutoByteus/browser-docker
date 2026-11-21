# Delivery / Release / Deployment Report

## Release / Publication / Deployment Scope

- Ticket `x11-unix-restart` (Project Task `autobyteus-596`), repository `AutoByteus/browser-docker`. `task_size: Small`, `architectural_risk: Low`, direct route.
- Scope: docs sync, verification from evidence, finalization onto `main`, cleanup. No publication (DEC-006: only on the founder's word).

## Project Release Guide

- Release guide path and revision: `Created: RELEASE.md` (this delivery; the repository had none). It is written from what this delivery used and from the repository's earlier releases (`tickets/done/python313-gh-tooling/release-deployment-report.md`, `requirements/chromium-keyring-prompt/release-deployment-report.md`). It also carries DEC-003's release-time checks and DEC-004's downstream steps.
- Deviations from the guide and why: `None`
- Proposed guide fixes, and whether the user agreed:
  - Open decision for the founder: whether the per-architecture checks must run before the push. As written (the 1.4.1 practice), they run against the published child digests, and the rolling tags move at push.
- The repository has no `AGENTS.md`, so no line naming `RELEASE.md` was added.

## Handoff Summary

- Handoff summary artifact: `tickets/done/x11-unix-restart/handoff-summary.md`
- Handoff summary status: `Updated`
- Delivery revision record: `tickets/done/x11-unix-restart/delivery-revision-record.md`
- Current delivery revision ID: `DR-001`

## Initial Delivery Integration Refresh

- Bootstrap base reference: `origin/main` @ `ef63a4670e`
- Latest tracked remote base reference checked: `origin/main` @ `ef63a4670e`
- Base advanced since bootstrap: `No`
- New base commits integrated into the ticket branch: `No`
- Local checkpoint commit result: `Not needed` (clean worktree; API/E2E committed `5ebc4d9`)
- Integration method: `Already current`
- Post-integration executable checks rerun: `No`
- No-rerun rationale: the branch is based on the current `origin/main`, and API/E2E tested `f3cfa3d`, whose code (`37edc71`) is unchanged at the head. Before finalizing, delivery ran `bash tests/validate-source-contract.sh` (PASS) and `bash tests/validate-build-wrapper.sh` (PASS) on the final state, with `RELEASE.md` present, as `RELEASE.md` asks.
- Delivery edits started only after integrated state was current: `Yes`
- Handoff state current with latest tracked remote base: `Yes`

## Verification

- Evidence judged: `Sufficient`
- Evidence relied on:
  - `api-e2e-execution-coverage-report.md` (V-01..V-12) and the files in `evidence/api-e2e/`.
  - Final confidence 95%, no category below 90%.
  - A real `docker build` (default, arm64) with throwaway labelled containers, real root X servers (Xvnc and `xvfb-run`), and the unfixed 1.4.1 image as the control. The founder's `autobyteus-server-*` nodes were not touched.

| Acceptance-Criteria ID | Cases And Files Checked | What You Saw | Judgement |
| --- | --- | --- | --- |
| AC-001 | V-04, V-05 step 1 | fresh container passes `validate-running-container.sh`; `/tmp/.X11-unix` `root root 1777` | Proven |
| AC-002, AC-003, AC-004 (critical) | `V-05-restart-recovery-fixed.txt` | steps 2–5: "Root Xvnc :150/:151/:152 runs; /tmp/.X11-unix is root root 1777", every program RUNNING after each step; "PASS: … recovered after a Supervisor restart of Xvnc, docker restart, and kill/start"; `real 0m28.237s`; 0 `changing permissions` lines | Proven |
| AC-005 | `V-07-launcher-ac005.txt` | root 0755 and 0777: `exit=1`, one line "/tmp/.X11-unix must be a world-writable sticky directory (mode 1777); found owner root:root, mode 755/777.", `Xvnc processes: 0`; missing: created `vncuser vncuser 1777` and Xvnc `:99` runs; vncuser's own 0755 fixed | Proven |
| AC-006 | `V-10-server-overlay-probe.txt` | fresh "ALL RUNNING", in-life tigervnc RUNNING, after restart "ALL RUNNING", "X11-unix chmod failures in supervisord.log: 0" (the final `exit=1` is the probe's `grep -c` of 0) | Proven |
| AC-007 (critical) | `V-06-restart-recovery-control.txt` | 1.4.1 control: "FAIL: fresh start … 'vncuser vncuser 1777'", in-life "tigervnc BACKOFF", after `docker restart` chrome/copyq/xfce FATAL | Proven |
| AC-008 | V-01 (contract and mutations), V-03, V-12 | source contract PASS, four launcher mutations fail it; `validate-image.sh` PASS; build-wrapper PASS (delivery reran both source checks: PASS) | Proven |
| AC-009 | `V-11-readme-recovery-control.txt`; `VERSION`; `README.md` lines 193–209; `release-notes.md` | the README command, as written, turns tigervnc BACKOFF and chrome/copyq/xfce FATAL into all RUNNING; `VERSION` 1.4.2; README and notes state REQ-007's content | Proven |
| amd64 and the `zh` variant | — | not built or run in this ticket | Accepted Risk (DEC-003) |

- DEC-003 covers exactly what was not tested (amd64, `zh`). Its condition, that the release build runs the image checks for both variants and architectures, is not done by `build-multi-arch.sh`. It is now a release step (`RELEASE.md` "Checks After Publishing").
- More evidence requested: `None`
- User check needed: `No`
- Re-verification after later re-integration: see Repository Finalization

## Release Decision

- Decision: `No release`
- Decided by: DEC-006 and the Task direction ("Release and publishing only on the founder's word"); the founder has not asked.

## Docs Sync Result

- Docs sync artifact: `tickets/done/x11-unix-restart/docs-sync-report.md`
- Docs sync result: `Updated` (`RELEASE.md` created; `README.md`, `DESIGN.md` and `TESTING.md` confirmed)

## Ticket State Transition

- Ticket moved to `tickets/done/x11-unix-restart`: `Yes`

## Version / Tag / Release Commit

- `VERSION` 1.4.2 (in `37edc71`). No git tag (not part of this repository's release method). Nothing published.

## Repository Finalization

FINALIZATION

## Release / Publication / Deployment

- Applicable: `No`
- Release/publication/deployment result: `Not required` (on the founder's word, follow `RELEASE.md` with `tickets/done/x11-unix-restart/release-notes.md`)
- Release notes handoff result: `Not required` now; the notes are ready

## Post-Finalization Cleanup

CLEANUP

## Environment Or Persisted-Data Transition Notes

- None: no stored data. Running containers of older images need the README recovery command after a takeover (DEC-005).

## Verification Checks

CHECKS

## Rollback Criteria

- Nothing published. Reverting the commits on `main` restores 1.4.1's sources. After a future publication, `RELEASE.md` "Rollback" points the rolling tags back to the 1.4.1 digests recorded in the release notes.

## Final Status

FINAL
