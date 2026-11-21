# API/E2E Execution Coverage Report — autobyteus-596 (`x11-unix-restart`)

## Round

- Coverage investigation: `api-e2e-coverage-investigation.md`; revision record `api-e2e-revision-record.md` (API-REV-001); progress `api-e2e-test-progress.md`.
- Trigger: IR-001, direct route (Small / Low). Tested at `f3cfa3d` (code `37edc71`). First round.
- Evidence: `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart/tickets/in-progress/x11-unix-restart/evidence/api-e2e/` (the implementer's in `evidence/`).
- Stale tests: none. The existing checks changed on purpose for the new directory state (image check, source contract) and pass.
- Project document created: `TESTING.md` (this repository had none). The repository has no `AGENTS.md`, so no line was added there.

## Routing Classification

- Task size: `Small`. Architectural risk: `Low`. Input route: `Direct`.
- Test-code review: `Not Required — direct low-risk route`.

## Tested Builds And Environments

| Env | What | Notes |
| --- | --- | --- |
| E1 | `autobyteus-596-chrome-vnc:api`, my own `docker build .` at `f3cfa3d`, default variant, linux/arm64 (image `sha256:e06f7274b79b…`) | macOS, Docker Desktop; never pushed; tag removed after |
| E2 | control `autobyteus/chrome-vnc@sha256:b2fde77f…96f4` (1.4.1, the unfixed launcher with its unconditional `chmod`) | confirmed inside: `start-vnc.sh` L10 `chmod 1777 /tmp/.X11-unix`; directory `vncuser vncuser 1777` |
| E3 | `autobyteus-596-server-overlay:api`, my build of `probe/server-overlay.Dockerfile` on `autobyteus/autobyteus-server:beta` (`52db87304cc4`) | never pushed; tag removed after |

All containers were my own, labelled throwaway, and removed afterwards. The founder's `autobyteus-server-0/1/2` were never touched; they stayed up throughout.

## Cases

| Case | Criteria | Surface | Command / Steps | Result | Evidence | Look For |
| --- | --- | --- | --- | --- | --- | --- |
| V-01 | AC-008 | source contract | `bash tests/validate-source-contract.sh`; then four mutations of `start-vnc.sh`, each restored | Pass | `V-01-source-contract*.txt` | `PASS: … X socket directory, and documentation contracts are consistent`. The mutations all fail the contract: an unconditional `chmod`, the `-O` test replaced, a `chmod … \|\| true`, and an indented `chmod` inside another block ("must change the X socket directory mode once, only inside its ownership test"). Rerun after adding `TESTING.md`: PASS |
| V-02 | REQ-002 | `docker build -t autobyteus-596-chrome-vnc:api .` | build | Pass | `V-02-build-excerpt.txt` | the X11 layer `mkdir -p /tmp/.X11-unix && chmod 1777 …` with no `chown`; `exit=0` |
| V-03 | AC-005, AC-008 | `bash tests/validate-image.sh autobyteus-596-chrome-vnc:api default` | image | Pass | `V-03-validate-image.txt` | `PASS: … X socket directory and launcher check, and UID/GID contracts validated` |
| V-04 | AC-001 | fresh throwaway container | `validate-running-container.sh`; `stat` | Pass | `V-04-fresh.txt` | all programs `RUNNING`; four `PASS` lines; `exit=0`; `dir: root root 1777` |
| V-05 | AC-002, AC-003, AC-004 | the same container | `bash tests/validate-restart-recovery.sh ab596-api-fixed default` | Pass | `V-05-restart-recovery-fixed.txt` | steps 1–5, each running check `PASS`; final `PASS: after a root X server took over /tmp/.X11-unix, the desktop recovered after a Supervisor restart of Xvnc, docker restart, and kill/start`; 28 s in all (limit 120 s per step); 0 "changing permissions" lines in any Supervisor log; root X servers `:150`–`:152` ran |
| V-05b | safety of the new check | an unlabelled container of mine | the same script | Pass | `V-05b-refuses-unlabelled.txt` | `Refusing: container … is not labelled chrome-vnc.test=throwaway`, `exit=2`, restart count 0 |
| V-06 | AC-007 | control E2 | `validate-running-container.sh`, then `validate-restart-recovery.sh` | Pass (the control fails as required) | `V-06-restart-recovery-control.txt` | fresh `exit=0`. Then `FAIL: in-life restart: tigervnc … BACKOFF`; `docker restart` fails with "30 'changing permissions …' lines"; `kill/start` fails; `exit=1` |
| V-07 | AC-005, REQ-003, QR-002 | `start-vnc.sh` as `vncuser` without Supervisor, my image | `docker run --rm --entrypoint bash …` | Pass | `V-07-launcher-ac005.txt` | root 0755: `exit=1`, one line naming `/tmp/.X11-unix`, `root:root`, `755`, 0 Xvnc. Root 0777 (not sticky): the same refusal. Missing: created `vncuser vncuser 1777`, Xvnc `:99` runs. `vncuser`-owned 0755: fixed to 1777, Xvnc runs |
| V-08 | REQ-004 (Supervisor restart), SCN-002 with the agents' real tool | fresh container of my image; `xvfb` installed in it as root | `xvfb-run -a` as root (got `Xvfb :100`), then `supervisorctl restart tigervnc`, then `docker restart` | Pass | `V-08-xvfb-takeover.txt` | `X100` owned by root beside `X99`; all programs `RUNNING` and running check `exit=0` after both; directory `root root 1777`; 0 chmod lines |
| V-09 | REQ-006 | the fixed container, after V-05's kill/start (stale lock path) | a second `start-vnc.sh` as `vncuser` | Pass | `V-09-duplicate-refusal.txt` | `Display :99 appears to be used by live PID 40; refusing to start duplicate X server.`, `exit=1`; tigervnc keeps pid 40 |
| V-10 | AC-006 | server composition E3 | `probe/x11-takeover-restart-probe.sh autobyteus-596-server-overlay:api ab596-api-overlay` | Pass | `V-10-server-overlay-probe.txt`, `V-10-build-overlay-excerpt.txt` | `ALL RUNNING` at fresh start and after restart; in-life `tigervnc RUNNING` with a new pid; directory `root root`; `chmod failures …: 0`. The probe exits 1 only because its last `grep -c` counts 0 matches (a ticket evidence tool, not a durable check) |
| V-11 | AC-009, REQ-007 | the broken control after V-06; docs | the README command, as written (no `-u` flag); `VERSION`, README, release notes | Pass | `V-11-readme-recovery-control.txt` | before: `chrome/copyq/xfce FATAL`, `tigervnc BACKOFF`; after: all `RUNNING`, running check `exit=0`. `VERSION` `1.4.2`. The README section states the directory's state and the command. The release notes state the server-image digest bump and rebuild |
| V-12 | regression | build wrapper | `bash tests/validate-build-wrapper.sh` | Pass | `V-12-build-wrapper.txt` | `PASS` |
| V-13 | amd64; `zh` variant | — | — | Accepted Unverified Risk (DEC-003) | — | not run here; see the proof table |

## Acceptance-Criteria Proof

| AC | Critical | Proven By | Result | For An Accepted-Risk Part |
| --- | --- | --- | --- | --- |
| AC-001 | Yes | V-04, V-02 | Proven (default, arm64) | amd64 and `zh`: Accepted Unverified Risk (DEC-003) |
| AC-002 | Yes | V-05, V-08 | Proven | as above |
| AC-003 | Yes | V-05 step 3, V-08 | Proven | as above |
| AC-004 | Yes | V-05 step 5 | Proven | as above |
| AC-005 | No | V-07, V-03 | Proven | — |
| AC-006 | Yes | V-10 | Proven | — |
| AC-007 | No | V-06, V-05 | Proven | — |
| AC-008 | No | V-01, V-03 | Proven | — |
| AC-009 | No | V-11 | Proven | — |

DEC-003 assumes that the release build "runs the image checks" for both variants and both architectures. `build-multi-arch.sh` builds and tags but runs no check. That step must be part of the release procedure: `TESTING.md` Choosing The Layer states it, and `RELEASE.md` (delivery's document; this repository has none yet) should include it.

## Validation Confidence Scorecard (Mandatory)

| Category | Final | Supports | Residual |
| --- | --- | --- | --- |
| Requirement and AC proof | 96% | every AC directly on a real build, with the control showing the failure | amd64 and `zh` (DEC-003) |
| Changed-boundary directness | 97% | the real entrypoint, launcher and Supervisor in containers; real root X servers (Xvnc and the agents' `xvfb-run`) | — |
| Integration realism | 95% | the server-image composition (AC-006); the release image as control | the server image is composed by overlay, not rebuilt on 1.4.2 (that is release work, DEC-004) |
| Environment fidelity | 92% | Docker Desktop arm64 | amd64 and `zh` (accepted, DEC-003) |
| Failure / lifecycle / recovery | 97% | Supervisor restart, `docker restart`, kill/start, stale lock, duplicate refusal, unusable and missing directory | — |
| Durable regression coverage | 96% | the restart check (fails on the control), the image check and the source contract (mutation-tested) | — |

- Overall: 95%. Every critical AC is directly proven, apart from the part accepted as unverified risk.
- No category is below 90%. The 95% target is met.

## Broader Validation Decision (Mandatory)

- `Required`, executed: real image build, throwaway containers, the 1.4.1 control, the server-image overlay, and the agents' real `xvfb-run`.

## Persisted Data / Compatibility

- Not Affected: only `/tmp` in the container's layer. No compatibility code was added. Older images recover with the documented command (V-11).

## Durable Coverage Changed In The Codebase

- By the implementer, validated here:
  - `tests/validate-restart-recovery.sh` (new);
  - `tests/validate-image.sh` (X socket directory and launcher cases);
  - `tests/validate-source-contract.sh` (X socket directory rules).
- By me: none. I added `TESTING.md` (project document).

## Temporary Methods And Cleanup

- Containers `ab596-api-*` (fixed, control, xvfb, overlay, nolabel): removed.
- Images `autobyteus-596-chrome-vnc:api` and `autobyteus-596-server-overlay:api`: removed. The implementer's `:local` images remain for delivery.
- The `start-vnc.sh` mutations: restored (`git status` clean).
- Nothing was pushed.

## Latest Authoritative Result

- Result: `Pass`.
- Criteria accepted as unverified risk: amd64 and `zh` runtime, under DEC-003 (decided in the requirements; no new request).
- Evidence decisions requested: `None`.
- Next recipient: delivery engineer.
- Notes:
  - Release follow-through: run `validate-image.sh` and `validate-running-container.sh` (and preferably the restart check) for both variants on both architectures before publishing, as DEC-003 assumes. Put it in `RELEASE.md`.
  - Then DEC-004's digest bump and server rebuild.
