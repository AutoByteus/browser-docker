# Handoff Summary

## Summary Meta

- Ticket: `x11-unix-restart` (Project Task `autobyteus-596`, Project `project_a1377344-25db-482a-97cc-ecfdb0fb495a`), repository `AutoByteus/browser-docker`
- Date: `2026-11-21`
- Classification: `task_size: Small`, `architectural_risk: Low`, direct route. Architecture review, code review and test-code review: `Not Applicable`.
- Current Status: `Verified from evidence / finalized on main; not published`
- Branch: `codex/x11-unix-restart`, base `origin/main` @ `ef63a4670e` (current at delivery). Code at `37edc71`. Finalized: fast-forward of `main` to `7164571`, pushed.

## Delivery Summary

- A root X server started inside the container no longer stops the desktop. Examples are `xvfb-run` or another `Xvnc`, which agents start for their own tests.
- `/tmp/.X11-unix` is `root:root` with mode 1777, set in the Dockerfile and again by `/entrypoint.sh` at every start.
- `start-vnc.sh` changes the directory's mode only when `vncuser` owns it. Otherwise it checks that the directory is world-writable and sticky, and when it is not, it exits with one message naming the owner and mode.
- New `tests/validate-restart-recovery.sh` proves recovery after a takeover: Supervisor restart of Xvnc, `docker restart`, and kill/start. It refuses unlabelled containers. The source contract and image check guard the directory state and the launcher's ownership test.
- `VERSION` 1.4.2. `README.md` documents the directory and a recovery command for running containers of older images.
- New project documents: `DESIGN.md` (Solution Designer), `TESTING.md` (API/E2E), `RELEASE.md` (delivery).

## Verification Summary

- Verified from evidence by delivery; no user check needed. AC-001..AC-009 are directly proven on a real build (default, arm64) in throwaway containers:
  - V-05: `validate-restart-recovery.sh` PASS in 28 s; `/tmp/.X11-unix` stayed `root root 1777`; 0 "changing permissions" lines.
  - V-06: the 1.4.1 control fails at fresh start, in-life (tigervnc BACKOFF) and `docker restart` (FATAL).
  - V-07: the launcher refuses root 0755 and 0777 with one line and starts no Xvnc; a missing directory is created 1777 and Xvnc starts.
  - V-10: the server-image overlay is all running at fresh start, in-life and after restart, with 0 chmod failures.
  - V-11: the README command brings the FATAL control back to all RUNNING.
- Accepted unverified risk: amd64 and the `zh` variant (DEC-003). `RELEASE.md` makes the checks per variant and architecture a release step.
- Final confidence: 95%, no category below 90%.
- gitleaks: no leaks in the ticket commits. Source contract and build-wrapper checks PASS on the final state.

## Residual Risks For The User

- amd64 and `zh` are proven only when a release builds and checks them (DEC-003, `RELEASE.md` "Checks After Publishing").
- AutoByteus nodes get the fix only after the base is published, the server digest is bumped and the server image is rebuilt and published, and the nodes are recreated (DEC-004, `RELEASE.md` "Watching The Rollout").
- Until then, a node whose desktop went FATAL recovers with the README command (DEC-005).
- Open decision: whether release checks must run before the push, because the rolling tags move at push (`docs-sync-report.md`).

## Follow-ups

- `follow-ups.md` FU-001 (Solution Designer): `base.conf` uses `depends_on=`, which Supervisor ignores, so the file suggests a start order that does not exist. Delivery added none.

## Release

- Not published: only on the founder's word (DEC-006). `release-notes.md` (1.4.2 / 1.4.2-zh) is ready, with the 1.4.1 rollback digests.
