# API/E2E Execution Coverage Report

## Execution Round Meta

- Requirements Doc: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-doc.md`
- Investigation Notes: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/investigation-notes.md`
- Requirements Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-revision-record.md`
- Design Spec: `N/A — not applicable`
- Supplemental Task Artifacts: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Architecture Design Revision Record: `N/A — not applicable`
- Design Review Report: `N/A — not applicable`
- Architecture Review Revision Record: `N/A — not applicable`
- Implementation Handoff: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-handoff.md`
- Implementation Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-revision-record.md` (`IR-001`)
- Code Review Report: `N/A — not applicable`
- Code Review Revision Record: `N/A — not applicable`
- Delivery Revision Record: `N/A — initial validation`
- Relevant Delivery Revision IDs: `N/A`
- Coverage Investigation: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
- API/E2E Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Current API/E2E Revision ID: `API-REV-001`
- Current Execution Round: `1`
- Trigger: Direct API/E2E handoff from Implementation Engineer at commit `bf290fd`.
- Prior Round Reviewed: `N/A — no prior completed API/E2E result`
- Latest Authoritative Round: This file.

## Routing Classification

- Task size: `Medium`
- Architectural risk: `Low`
- Input route: `Direct Low-Risk`
- Successful-output route: `Delivery`
- Proportional test-code review decision: `Not Required — direct low-risk route`; this round did not pass and is routed by the failure rule instead.

## Investigation And Execution Basis

- Coverage investigation completed before durable coverage changes or final execution: `Yes`.
- Investigation plan followed: `Yes`, through the mandatory clean default build gate. Later image/runtime/multi-platform steps stopped when the build failed.
- Existing coverage decisions revised during execution: No prior durable tests existed. Three requirement-linked scripts were added. The source script passed; built-image/runtime scripts could not run because no image was produced.
- Reroute required during execution: `Yes — critical AC-003 implementation failure`.
- Notes: Docker/BuildX was absent at intake. Docker, BuildX, QEMU, Podman and Buildah were installed. A nested Docker daemon could not start containers because the outer cgroup filesystem is read-only. A task-isolated Podman/Buildah VFS build with chroot execution then ran the exact Dockerfile, with no cache and real Ubuntu/XtraDeb/NodeSource inputs, and reached a deterministic Dockerfile error unrelated to builder semantics. Both official platform roots were independently inspected to confirm the same precondition.

## Compatibility / Legacy Scope Check

- Reviewed requirements/design introduce, tolerate, or ambiguously describe backward compatibility in scope: `No`.
- Compatibility-only or legacy-retention behavior observed in implementation: `No`.
- Approved persisted-data transition followed without unnecessary migration or version-specific runtime fallback: `N/A — image did not build; source still reflects the approved Not Affected decision`.
- Durable coverage added or retained only for compatibility-only behavior: `No`.
- Compatibility reroute: `N/A`.
- Upstream recipient notified: Dynamic handoff occurs after this report and revision record are persisted.

## Changed Boundary And Evidence Matrix

| Scenario ID | Behavior / Requirement / AC IDs | Changed Boundary | Execution Surface / Mode | Evidence Type | Result | Evidence / Artifact |
| --- | --- | --- | --- | --- | --- | --- |
| AE2E-SCN-001 | BEH-001–BEH-003; source portions of AC-001–AC-004, AC-009, AC-011–AC-012 | Base/release/tag/path/docs declarations | Durable source harness | Durable | Pass | `tests/validate-source-contract.sh`; `evidence/repository-checks.log` |
| AE2E-SCN-004 | REQ-001–REQ-005; AC-002–AC-004 | Exact official base and clean default build | No-cache real Dockerfile build on ARM64 using task-isolated Podman/Buildah chroot | Live / Temporary | **Fail** | `evidence/build-default-arm64.log`; `evidence/base-identity-and-uid-collision.log` |
| AE2E-SCN-002 | AC-001, AC-006–AC-007, AC-010 | Completed image identity/tool/package/variant | Durable image harness | Durable | Not Tested | Default image was not produced. |
| AE2E-SCN-003 | AC-005–AC-008, AC-010 | Supervisor/services/browser/VNC/websockify/profile | Durable runtime harness | Durable / Live / Browser | Not Tested | Default image was not produced. |
| AE2E-SCN-005 | AC-005, AC-007 | Semantic browser rendering and supporting desktop evidence | Browser/DevTools/VNC | Browser | Not Tested | Runtime prerequisite failed. |

## Acceptance-Criteria Result Matrix

| Acceptance Criterion | Result | Direct Evidence / Reason |
| --- | --- | --- |
| AC-001 | Not Tested (source portion passed) | Dockerfile resolves to explicit `ubuntu:24.04`; the exact ARM64 base was pulled, but no completed product image exists for `/etc/os-release` inspection. |
| AC-002 | Pass | Exact Docker Official `ubuntu:24.04` platform roots were pulled/inspected for ARM64 and AMD64 by digest; the source has no alternate/heavyweight base. |
| AC-003 | **Fail** | The no-cache default ARM64 build installed real Noble dependencies, then exited status 4 at `groupadd -g 1000 vncuser`. Current official Noble roots already define `ubuntu` UID/GID 1000. |
| AC-004 | Not Tested | Full default/`zh` AMD64/ARM64 builds stopped at the failed default build gate. Base-root inspection confirms both architectures have the same default-ID collision, but this is not claimed as a full build result. |
| AC-005 | Not Tested | No runnable image. |
| AC-006 | Not Tested | No runnable default or custom-ID image. |
| AC-007 | Not Tested | No `zh` image. |
| AC-008 | Not Tested | No image for profile recreation/recovery. |
| AC-009 | Pass | Durable source scan and documentation review found the intended 24.04/Python 3.12 identity and no active 22.04 claim. |
| AC-010 | Not Tested | Python packages began resolving from Noble, but the completed interpreter/tool/websockify image contract could not be inspected or started. |
| AC-011 pre-publication | **Fail — not release-ready** | `VERSION=1.4.0` and tag/platform source semantics pass, but required builds/runtime checks have not passed. No publication was attempted. |
| AC-012 pre-publication | **Fail — gate not met** | No publishable immutable images/digests exist; server repository work remained untouched and deferred. |

## Additional Repository Coverage Execution

No commands were added after the investigation's repository result and confidence decision. The authoritative command/results table is in `api-e2e-coverage-investigation.md`.

## Validation Confidence Scorecard

Broader runtime validation did not run because the build gate failed, so post-repository and final scores are the same.

| Confidence Category | Post-Repository Score | Final Score | Change | New / Final Supporting Evidence | Residual Uncertainty |
| --- | --- | --- | --- | --- | --- |
| Requirement and acceptance-criteria proof | 35% | 35% | 0 | Direct AC-003 failure; AC-002/AC-009 pass | Most runtime criteria not reached |
| Changed-boundary execution directness | 75% | 75% | 0 | Exact Dockerfile and real official base/packages executed to failure | No completed image |
| Cross-boundary integration realism and mock gap | 40% | 40% | 0 | Real remote dependency resolution; no mocks | No service/browser/profile integration |
| Environment, configuration, identity, and fixture fidelity | 75% | 75% | 0 | ARM64 host, no-cache real build, both exact platform base roots inspected | No Docker BuildX execution because nested cgroups prevented it |
| Failure, edge-case, lifecycle, and recovery evidence | 45% | 45% | 0 | Deterministic build failure and cross-platform base precondition | Lifecycle/recovery not reached |
| User-surface, browser, and desktop-shell confidence | 0% | 0% | 0 | None; no runnable upgraded image | Entire user surface untested |
| Durable regression coverage quality and relevance | 75% | 75% | 0 | Three focused scripts added; source gate executed and passed | Image/runtime scripts await a repaired build |

- Overall post-repository confidence: `49%`.
- Overall final confidence: `49%`.
- Calculation method: Simple average of seven applicable categories, rounded from 49.3%.
- Confidence change produced by broader validation: `0` — broader runtime validation could not begin after the build failure.
- Every critical acceptance criterion directly proven: `No`; AC-003 directly fails.
- Any final applicable category below 90%: `Yes — all seven`.
- Default final confidence target of 95% met: `No`.
- Confidence-limiting residual risks: In addition to the proven default user-creation defect, all built-image runtime, `zh`, custom-ID, persistence/recovery and multi-platform completion behavior remains unverified.

## Broader Validation Decision And Execution

- Decision/mode from investigation: `Required — CLI, Live API, Lifecycle, Browser`.
- Material deviation: The runtime/browser/lifecycle portion was stopped because the clean default build failed.
- Confidence gap addressed: The clean build directly disproved default image buildability; static/source evidence alone would have missed the pre-existing Noble `ubuntu` UID/GID.
- Startup order/readiness: Container runtime installation and nested Docker attempts completed; nested Docker container execution was unavailable due outer cgroups. The alternate no-cache real Dockerfile build started, resolved the official base and real repositories, installed dependencies, generated `en_US.UTF-8`, then failed before image creation. No service readiness was possible.
- Environment choices: ARM64 host; isolated `/tmp/brd-*` stores; no registry push; exact branch/commit; no application accounts/secrets.
- Fixtures/identities: Default build identity `USER_UID=1000`/`USER_GID=1000`; exact base platform roots for ARM64 and AMD64.

| Scenario / Journey Step | Expected Observable Result | Actual Observable Result | Evidence | Result |
| --- | --- | --- | --- | --- |
| Pull exact ARM64 `ubuntu:24.04` and start no-cache build | Official Noble base resolves and build proceeds | Base digest `sha256:33ceb719…`; Noble/XtraDeb/NodeSource repositories and packages resolved | Build/base logs | Pass |
| Create preserved default `vncuser` identity | `groupadd -g 1000 vncuser` and subsequent `useradd` succeed | `groupadd: GID '1000' already exists`; build exits 4 because base already has `ubuntu:x:1000` | Build/base logs | **Fail** |
| Inspect both official platform base roots | Identify whether the failure is architecture-specific | Both ARM64 and AMD64 roots contain `ubuntu` with UID/GID 1000 | Base identity log | Pass (failure classification evidence) |
| Start default/`zh` and validate services/browser/profile | Stable Supervisor and user surfaces | Not reached; no image | Build log | Not Tested |

## Desktop Application Validation

- Planned approach: Real Chromium DevTools semantic DOM assertion plus VNC/websockify/process evidence.
- Browser-tested web-equivalent behavior: Not executed.
- Shell-specific/lifecycle behavior: Not executed.
- Effect on already-running desktop application: None. No current environment display/profile or unrelated container was modified.
- Confidence consequence: User-surface category remains 0% and blocks Pass independently of the proven build failure.

## Platform / Runtime Targets

- Host: Linux ARM64 (`aarch64`), kernel `6.12.54-linuxkit`.
- Requested image targets: `linux/arm64`, `linux/amd64`.
- Build/runtime tooling installed for validation: Docker Engine/CLI 29.1.3, BuildX 0.30.1, Podman 3.4.4, Buildah 1.23.1, QEMU user-static 6.2.
- Actual failing build target: ARM64; both target base roots separately inspected.
- Browser/engine: Not reached.

## Lifecycle / Upgrade / Restart / Persisted-Data Checks

- Approved persisted-data decision: `Not Affected`.
- Representative existing data exercised: None; image prerequisite failed.
- Direct-use/discard/migration result: Not tested.
- Migration completion/recovery: `N/A — no migration approved`.
- Version-specific runtime branch, dual read/write, or compatibility fallback observed: `No` in source review.
- Residual persisted-data risk: Profile persistence and stale-lock cleanup remain entirely unexecuted and must be rerun after the build fix.

## Tests Implemented Or Updated

| Path / Scenario | Change | Requirement / Boundary | Execution Result | Notes |
| --- | --- | --- | --- | --- |
| `tests/validate-source-contract.sh` / AE2E-SCN-001 | Added | AC-001–AC-004, AC-009, pre-publication AC-011/AC-012 | Pass | Fast source/release/path/docs gate. |
| `tests/validate-image.sh` / AE2E-SCN-002 | Added | AC-001, AC-006–AC-007, AC-010 | Not Tested | Requires a successfully built image. |
| `tests/validate-running-container.sh` / AE2E-SCN-003 | Added | AC-005–AC-008, AC-010 | Not Tested | Includes Supervisor/process, VNC, WebSocket, DevTools semantic DOM and profile-write probes. |

## Tests Removed As Stale Or Obsolete

None.

## Durable Coverage Changed In The Codebase

- Repository-resident durable coverage added, updated, or removed this round: `Yes — three files added; none updated/removed`.
- Paths added: `/home/autobyteus/workspace/browser-docker/tests/validate-source-contract.sh`; `/home/autobyteus/workspace/browser-docker/tests/validate-image.sh`; `/home/autobyteus/workspace/browser-docker/tests/validate-running-container.sh`.
- Paths removed: None.
- Added paths attached for proportional test-code review: `Not Applicable — direct low-risk route`; they remain included in the complete failure package.

## Other Execution Artifacts

| Artifact Path | Type / Purpose | Retained Or Temporary | Notes |
| --- | --- | --- | --- |
| `requirements/ubuntu-24-minimal-base/evidence/repository-checks.log` | Syntax/static/Supervisor/source evidence | Retained | Passing checks. |
| `requirements/ubuntu-24-minimal-base/evidence/build-default-arm64.log` | Complete clean build output | Retained | Authoritative failing command output. |
| `requirements/ubuntu-24-minimal-base/evidence/base-identity-and-uid-collision.log` | ARM64/AMD64 base digest/root identity evidence | Retained | Confirms failure mechanism on both targets. |

## Temporary Execution Methods / Scaffolding

| Path / Method | Why Needed | Result / Evidence | Cleanup Result |
| --- | --- | --- | --- |
| Task-specific nested Docker daemon attempts under `/tmp/brd-ubuntu24-*` | Try the repository's documented Docker/BuildX route after installing missing tools | Daemon initialized, but nested containers could not use the read-only outer cgroup hierarchy | Daemon stopped; task data scheduled for removal after text evidence persisted |
| Task-specific Podman/Buildah VFS/chroot stores | Execute the exact Dockerfile and real dependency boundary without nested cgroups | Reproduced builder-independent UID/GID failure | No processes remain; stores removed after evidence capture |
| Temporary Supervisor config under `/tmp` | Parse repository `base.conf` with custom XDG path without touching system config | Pass | Removed after evidence capture |

## Dependencies Mocked Or Emulated

| Dependency | Method | Why Real Dependency Was Not Used | Confidence Limitation |
| --- | --- | --- | --- |
| Docker BuildX execution engine | Podman/Buildah chroot executed exact Dockerfile after Docker daemon cgroup failure | Outer container exposes cgroup v2 read-only | Full BuildX/platform output is still required after correction; the observed `groupadd` semantics and base files are not builder-specific. |

## Result Summary

| Result | Scenario IDs | Summary / Reason |
| --- | --- | --- |
| Pass | AE2E-SCN-001 | Static/source/release/path/documentation contract gate passed. |
| **Fail** | AE2E-SCN-004 | Critical AC-003 default clean build fails on the official Noble base's pre-existing UID/GID 1000. |
| Not Tested | AE2E-SCN-002, AE2E-SCN-003, AE2E-SCN-005 | Built-image, runtime, browser, `zh`, custom-ID and recovery prerequisites were not met. |

## Cleanup Performed

| Resource / Process / Data | Ownership | Cleanup Action | Result |
| --- | --- | --- | --- |
| Nested Docker daemon sessions | API/E2E round | Interrupted gracefully | Pass; no daemon remains |
| Podman API service | API/E2E round | Interrupted | Pass; no service remains |
| Validation containers | API/E2E round | Failed/temporary instances removed by task tools | Pass; none running |
| Task build/rootfs stores | API/E2E round | Removed after extracting text evidence | Pass |
| Docker Hub / external registry | Delivery-owned | No push or mutation attempted | Pass |
| AutoByteus server repository | Out of scope | No source write performed | Pass |

## Preliminary Classification

- Finding ID: `APIE2E-F-001`.
- Classification: `Local Fix — implementation` (preliminary).
- Expected: The default clean build preserves UID/GID 1000 and creates the `vncuser` runtime identity successfully on official Ubuntu 24.04.
- Observed: Official Ubuntu 24.04 currently includes `ubuntu` with UID/GID 1000 on both target platform roots. Dockerfile line 95 unconditionally calls `groupadd -g ${USER_GID} vncuser`; with the default `USER_GID=1000`, the ARM64 clean build exits status 4 before an image exists.
- Recommended owner: Implementation Engineer, after Code Reviewer confirms failure origin.

## Recommended Recipient

Dynamic handoff recipient for an API/E2E `Fail` (normally `/software_engineering_team/code_reviewer`) for focused failure-origin review.

## Evidence / Notes

This is not an environment blocker: the exact clean Dockerfile execution failed in an implementation-owned command, and the relevant base files independently confirm the same collision for AMD64 and ARM64. Docker Hub publication must not occur. On rework, first rerun AC-003 and `APIE2E-F-001`, then reuse AE2E-SCN-001 through AE2E-SCN-005 to complete the entire matrix.

## Latest Authoritative Result

- Result: `Fail`.
- Final validation confidence: `49%`.
- Default 95% confidence target met: `No`.
- Any final applicable confidence category below 90%: `Yes — all seven`.
- Broader validation decision: `Required but stopped at failed build gate`.
- Critical acceptance criteria lacking direct proof: AC-001 runtime, AC-004–AC-008, AC-010, and the pre-publication readiness portions of AC-011/AC-012; AC-003 directly fails.
- Required next recipient: Dynamic API/E2E failure recipient for focused failure-origin review.
- Notes: No publication or server adoption may begin from this result.
