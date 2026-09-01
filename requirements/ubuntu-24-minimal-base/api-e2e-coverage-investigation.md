# API/E2E Coverage Investigation

## Investigation Meta

- Ticket: `BRD-UBUNTU24-001`
- Requirements Doc / Revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-doc.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` (`RER-006`)
- Investigation Notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/investigation-notes.md`
- Design / Architecture Review: `N/A — approved direct low-risk route`
- Supplemental Artifact: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Implementation Handoff / Revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-revision-record.md` (`IR-003`)
- Code Review / Revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-revision-record.md` (`CRR-004` source Pass; `CRR-003` prior durable-test Pass)
- API/E2E Test Review: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-test-review-report.md`
- API/E2E Revision Record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Current API/E2E revision / round: `API-REV-004` / round 4 IR-003 re-entry
- Prior result reviewed: `API-REV-003 — Fail / 89%`; `APIE2E-F-002`; AC-003
- Assigned worktree / branch: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base`; `requirements/ubuntu-24-minimal-base`
- Implementation under test: `6bbe7a9edab3d19a320ef53e2a99df0fb59b8eef`
- Latest authoritative investigation: this file

## Routing Classification

- Task size / architecture risk: `Medium cumulative; Small re-entry delta` / `Low`
- Route: `Direct Low-Risk`
- Round-4 result: `Pass`
- Final confidence: `96%`
- Successful-output recipient: `/code_reviewer` for proportional review of the round-4 durable source-contract update; then Delivery if that review passes.

## Current Requirement And Changed-Behavior Basis

The approved ticket uses official `ubuntu:24.04`, Noble-native Python 3.12, and release `1.4.0`, preserving AMD64/ARM64, default/`zh`, documented local BuildX execution, `vncuser` and configurable identity, VNC/XFCE/Chromium/websockify/DevTools services, English-default optional Pinyin input, profile persistence, and stale-lock recovery. IR-003 changes only the local host-architecture case label from `aarch64` to `arm64|aarch64`, resolving the supported Apple Silicon spelling without changing Docker platforms, image content, tags, variants, push behavior, runtime, or data.

| Behavior / Boundary | Change Type | Upstream Evidence | Coverage Consequence |
| --- | --- | --- | --- |
| Apple Silicon local-load architecture mapping | Changed | IR-003; CRR-004; `APIE2E-F-002` | Recheck the exact failed command first and require real BuildX build/load/tag evidence. |
| Linux ARM64, AMD64, variants, tags, multi-platform push | Preserved | REQ-003/005; AC-003/004 | Controlled independent alias/command-composition regression plus existing round-3 full builds/indexes. |
| Image/runtime/browser/input/profile behavior | Unchanged / Preserved | IR-003 handoff; AC-005–AC-008/010 | Validate loaded exact-command image and focused live runtime; retain direct round-3 matrix/lifecycle evidence. |
| Publication and server adoption | Deferred | REQ-008/009; AC-011/012 | No push or server write; route through review and Delivery. |

## Changed Surface And Boundary Classification

| Surface / Boundary | Affected? | Actual Boundary / Risk | Evidence Mode |
| --- | --- | --- | --- |
| Build wrapper / CLI lifecycle | Yes | `uname -m` alias could reject a supported local host or change BuildX arguments. | Exact host command plus controlled alias matrix. |
| Image / external package integration | Indirectly reached | Wrapper must reach the unchanged Dockerfile and load a real image. | Clean no-cache Docker/BuildX build and durable image harness. |
| Browser / desktop / process lifecycle | Source unchanged | Need bounded regression that loaded image remains runnable. | Normal entrypoint, durable live harness, host ports and semantic DOM. |
| Persisted data | No implementation change | No migration; round-3 profile/recovery evidence remains valid. | Prior direct lifecycle evidence retained. |
| Backend/API/auth/worker/distributed | No | Not present in this image repository. | N/A. |

## Project Execution Discovery

- Authoritative instructions: `README.md`, `build-multi-arch.sh`, Dockerfile and runtime configuration, both Compose files, and all three scripts under `tests/`; no `AGENTS.md` applies.
- Host: macOS ARM64; real `uname -m=arm64`.
- Docker: Desktop `29.0.1`; BuildX `v0.29.1-desktop.1`; pre-existing `multi-platform-builder` reports `linux/arm64` and `linux/amd64`.
- Pre-existing local `autobyteus/chrome-vnc:latest` was backed up by image ID before the exact command and restored after validation. The task-created `1.4.0` tag, backup tag, container and volume were removed.
- Docker Hub credentials/publication were not used. The AutoByteus server repository was not accessed or modified.

| Component / Fixture | Setup / Readiness | Cleanup |
| --- | --- | --- |
| Real BuildX local path | Exact `./build-multi-arch.sh --no-cache`; builder bootstrap | Loaded task image tag removed; prior `latest` restored. |
| Controlled alias matrix | Temporary PATH-injected `uname`/`docker` doubles; real script/VERSION | Temporary directory removed. |
| Live runtime/profile | Task container, ports and named Chromium profile volume | Container and volume removed. |
| Shared builder | Pre-existing and healthy | Retained; cache not globally pruned. |

## Persisted Data Transition Coverage Basis

- Approved decision: `Not Affected`; no migration, compatibility shim, or dual read/write behavior exists.
- IR-003 changes no image or runtime layer.
- Round-3 representative reuse and stale Chromium/X recovery remain direct valid evidence.
- Round 4 additionally proves the exact-command image writes its task profile marker through the normal runtime harness.

## Existing Durable Coverage Inventory And Decisions

| Path / Scenario | Initial Round-4 Decision | Final Decision / Result |
| --- | --- | --- |
| `tests/validate-source-contract.sh` / AE2E-SCN-001 | `Needs Update` | Added one exact `arm64|aarch64)` contract assertion because the critical alias was not durably protected; Pass. |
| `tests/validate-image.sh` / AE2E-SCN-002 | `Still Valid` | Reused unchanged; Pass on exact-command loaded image. Prior round-3 edit remains reviewed Pass (`CRR-003`). |
| `tests/validate-running-container.sh` / AE2E-SCN-003 | `Still Valid` | Reused unchanged; Pass on exact-command normal runtime. Prior round-3 edit remains reviewed Pass (`CRR-003`). |
| Independent alias matrix / AE2E-SCN-006 | Temporary Executable Probe | `arm64`, `aarch64`, `x86_64`, local/no-cache, `zh`, push, tags and unsupported host all pass. Not retained as another harness because a second Docker/uname-double framework is disproportionate to the one-label delta. |
| Round-3 platform/variant/runtime/input/recovery/index evidence / AE2E-SCN-002–005 | Still Valid | IR-003 touches no Dockerfile/runtime path; retained as current supporting evidence. |

### Durable Coverage Change Result

| Action | Path | Requirement / Rationale | Result |
| --- | --- | --- | --- |
| Update | `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-source-contract.sh` | AC-003/REQ-003: prevent recurrence of the exact missing Apple Silicon alias | Pass; proportional code review required. |
| Add / Remove | None | Existing three-script structure remains sufficient; no stale coverage | N/A. |

## Repository And Broader Execution Results

| Order | Command / Mode | Boundary | Result | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Exact prior-failure command `./build-multi-arch.sh --no-cache` on real `arm64` host | `APIE2E-F-002`; AC-003 | Pass: selected `linux/arm64`, no-cache built, loaded `1.4.0`/`latest` as one ARM64 image | `evidence/host-round4-exact-apple-silicon-build.log` |
| 2 | `bash -n`; `git diff --check`; updated source contract; independent controlled alias matrix | Wrapper syntax/aliases/tags/load/push/variant/failure regression | Pass | `evidence/host-round4-alias-regression.log` |
| 3 | `tests/validate-image.sh autobyteus/chrome-vnc:1.4.0 default 1000 1000` | Loaded image/Noble/tooling/identity | Pass | `evidence/host-round4-image-runtime-regression.log` |
| 4 | Normal entrypoint plus corrected durable runtime harness and host VNC/websockify/DevTools probes | Live runtime/browser/profile regression | Pass | `evidence/host-round4-image-runtime-regression.log` |
| 5 | Task cleanup and pre-existing `latest` restoration | Environment safety | Pass | `evidence/host-round4-cleanup.log` |

The exact build itself returned `0`. The first post-build evidence formatter used an incompatible Docker 29 `join .RepoTags` template and returned a probe-owned error; corrected `json .RepoTags` inspection immediately proved both tags, common digest and ARM64 platform. This did not affect the successful product command or classification.

## Prior Failure Resolution

### APIE2E-F-002 / AC-003

- Previous observed result: `./build-multi-arch.sh --no-cache` rejected `uname -m=arm64` before BuildX.
- Current observed result: the exact same command reports `Building for local architecture (linux/arm64)`, executes BuildX `--load --no-cache --platform linux/arm64`, completes, and loads `autobyteus/chrome-vnc:1.4.0` and `:latest` at digest `sha256:13d9dd530ef09a7f7f91bb3428ce3a1731055d9213f47d91133b64ac0ae60051`.
- Loaded image result: durable image and live runtime/browser/network/profile checks pass.
- Status: `Resolved`.

## Acceptance-Criteria Status

| AC | Result | Evidence / Scope Note |
| --- | --- | --- |
| AC-001–AC-002 | Pass | Round-3 four-target image evidence plus round-4 exact-command Noble ARM64 image. |
| AC-003 | **Pass** | Exact supported Apple Silicon local no-cache command now builds, tags and loads successfully. |
| AC-004 | Pass | Round-3 clean AMD64/ARM64 default/`zh` builds and both local two-platform OCI indexes remain valid; controlled push/variant command regression passes. |
| AC-005–AC-006 | Pass | Round-4 loaded image and live default runtime pass; round-3 custom identity and broader runtime remain valid. |
| AC-007 | Pass | Round-3 live `zh` Pinyin journey and image matrix unaffected by IR-003. |
| AC-008 | Pass | Round-3 persistence/recovery direct evidence unaffected; round-4 task profile write passes. |
| AC-009–AC-010 | Pass | Updated source contract, docs, Noble Python/tool origin and live tooling pass. |
| AC-011 | Ready for Delivery execution, not performed here | Local pre-publication validation passes. Docker Hub publication/remote verification remains Delivery-owned. |
| AC-012 | Deferred to Delivery/follow-up | Server adoption begins only after verified publication; no server change now. |

## Confidence Scorecard

| Category | Post-Repository | Final | Basis / Residual Uncertainty |
| --- | ---: | ---: | --- |
| Requirement and acceptance-criteria proof | 90% | 95% | Reviewed source plus exact prior-failure resolution; only Delivery-owned remote publication remains. |
| Changed-boundary execution directness | 95% | 100% | Exact supported command and real loaded image directly exercise the one-line boundary. |
| Cross-boundary integration realism / mock gap | 95% | 95% | Real Docker/BuildX/image/services/browser; controlled aliases supplement rather than replace real host execution. |
| Environment/configuration/identity/fixture fidelity | 95% | 95% | Real Apple Silicon host, pre-existing tag preserved, task runtime/volume; round-3 architectures/variants remain valid. |
| Failure/edge/lifecycle/recovery evidence | 90% | 95% | Exact prior failure, other host spellings, unsupported host, runtime/profile and prior recovery directly covered. |
| User surface/browser/desktop confidence | 95% | 95% | Focused live semantic Chromium regression plus unchanged round-3 VNC/Pinyin evidence. |
| Durable regression coverage quality | 95% | 95% | Three narrow scripts pass; new one-line source assertion awaits proportional review. |

- Overall post-repository confidence: `94%` (rounded simple average).
- Overall final confidence: `96%` (rounded from 95.7%).
- Every critical API/E2E acceptance criterion directly proven: `Yes`.
- Any applicable category below 90%: `No`.
- Default clean-confidence target met: `Yes`.
- Broader-validation decision: `Required and completed` — exact real host BuildX plus focused loaded-image/runtime regression closed the remaining gap.

## Deferred Scope / Reroute Triggers

| Boundary | Status / Risk | Follow-up |
| --- | --- | --- |
| Docker Hub tags/manifests and published artifact identity | Not tested by API/E2E; no local blocker remains | Delivery after proportional source-test review. |
| AutoByteus server adoption | Separate sequenced ticket | Use verified published digest later; no current server write. |
| Durable source-contract update | Pass locally but changed after CRR-003 | `/code_reviewer` proportional review before Delivery. |

## Cleanup And Investigation Decision

Task container, volume, `1.4.0` image tag and backup tag were removed. The pre-existing `autobyteus/chrome-vnc:latest` image ID was restored exactly. Temporary doubles were removed. The shared BuildX builder/cache was retained. Docker Hub and the server repository were untouched.

- Proceeded to focused API/E2E execution: `Yes`.
- Repository-resident durable coverage updated: `Yes — tests/validate-source-contract.sh`.
- Final result: `Pass`.
- Final confidence: `96%`.
- Prior failure resolved: `APIE2E-F-002 / AC-003`.
- Required route: `/code_reviewer` for proportional review of the one-line durable source-contract assertion; Delivery becomes eligible only after that review passes.
