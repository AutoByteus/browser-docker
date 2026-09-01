# Implementation Handoff

## Upstream Artifact Package

- Requirements doc: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-doc.md` (`RER-007`)
- Investigation notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/investigation-notes.md`
- Design spec: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/design-spec.md`
- Supplemental task artifact: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Solution revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/solution-revision-record.md` (`SR-001`, `SR-002`)
- Design review report: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/design-review-report.md` (`Pass`)
- Architecture review revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/architecture-review-revision-record.md` (`ARCH-REV-002`)
- Feasibility evidence: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-probe.log`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-amd64-availability.log`
- Triggering current-state context: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/delivery-revision-record.md` (`DR-003`); `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/implementation-ir-004-latest-base-integration-check.log`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/delivery-dr003-integration-refresh.log`

## Current Implementation Summary

Starting from integrated revision `cc30abff0769553c84fb1ebb453c28e6123f4218`, IR-005 implements the reviewed Python 3.13/Noble design as a clean provider replacement:

- Canonical `ubuntu:24.04` and Noble's distribution-owned `/usr/bin/python3` remain intact.
- The Deadsnakes Noble PPA supplies `python3.13`, `python3.13-dev`, and `python3.13-venv` for the supported architectures.
- Public `python3` and `python` resolve through `/usr/local/bin` symlinks to `/usr/bin/python3.13`; `/usr/bin/python3` is not repointed.
- `/opt/browser-tools` is created explicitly with `/usr/bin/python3.13` and is the sole owner of `supervisor==4.3.0`, websockify, and `uv`.
- `/usr/local/bin/supervisord`, `supervisorctl`, `websockify`, and `uv` select that environment; `/usr/local/share/websockify` remains the computed, Python-minor-independent asset boundary.
- Explicit apt Supervisor, Python 3.12 developer/pip/venv packages, `python-is-python3`, global pip, `update-alternatives`, `/usr/bin/supervisord`, and runtime fallback behavior are absent.
- `entrypoint.sh` executes `/usr/local/bin/supervisord` directly after the preserved configured-identity/XDG/DBus/profile/VNC preparation.
- README now states Python 3.13 and Supervisor 4.3.0.

Ubuntu 24.04, version `1.4.0`, default/`zh`, AMD64/ARM64, Apple/Linux ARM aliases, configured UID/GID and dynamic XDG/DBus behavior, `gh`, Node.js 22, Yarn, mobile-safe Chromium, services/endpoints, locale/input, persistent profile/recovery, build/load/push/tag, and publication sequencing are preserved. No server source or durable API/E2E test changed.

- Implementation cycle: `Rework`
- Implementation revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-revision-record.md`
- Current implementation revision ID: `IR-005`
- Related solution revision IDs: `SR-001`, `SR-002`
- Related architecture-review revision IDs: `ARCH-REV-002`
- Related code-review revision IDs: `CRR-004`, `CRR-005` are pre-IR-005 context only
- Related API/E2E revision IDs: `API-REV-004` is pre-IR-005 context only
- Related delivery revision IDs: `DR-003`
- Triggering finding IDs: `N/A — ARCH-F-001 resolved upstream; ARCH-REV-002 is Pass`

## Reviewed Behavior Implementation Trace

| Behavior ID | Approved Change / Preserved Outcome | Implemented Production Path / Key Files | Result / Notes |
| --- | --- | --- | --- |
| `BEH-001` | Retain official minimal Ubuntu 24.04, release `1.4.0`, default/`zh`, AMD64/ARM64, local-load, push, and tag behavior while composing Python 3.13. | `Dockerfile` keeps `ubuntu:24.04` and adds the Deadsnakes Noble source/package family; unchanged `VERSION` and `build-multi-arch.sh` retain release/platform/variant/tag semantics and `arm64\|aarch64` mapping. | Source implementation complete; final cross-platform clean builds and release-equivalent checks remain API/E2E/Delivery work. |
| `BEH-002` | Public Python 3.13 and compatible isolated Supervisor/tooling while preserving the full runtime/service/profile/identity behavior. | `Dockerfile` separates OS and public Python, creates the sole `/opt/browser-tools` provider, and exposes stable commands/assets; `entrypoint.sh` deterministically launches `/usr/local/bin/supervisord`; unchanged `base.conf` consumes stable commands/assets and retains the service graph. | Source/config implementation complete. Focused ownership/path/config checks pass; built-image and live-runtime behavior remain downstream. |
| `BEH-003` | README, image identity, and deferred follow-up intake identify Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 and verified 1.4.0 artifacts. | `README.md` reflects Python 3.13/Supervisor 4.3.0; the architecture-reviewed `server-base-image-adoption-follow-up.md` is already aligned and remains deferred/non-authorizing. | Current source/supplement aligned; published identity cannot be claimed before downstream release verification. |

## Key Files Or Areas

- `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/Dockerfile` — interpreter source/packages, OS/public separation, sole operational-tools environment, and stable selectors/assets.
- `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/entrypoint.sh` — one absolute Supervisor 4.3.0 runtime handoff after preserved preparation.
- `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/base.conf` — unchanged service graph using public `websockify` and stable assets.
- `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/README.md` — current Ubuntu/Python/Supervisor/tool documentation.
- `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/build-multi-arch.sh` and `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/VERSION` — preserved build/release contract.
- `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/implementation-ir-005-python313-noble-check.log` — focused implementation evidence.

## Important Assumptions

- The reviewed Deadsnakes Noble packages remain available for AMD64/ARM64 at final clean-build time; retained probes resolved `3.13.15-1+noble1` on both targets.
- Standard image PATH precedence selects `/usr/local/bin` before `/usr/bin` for root and `vncuser`; API/E2E must prove the actual built-image resolution.
- Python 3.13 `venv` creates the isolated pip environment and PyPI continues to provide Supervisor 4.3.0, websockify, and `uv` compatible with the final platform targets.
- Existing manual Supervisor config/log/socket directories remain sufficient after removing the apt provider; downstream real-config execution must confirm no hidden distribution-package filesystem dependency.

## Known Risks

- Deadsnakes, PyPI, Ubuntu, XtraDeb, and NodeSource are mutable remote inputs. Implementation reused the reviewed feasibility evidence but did not rebuild the complete final image.
- `websockify` and `uv` remain intentionally unpinned; final resolved versions and behavior must be recorded downstream.
- The repository's current durable source/image/runtime harnesses still assert the superseded Python 3.12/no-Deadsnakes/distribution-Supervisor target. They were intentionally not edited or executed by Implementation; API/E2E owns the coverage investigation, corrections, execution, and subsequent durable-test code-review loop.
- Publication, remote manifest/runtime identity, explicit user verification, finalization, and server adoption remain blocked.

## Task Design Health Assessment Implementation Check

- Reviewed change posture: `Behavior Change` with bounded runtime-provider refactor.
- Reviewed root-cause classification: `Boundary Or Ownership Issue` plus `Legacy Or Compatibility Pressure`.
- Reviewed refactor decision: `Refactor Needed Now`
- Implementation matched the reviewed assessment: `Yes`
- If challenged, routed as `Design Impact`: `N/A`
- Evidence / notes: Noble `/usr/bin/python3` remains the OS authority; `/usr/local` owns public developer selectors; `/opt/browser-tools` owns exactly Supervisor/websockify/`uv`; entrypoint depends on one public Supervisor boundary. No caller or runtime path depends on both the new owner and a removed provider.

## Legacy / Compatibility Removal Check

- Backward-compatibility mechanisms introduced: `None`
- Legacy old-behavior retained in scope: `No`
- Dead/obsolete code, files, helpers, flags, adapters, and dormant replaced paths removed in scope: `Yes — explicit apt Supervisor, Python 3.12 dev/pip/venv selection, python-is-python3, /usr/bin Supervisor exec, and potential dual-provider shape are removed`
- Shared structures remain tight: `Yes — /opt/browser-tools contains only Supervisor, websockify, and uv`
- Canonical shared design guidance reapplied: `Yes`
- Changed source implementation files stayed within proactive guardrails: `Yes — Dockerfile 173, entrypoint.sh 77, and README 102 effective non-empty/non-comment lines; largest delta is Dockerfile +14/-10`
- Notes: No fallback, global-pip, `update-alternatives`, mixed Supervisor, secondary public Python, or Python-minor-specific service asset path was introduced.

## Persisted Data Transition Check

- Approved decision: `Not Affected`
- Design-spec decision reference: `design-spec.md` → `Persisted Data / State Transition Decision`
- Implementation follows the approved decision without migration or runtime compatibility fallback: `Yes`
- Direct-use evidence: Chromium profile location, ownership preparation, profile-lock detection/cleanup, and recreation behavior are unchanged by IR-005.
- Migration implementation: `N/A`
- Deviation: `None`

## Environment Or Dependency Notes

- Current production starting revision: `cc30abff0769553c84fb1ebb453c28e6123f4218`.
- ARM64 Noble public-Python/tool-boundary probe and AMD64 package-availability probe are upstream feasibility evidence, not final executable validation.
- Reviewed RER-007/SR-001/SR-002/ARCH-REV-002 solution artifacts and Delivery-owned DR-003 artifacts remain unmodified by Implementation and were hash-verified byte-for-byte after source changes.
- Implementation changed no file under `tests/`; durable coverage remains API/E2E-owned.

## Local Implementation Checks Run

Evidence: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/implementation-ir-005-python313-noble-check.log`.

- Verified exact reviewed starting revision `cc30abf`.
- Bash syntax and ShellCheck over production scripts — passed; only pre-existing intentional SC2086 sites were excluded.
- `git diff --check` — passed.
- Noble/Deadsnakes/Python 3.13 package-source and stale apt-payload removal assertions — passed.
- Public `/usr/local` Python selectors and preserved `/usr/bin/python3` ownership assertions — passed.
- Sole `/opt/browser-tools` Supervisor 4.3.0/websockify/`uv` provider, stable commands, and stable assets — passed.
- Rejected global-pip, `update-alternatives`, apt Supervisor, `/usr/bin/supervisord`, fallback, and Python-minor asset-path scans — passed.
- Supervisor INI parsing, complete program-section inventory, Chrome wrapper command, and websockify stable command — passed.
- Preserved version, `gh`, Node/Yarn, dynamic XDG/DBus, ARM/platform, `zh`, Chrome normal/mobile-safe, and port contracts — passed.
- README Python 3.13/Supervisor 4.3.0 assertion and obsolete active-source scan — passed.
- Reviewed ARM64 boundary and AMD64 availability evidence presence — passed.
- Source-size/change-pressure guardrails — passed.
- Upstream artifact hashes and no durable-test delta — passed.
- Full Docker/BuildX image/runtime checks — not run by Implementation; API/E2E required.

## Frontend Rendered-Result Check

Not Applicable — this change affects container packaging, interpreter/tool ownership, and process startup rather than a rendered implementation surface. Browser/VNC/IME rendering and interaction remain downstream executable coverage.

## Downstream Coverage Hints / Suggested Scenarios

1. Coverage investigation must classify and replace the stale Python 3.12/no-Deadsnakes/distribution-Supervisor assertions in all three durable harnesses; any edits return through proportional code review after successful API/E2E.
2. Clean-build default and `zh` for ARM64 and AMD64. Confirm Deadsnakes Noble origin and exact resolved packages on each target.
3. In each built target, prove `/usr/bin/python3` remains Noble 3.12 while `command -v python3`/`python` are `/usr/local/bin` and report 3.13; prove `/opt/browser-tools` uses Python 3.13.
4. Prove `/usr/local/bin/supervisord` and `supervisorctl` resolve to the venv, Supervisor reports 4.3.0, the real config starts without the prior Python compatibility traceback, and no apt Supervisor provider remains.
5. Prove websockify/`uv` resolve to the same venv and `/usr/local/share/websockify` serves valid HTTP/WebSocket assets.
6. Re-run default/custom UID, dynamic XDG/DBus, default/`zh`, English/Pinyin, Chrome normal/mobile-safe, VNC/DevTools/websockify, profile recreation, and stale-lock recovery journeys.
7. Re-run Apple/Linux ARM aliases, local load, default/`zh` tags, and no-push multi-platform readiness.
8. Do not publish or return to Delivery until source review, API/E2E, and proportional review of durable coverage edits pass.

## API / E2E / Executable Coverage Investigation And Execution Still Required

Current source review is required first. API/E2E then owns the coverage investigation, durable test corrections, complete integrated Docker matrix, evidence, and pass/fail classification. If durable tests change, the updated state must return through Code Review before Delivery. Docker Hub publication, remote verification, explicit user verification, repository finalization, and server adoption remain blocked.
