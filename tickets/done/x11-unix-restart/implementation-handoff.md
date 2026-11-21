# Implementation Handoff — autobyteus-596 (`x11-unix-restart`, browser_docker)

Folder: `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart/tickets/in-progress/x11-unix-restart/`. Worktree `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart`, branch `codex/x11-unix-restart`, base `origin/main` @ `ef63a4670e`. Code commit `37edc71`; the ticket documents and evidence are in the commit after it. Nothing was pushed.

## Upstream Artifact Package

- Upstream review applicability and handoff-rule result: `Architecture Design Complete`, `Small`/`Low`. Direct route; architecture review not selected.
- Requirements doc: `requirements-doc.md` (Approved, SR-001)
- Investigation notes: `investigation-notes.md`
- Solution revision record: `solution-revision-record.md`
- Design spec (required on every route): `design-spec.md` (SR-001, Ready)
- Supplemental task artifacts: `probe/x11-takeover-restart-probe.sh`, `probe/server-overlay.Dockerfile`, `follow-ups.md`; project `DESIGN.md` (created by the Solution Designer)
- Design review report: `N/A — not applicable`
- Architecture review revision record: `N/A — not applicable`
- Triggering rework report, revision record, or evidence, when applicable: N/A

## Current Implementation Summary

- `/tmp/.X11-unix` has one defined state, `root:root 1777`.
  - The image is built that way: the `Dockerfile` no longer chowns it to vncuser.
  - `/entrypoint.sh` sets it as root at every container start, before the stale `:99` cleanup and Supervisor.
- `start-vnc.sh` (vncuser) does only what vncuser may do:
  - it creates the directory with mode 1777 if it is missing;
  - it runs `chmod 1777` only when it owns the directory (`-O`);
  - otherwise it requires the directory to be writable and sticky, or exits 1 before Xvnc with one message: `/tmp/.X11-unix must be a world-writable sticky directory (mode 1777); found owner root:root, mode 755.`
  - The stale `:99` logic and the duplicate-server refusal are unchanged.
- New `tests/validate-restart-recovery.sh CONTAINER [default|zh] [EXPECTED_UID]`:
  - It refuses any container not labelled `chrome-vnc.test=throwaway`.
  - Steps:
    1. fresh-start directory state;
    2. root `Xvnc :150` takeover;
    3. in-life restart: kill vncuser's Xvnc, wait for `tigervnc` `RUNNING` with a new PID, then run `validate-running-container.sh`;
    4. takeover `:151` + `docker restart` → `validate-running-container.sh`, directory state, 0 `changing permissions of '/tmp/.X11-unix'` lines in `supervisord.log`;
    5. takeover `:152` + `docker kill -s KILL` / `docker start` → `validate-running-container.sh`, directory state.
- `tests/validate-image.sh`:
  - asserts the built `root root 1777`;
  - AC-005: with the directory set to 0755 (root), the launcher exits non-zero with the exact message and starts no Xvnc;
  - with the directory removed, the launcher creates it (`vncuser 1777`) and `:99` comes up.
- `tests/validate-source-contract.sh`: VERSION 1.4.2, plus these checks:
  - `start-vnc.sh` has `x11_dir`, the `-O` test, no top-level `chmod`, exactly one directory `chmod` and it directly follows the `-O` line, the writable+sticky check, and no `sudo` or `chown`;
  - `entrypoint.sh` has the `chown root:root` and `chmod 1777` lines, ordered before the `:99` cleanup and Supervisor;
  - `Dockerfile` has no `chown` of the directory;
  - the restart script carries the label guard;
  - the README recovery section states the state.
- Docs: README "Reliable Recovery After Host/Daemon Restart" states the directory state and the takeover behavior. It gives the tested older-image recovery command (owner back to vncuser, DEC-005). `VERSION` is `1.4.2`.
- `release-notes.md` (ticket folder, draft, `Not published`) states the server-image rollout path: base release → digest bump → server rebuild (REQ-007, DEC-004). Delivery completes it at publication.
- Implementation cycle: `Initial`
- Implementation revision record: `implementation-revision-record.md`
- Current implementation revision ID: `IR-001`
- Related solution revision IDs: `SR-001`
- Related architecture-review revision IDs: `N/A`
- Related code-review revision IDs: `N/A`
- Related API/E2E revision IDs: `N/A`
- Related delivery revision IDs: `N/A`
- Triggering finding IDs: `N/A`

## Routing Classification (Mandatory)

- Task size: `Small`
- Architecture risk: `Low`
- Design classification section / evidence reference: `design-spec.md` "Task Size And Architectural Risk"
- Classification confirmed or changed: `Confirmed`
- Evidence and rationale for confirmation or change:
  - Three image files change by a few lines (`start-vnc.sh` +14/−3, `entrypoint.sh` +7, `Dockerfile` −1 line).
  - Same programs, users, ports, Supervisor graph and server-image interface.
  - None of the design's escalation triggers fired:
    - only tigervnc's launcher changed;
    - the server overlay works with the base scripts unchanged in interface;
    - the non-root Xvnc runs in the `root:root 1777` directory;
    - only `run-container.sh` flags were used.
- Selected route: `Direct API/E2E`
- Lightweight implementation self-review completed for the direct route: `Yes`. I read the diff against the design's Target Mapping and Examples:
  - the launcher block matches the design's example;
  - no `|| true`, `sudo` or `chown` in the launcher;
  - entrypoint ordering checked by the source contract;
  - shellcheck reports nothing in the changed scripts beyond info-level notes on deliberately literal single-quoted patterns.
- New design impact or escalation trigger: `None`

## Reviewed Behavior Implementation Trace

| Behavior ID | Approved Change / Preserved Outcome | Implemented Production Path / Key Files | Result / Notes |
| --- | --- | --- | --- |
| BEH-001 | All up; dir `root:root 1777` | `Dockerfile` X11 layer (no chown) + `entrypoint.sh` invariant block | IMP-04 (built `root root 1777`), IMP-05 (all `RUNNING`, `root root 1777`) |
| BEH-002 | Root X server takes the dir; now a no-op on ownership | Outside the image; exercised by `take_over` in the restart check | IMP-06: `Root Xvnc :150 runs; /tmp/.X11-unix is root root 1777.` |
| BEH-003 | Restart after takeover: all up | DS-001: `entrypoint.sh` → Supervisor → `start-vnc.sh` check | IMP-06 step 4, IMP-10 (server overlay); control fails (IMP-08) |
| BEH-004 | In-life Xvnc restart after takeover: all up | DS-002: `start-vnc.sh` check (`-O` false → writable+sticky → `exec Xvnc`) | IMP-06 step 3, IMP-10; control `BACKOFF` (IMP-08) |
| BEH-005 | Abrupt stop: `:99` artifacts cleared, also after takeover; duplicate refused | `entrypoint.sh` stale cleanup and `start-vnc.sh` live-PID check, unchanged | IMP-06 step 5; IMP-07: `refusing to start duplicate X server.` |
| BEH-006 | Unusable dir: clear message, exit non-zero; missing dir created 1777 | `start-vnc.sh` check block | IMP-04 (exact message, no Xvnc; missing → `vncuser 1777` + `:99`) |

- Changes stayed within the requirements doc's Scope Guardrail: `Yes`

## Key Files Or Areas

- `start-vnc.sh`, `entrypoint.sh`, `Dockerfile` (X11 layer)
- `tests/validate-restart-recovery.sh` (new), `tests/validate-image.sh`, `tests/validate-source-contract.sh`
- `README.md` (recovery section), `VERSION`
- Ticket: `release-notes.md` (draft), `evidence/`

## Important Assumptions

- The restart check takes over with `Xvnc` on displays `:150`–`:152` and rfbports `5950`–`5952` (5800 + display). Each takeover uses its own display, so a takeover server's lock left by an earlier step (for example after kill/start) cannot interfere.
- The restart check runs every step and reports each failure, rather than stopping at the first one. This lets the unfixed control show where it breaks (AC-007): it fails at its fresh-start directory state and at the in-life, restart and kill/start steps. The design's "`FAIL: <step>` and exit 1" contract holds: one `FAIL:` line per failure, a summary, then exit 1.
- The fixed image's directory is already `root:root` at start, so its takeover changes no owner. The takeover still runs a root X server in the directory, as agents do.

## Known Risks

- RSK-001/RSK-002 (DEC-003): amd64 and the `zh` variant were not built or run locally. The change is two shell scripts and one Dockerfile line, the same for every architecture and variant; the release build runs the image checks for both.

## Task Design Health Assessment Implementation Check

- Reviewed change posture: `Bug Fix`
- Reviewed root-cause classification: `Missing Invariant`
- Reviewed refactor decision: `No Refactor Needed`
- Implementation matched the reviewed assessment: `Yes`
- If challenged, routed as `Design Impact`: `N/A`
- Evidence / notes: the owners in the design held. The entrypoint sets the invariant, and the launcher checks only what it needs (IMP-06, IMP-10).

## Legacy / Compatibility Removal Check

- Backward-compatibility mechanisms introduced: `None`. The older-image recovery command is documentation for running containers, not code.
- Legacy old-behavior retained in scope: `No`. The unconditional `chmod` and the Dockerfile `chown` are removed.
- Dead code in the touched files and modules removed (Core Principle 7): `Yes`
- Dead code found elsewhere, added to `follow-ups.md`: None. FU-001 (`depends_on`) was already recorded by the Solution Designer.
- Shared structures remain tight: `Yes`
- Canonical shared design guidance was reapplied during implementation: `Yes`
- Deviations from a design principle decided during implementation: `None`
- Changed source implementation files stayed within proactive size-pressure guardrails: `Yes`
- Notes: —

## Persisted Data Transition Check (When Applicable)

- Approved decision: `Not Affected`
- Design-spec decision reference: "Persisted Data / State Transition Decision"
- Implementation follows the approved decision: `Yes`. The entrypoint normalizes an existing container's `/tmp/.X11-unix` at its next start.
- Direct-use evidence: IMP-06 step 4 (`docker restart` of a container whose directory a takeover changed: `root root 1777`, all `RUNNING`)
- Migration implementation: N/A
- Deviation: `None`

## Environment Or Dependency Notes

- Docker Desktop on macOS arm64; local builds are `linux/arm64`. The repository has no `TESTING.md` yet; API/E2E creates it in this ticket (team project-documents rule). Commands were taken from the design and the existing `tests/` usage lines.
- Throwaway containers I created (`ab596-fixed`, `ab596-control`, `ab596-server-overlay`, all labelled throwaway) are removed. `autobyteus-server-0/1/2` were not touched; they were still `Up 3 hours` afterwards.
- Local scratch images kept for API/E2E to reuse, to remove at ticket cleanup:
  - `autobyteus-596-chrome-vnc:local` (`sha256:e88b1afc4bd4…`, built from `37edc71`);
  - `autobyteus-596-server-overlay:local`;
  - the Solution Designer's `autobyteus-596-proto:local` and `/tmp/autobyteus-596/`;
  - the pulled control `autobyteus/chrome-vnc@sha256:b2fde77f…96f4`.

## Checks Run

Every evidence file is in `evidence/`. All checks ran on commit `37edc71`, on macOS arm64 with Docker Desktop (`linux/arm64`), on 2026-11-21. Containers were throwaway, labelled `chrome-vnc.test=throwaway`, with `--cap-add SYS_ADMIN --security-opt seccomp=unconfined`.

| Check ID | Command Or Steps | Code It Exercises | Behavior / Criteria IDs | Result | Evidence Files | Look For |
| --- | --- | --- | --- | --- | --- | --- |
| IMP-01 | `bash tests/validate-source-contract.sh` | Source contract, all files | AC-008, REQ-005 | Pass | `IMP-01-source-contract.txt` | `PASS: source, build, release, runtime-path, port, no-keyring, X socket directory, and documentation contracts are consistent.` |
| IMP-01b | IMP-01 with `start-vnc.sh` mutated: (A) old top-level `chmod 1777 /tmp/.X11-unix` added; (B) `-O` test replaced by an unconditional block. Restored after | Source contract's guard | AC-008 | Pass: both mutations fail | `IMP-01b-source-contract-negative.txt` | (A) `FAIL: active source contains obsolete pattern: ^chmod…`; (B) `FAIL: start-vnc.sh does not contain expected literal line: if [ -O "$x11_dir" ]; then`; restored: `exit=0` |
| IMP-02 | `bash tests/validate-build-wrapper.sh` (fake `docker`, no push) | `build-multi-arch.sh` (unchanged; regression) | — | Pass | `IMP-02-build-wrapper.txt` | `PASS: modern credential-helper push sessions…` |
| IMP-03 | `docker build -t autobyteus-596-chrome-vnc:local .` (default variant, no push) | `Dockerfile` | REQ-002 | Pass | `IMP-03-build-default-arm64.log` (full), `.excerpt.txt` | X11 layer `RUN mkdir -p /tmp/.X11-unix &&     chmod 1777 /tmp/.X11-unix &&     mkdir -p /dev/shm &&     chmod 1777 /dev/shm` (no chown); `exit=0` |
| IMP-04 | `tests/validate-image.sh autobyteus-596-chrome-vnc:local default` | Built image; `start-vnc.sh` without Supervisor | AC-005, AC-008, BEH-006, REQ-002 | Pass | `IMP-04-validate-image-default.txt` | `PASS: … X socket directory and launcher check, and UID/GID contracts validated.` |
| IMP-05 | Fresh throwaway `ab596-fixed`; `tests/validate-running-container.sh ab596-fixed default`; `stat` the directory | Entrypoint + full desktop | AC-001, BEH-001 | Pass | `IMP-05-running-container-fixed.txt` | `exit=0`, then `root root 1777` |
| IMP-06 | `tests/validate-restart-recovery.sh ab596-fixed default` | Entrypoint + launcher across in-life, restart, kill/start | AC-002, AC-003, AC-004, AC-007 (fixed side), BEH-003..005 | Pass | `IMP-06-restart-recovery-fixed.txt` | `PASS: after a root X server took over /tmp/.X11-unix, the desktop recovered after a Supervisor restart of Xvnc, docker restart, and kill/start; /tmp/.X11-unix stayed root root 1777.` |
| IMP-07 | A second `start-vnc.sh` as vncuser while `tigervnc` runs in `ab596-fixed` | Launcher's live-`:99` refusal (unchanged) | REQ-006, BEH-005 | Pass | `IMP-07-duplicate-refusal-fixed.txt` | `exit=1: Display :99 appears to be used by live PID 40; refusing to start duplicate X server.`; tigervnc still `pid 40` |
| IMP-08 | Throwaway `ab596-control` from unfixed `autobyteus/chrome-vnc@sha256:b2fde77f…96f4` (1.4.1): IMP-08a fresh `validate-running-container.sh`, then `tests/validate-restart-recovery.sh ab596-control default` | New check against the control | AC-007 (control side) | Pass: the control fails as expected (fresh start passes) | `IMP-08a-control-fresh.txt`, `IMP-08-restart-recovery-control.txt` (full), `.excerpt.txt` | `FAIL: 5 step check(s) failed:` with in-life `BACKOFF`, `docker restart: the desktop did not recover`, `supervisord.log has 30 'changing permissions…' lines`, `kill/start: the desktop did not recover` |
| IMP-09 | README older-image recovery command (extracted from `README.md`) on `ab596-control` after IMP-08 left it `FATAL`; then `validate-running-container.sh` | README command | AC-009, REQ-007 | Pass | `IMP-09-readme-recovery-control.txt` | before: `chrome FATAL`, `tigervnc BACKOFF`; after: all `RUNNING`, `exit=0` |
| IMP-10 | Build `probe/server-overlay.Dockerfile` (`FROM autobyteus/autobyteus-server:beta` + branch scripts; never pushed) → `probe/x11-takeover-restart-probe.sh autobyteus-596-server-overlay:local ab596-server-overlay` | Server-image composition | AC-006 | Pass | `IMP-10a-build-server-overlay.log`, `IMP-10-server-overlay-probe.txt` | `ALL RUNNING` at fresh start and after restart; in-life `tigervnc RUNNING`; `X11-unix chmod failures in supervisord.log: 0`; `autobyteus_server RUNNING`. The probe's exit 1 is its final `grep -c` finding 0 matches |

- Not run, and why:
  - amd64 and `zh`: not built or run (DEC-003, release build);
  - the probe on the unfixed server `beta` image: the Solution Designer ran it as the reproduction (investigation notes);
  - `TESTING.md` creation and broader executable coverage: left to API/E2E.

## Frontend Rendered-Result Check (When Applicable)

`Not Applicable`. This is container startup scripts, with no rendered UI change. `validate-running-container.sh` checks the desktop stack's VNC, noVNC and Chromium DevTools rendering (IMP-05, IMP-06).

## Downstream Coverage Hints / Suggested Scenarios

- Rerun `tests/validate-restart-recovery.sh` on a fresh throwaway container of `autobyteus-596-chrome-vnc:local`, or rebuild from `37edc71`. Rerun the control (unfixed 1.4.1) for AC-007.
- Consider an xvfb-run takeover (SCN-002 names `xvfb-run -a …`) as well as `Xvnc`.
- Optional: the `zh` variant build and its restart check, if time allows (DEC-003 accepts skipping it).
- `TESTING.md` for this repository: the four `validate-*.sh` scripts, the throwaway label and run flags, and the "never touch `autobyteus-server-*`" rule.

## API / E2E / Executable Coverage Investigation And Execution Still Required

- Independent API/E2E validation of AC-001..AC-009 and the confidence classification.
- Creating `TESTING.md` (team rule: the API/E2E engineer creates it in this ticket).
