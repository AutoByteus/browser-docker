# API/E2E Coverage Investigation

## Investigation Meta

- Requirements Doc: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-doc.md`
- Investigation Notes: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/investigation-notes.md`
- Requirements Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-revision-record.md`
- Design / Architecture Review Artifacts: `N/A — not applicable; approved direct route`
- Supplemental Task Artifact: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Implementation Handoff / Revision: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-revision-record.md` (`IR-002`)
- Failure-Origin Review / Revision: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/code-review-report.md`; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/code-review-revision-record.md` (`CRR-001`)
- API/E2E Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Current API/E2E Revision ID: `API-REV-002`
- Current Investigation Round: `2`
- Trigger: Implementation Engineer re-entry at commit `e604ffa` after `IR-002` corrected confirmed finding `APIE2E-F-001`.
- Prior Investigation Reviewed: `Yes — API-REV-001, prior result Fail / 49%.`
- Latest Authoritative Investigation: This file.

## Routing Classification

- Task size: `Medium`
- Architectural risk: `Low`
- Input route: `Direct Low-Risk`
- Successful-output route: `Delivery`
- Proportional test-code review decision: `Not Required — direct low-risk route`

## Requirement And Changed-Boundary Basis

The approved package moves both browser-image variants to official `ubuntu:24.04`, Noble-native Python 3.12, and release `1.4.0` while preserving AMD64/ARM64 builds, `vncuser`, configurable UID/GID, ports 5900/6080/9223, Supervisor-managed desktop/browser/VNC/websockify/debugging services, English-default locale, optional Chinese Pinyin, Chromium profile persistence, and stale-lock recovery. Docker Hub publication is Delivery-owned. AutoByteus server adoption is a separate deferred ticket and its repository was not modified.

| Boundary | Requirement / AC | Required Evidence | Round-2 Status |
| --- | --- | --- | --- |
| Official Noble base and clean builds | AC-001–AC-004 | No-cache exact Dockerfile builds for default/`zh` and AMD64/ARM64 | ARM64 default passed; remaining three targets stopped at user direction. |
| Noble Python and isolated tools | AC-005, AC-010 | Built-image package/origin/tool assertions | Passed for ARM64 default. |
| Runtime services and browser surfaces | AC-005–AC-008, AC-010 | Live Supervisor/process/VNC/WebSocket/DevTools/browser checks | Not tested in round 2. |
| Runtime identity | AC-003, AC-006 | Default and representative custom UID/GID builds/runs | Full default 1000:1000 image passed; full custom build/run not tested. |
| Locale/input | AC-007 | `zh` package, profile, service, and input checks | Not tested. |
| Persistence/recovery | AC-008 | Recreate with task volume and stale locks | Not tested. |
| Release readiness | AC-009, pre-publication AC-011/AC-012 | Version/tag/platform/source contract plus complete validation | Source contract passed; release gate remains unmet because matrix is incomplete. |

## Round-2 Prior-Failure Gate

`APIE2E-F-001` was rechecked first as required. A complete no-cache ARM64 default build of the exact commit-`e604ffa` Dockerfile succeeded using Podman/Buildah OCI isolation with real official Ubuntu, Ubuntu archive, XtraDeb, NodeSource, PyPI, and npm inputs. In the completed image, numeric UID/GID 1000 resolve to `vncuser`; Noble/Python/tool/variant/image assertions also passed. This directly resolves the prior ARM64 default AC-003 collision.

The first round-2 chroot-isolated attempt reached and passed the corrected identity step, then hit a Node/libuv file-descriptor assertion during `npm install`. A task-isolated OCI retry executed the same Dockerfile successfully, demonstrating that the chroot result was an alternate-builder limitation rather than a product failure.

## Project Execution Discovery

- Repository root: `/home/autobyteus/workspace/browser-docker`
- Intake implementation commit: `e604ffa1ee8d3e33aa83a4960b48e434647e965b`
- Authoritative instructions: `README.md`, `build-multi-arch.sh`, `run-container.sh`, Compose files, `Dockerfile`, `entrypoint.sh`, `start-vnc.sh`, `base.conf`, and `supervisord.conf`.
- Repository instruction file: no applicable `AGENTS.md` was found.
- Docker Hub credentials/publication: not required and not used by API/E2E.
- Docker daemon limitation: nested Docker container execution cannot use the outer read-only cgroup hierarchy. This did not prevent the successful exact ARM64 default build/image proof because Podman OCI execution with cgroups disabled was available.
- Stop condition: after the partial successes, the user explicitly directed API/E2E not to continue Podman validation and requested that the branch be pushed for testing in another environment. The incomplete result is therefore a user-directed stop/external-continuation state, not a newly discovered implementation failure and not a claim that no executable validation was possible.

## Persisted Data Transition Basis

- Approved decision: `Not Affected`.
- Intended representative evidence: reuse a task-owned Chromium profile volume, preserve a marker, verify write ownership, and recover from stale Chromium/X locks.
- Round-2 result: not tested because execution stopped before runtime lifecycle coverage.
- Compatibility-only behavior or migration added: none observed.

## Durable Coverage Inventory And Decisions

| Path / Scenario | Decision | Round-2 Evidence / Change |
| --- | --- | --- |
| `tests/validate-source-contract.sh` / AE2E-SCN-001 | Still Valid | Reused; passed source/base/release/path/docs assertions. |
| `tests/validate-image.sh` / AE2E-SCN-002 | Updated | Added `docker run -i` so the heredoc actually executes on Docker-compatible clients; replaced unsupported `websockify --version` with distribution metadata plus executable `--help`. Passed on ARM64 default. |
| `tests/validate-running-container.sh` / AE2E-SCN-003 | Still Valid | Reused unchanged; not executed after the user-directed stop. |
| No-push multi-platform/index probe / AE2E-SCN-004 | Temporary Probe | ARM64 default exact build passed; AMD64/`zh` targets not tested. |
| Semantic Chromium/VNC journey / AE2E-SCN-005 | Temporary/Live | Not tested. |

No durable coverage was removed. The two image-harness changes correct test execution and package-compatible assertions; they do not change product source or approved behavior.

## Repository And Executable Results

| Order | Command / Mode | Boundary | Result | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Bash syntax, `git diff --check`, source contract, exact IR-002 source assertions, obsolete scan, file-size output, task-isolated Supervisor custom-XDG parse | AE2E-SCN-001; static portions AC-001–AC-004, AC-009–AC-012 | Pass | `evidence/repository-checks-round2.log` (an initial non-isolated parser invocation read host `/etc`; the corrected task-isolated parse is authoritative). |
| 2 | Full exact no-cache ARM64 default build, Podman/Buildah OCI, cgroups disabled, host network | AE2E-SCN-004; prior `APIE2E-F-001`; AC-003 | Pass | `evidence/build-default-arm64-oci-round2.log` |
| 3 | Numeric default identity probe and updated `tests/validate-image.sh ... default 1000 1000` | AE2E-SCN-002; AC-001, AC-003, AC-006 default, AC-010 | Pass | `evidence/image-default-arm64-round2.log` |
| 4 | Default runtime, browser/VNC/websockify/debugging and persistence/recovery | AE2E-SCN-003/005; AC-005–AC-008 | Not Tested — user-directed stop | No result claimed. |
| 5 | ARM64 `zh`, AMD64 default/`zh`, full custom 1234:1234 build/runtime | AE2E-SCN-002–005; AC-003–AC-007, AC-010 | Not Tested — user-directed stop | No result claimed. |
| 6 | Local no-push multi-platform OCI indexes/manifests | Pre-publication AC-011/AC-012 | Not Tested — user-directed stop | No publication or manifest claim. |

## Acceptance-Criteria Status

| AC | Status | Evidence / Gap |
| --- | --- | --- |
| AC-001 | Partial Pass | Completed ARM64 default image directly reports Ubuntu 24.04 Noble; other variant/platform targets untested. |
| AC-002 | Pass | Exact official `ubuntu:24.04` was pulled; source uses no alternate base. Prior both-platform base evidence remains relevant. |
| AC-003 | Partial Pass | Prior default-ID failure resolved and full no-cache ARM64 default build passed. Required complete target/variant matrix not finished. |
| AC-004 | Not Tested / incomplete | AMD64 and `zh` complete builds not executed in round 2. |
| AC-005 | Partial Pass | Built-image Python/tool contracts passed; live service graph not executed. |
| AC-006 | Partial Pass | Default 1000:1000 image identity passed; full custom-ID image/runtime not executed. |
| AC-007 | Not Tested | `zh` image/input path not executed. |
| AC-008 | Not Tested | Persistence/recovery lifecycle not executed. |
| AC-009 | Pass | Active source/docs contract scan passed. |
| AC-010 | Partial Pass | ARM64 default image directly proved Noble Python 3.12, Ubuntu package ownership, isolated `/opt/browser-tools`, `uv`, and websockify. Runtime service use and other targets remain untested. |
| AC-011 pre-publication | Not Ready | Version/tag/platform source contract passes, but executable matrix is incomplete; no push occurred. |
| AC-012 pre-publication | Not Ready | No remote image/manifests/digests were published or verified; server adoption remains deferred. |

## Confidence Scorecard

| Category | Final Score | Basis And Residual Gap |
| --- | ---: | --- |
| Requirement and AC proof | 55% | Direct ARM64 default build/image plus source proof; critical runtime, variant, platform, and recovery criteria remain open. |
| Changed-boundary execution directness | 85% | Exact full ARM64 default Dockerfile and real dependencies executed; no completed matrix. |
| Cross-boundary integration realism / mock gap | 50% | Real image integration completed without mocks; live supervised/browser/network boundaries not run. |
| Environment/configuration/identity/fixture fidelity | 80% | Native ARM64, official base, no-cache build, real repositories, default identity; no Docker BuildX, AMD64, custom runtime, or persistence fixture. |
| Failure/edge/lifecycle/recovery evidence | 50% | Prior failure directly resolved; lifecycle, restart, custom identity, and stale-lock recovery remain untested. |
| User surface/browser/desktop confidence | 0% | No round-2 live desktop/browser/VNC journey executed. |
| Durable regression coverage quality | 85% | Source and corrected image harnesses passed; runtime harness remains unexecuted. |

- Overall final confidence: `58%` (simple average, rounded from 57.9%).
- Critical criteria fully proven: `No`.
- Any category below 90%: `Yes — all categories`.
- Default 95% target met: `No`.

## Broader Validation Decision

- Decision: `Required`, but stopped at the user's explicit direction for external continuation.
- Selected but incomplete modes: full platform/variant builds, live process/API/container lifecycle, semantic browser/DevTools, VNC/websockify, locale/input, custom identity, and persistence/recovery.
- This is not a product `Fail`: no new implementation failure was observed after `IR-002`, and `APIE2E-F-001` was resolved for the full ARM64 default image.
- This is not reported as an unavoidable environment blocker: a meaningful Podman build/image path worked. The formal result is `Blocked — user-directed stop/external validation pending` solely because required critical proof remains incomplete and the user asked this stage not to continue.

## Cleanup And Deferred Scope

All API/E2E-created Podman/Buildah stores, containers, temporary wrappers/configuration, `/dev/net/tun`, and binfmt registration/mount were removed or restored. No validation process remains. Docker Hub was not mutated. The AutoByteus server repository was not modified.

## Investigation Decision

- Proceed to further local API/E2E execution: `No — user explicitly directed the stage to stop`.
- Latest result: `Blocked — user-directed stop/external validation pending`.
- Final confidence: `58%`.
- Prior failure resolved: `Yes — APIE2E-F-001/AC-003 for the full ARM64 default image`.
- Remaining required scope: default runtime; ARM64 `zh`; AMD64 default/`zh`; full custom ID; locale/input; browser/VNC/websockify/debugging; persistence/recovery; local no-push multi-platform readiness.
- Publication status: `Not ready and not attempted`.
