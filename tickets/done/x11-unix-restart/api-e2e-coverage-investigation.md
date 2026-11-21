# API/E2E Coverage Investigation — autobyteus-596 (`x11-unix-restart`)

## Basis

- Requirements: `requirements-doc.md` (SR-001: REQ-001..007, AC-001..009, DEC-001..006).
- Design: `design-spec.md`.
- Implementation: IR-001 (`37edc71`; documents `f3cfa3d`). Direct route, Small / Low.
- The change: the X socket directory `/tmp/.X11-unix` is `root:root 1777` at build and at every start (`entrypoint.sh`), and `start-vnc.sh` changes the mode only of a directory it owns, otherwise checks that the directory is usable. New check `tests/validate-restart-recovery.sh`.
- Real boundary: a built image in throwaway containers, with real Supervisor programs, real root X servers taking the directory over, `docker restart`, and kill/start. No service, credential or account is involved.
- Accepted beforehand: DEC-003 accepts amd64 and the `zh` variant as a low, bounded risk, proven later by the founder-gated release build. Recorded as `Accepted Unverified Risk (DEC-003)`.
- Hard limits: never touch `autobyteus-server-0/1/2`; no push and no `--push` build.

## Existing coverage

- `tests/validate-source-contract.sh`: source rules (extended).
- `tests/validate-image.sh`: built image (extended).
- `tests/validate-running-container.sh`: a running container's programs and Chromium.
- `tests/validate-restart-recovery.sh`: new.
- `tests/validate-build-wrapper.sh`: the build script, with a fake docker.
- There was no `TESTING.md`; I create it in this ticket.

## Planned cases

| Case | Covers | Surface | Kind |
| --- | --- | --- | --- |
| V-01 | AC-008 | source contract, plus its two launcher mutations (must fail) | Existing (extended) |
| V-02 | REQ-002, build | `docker build` of this branch (default, arm64), done by me | Build |
| V-03 | AC-005, AC-008 | `tests/validate-image.sh` on my build | Existing (extended) |
| V-04 | AC-001 | fresh throwaway container: `validate-running-container.sh`, the directory's state | Existing |
| V-05 | AC-002, AC-003, AC-004 | `validate-restart-recovery.sh` on the fixed image | New durable |
| V-06 | AC-007 | the same check on the unfixed 1.4.1 control (must fail at in-life, restart, kill/start) | New durable |
| V-07 | AC-005 directly | `start-vnc.sh` as vncuser with the directory root 0755, and missing | Focused |
| V-08 | REQ-004 (Supervisor restart of Xvnc) and SCN-002 (`xvfb-run -a` as the root X server) | throwaway container of the fixed image | Extra |
| V-09 | REQ-006 | duplicate `:99` refusal while Xvnc runs; stale lock after a kill (V-05 kill/start) | Focused |
| V-10 | AC-006 | server-image composition: `probe/server-overlay.Dockerfile` + `probe/x11-takeover-restart-probe.sh` | Probe |
| V-11 | AC-009 | the README older-image recovery command on the control after a takeover; README, release notes, `VERSION` | Docs + throwaway |
| V-12 | regression | `tests/validate-build-wrapper.sh` | Existing |
| V-13 | amd64, `zh` | — | Accepted Unverified Risk (DEC-003) |
