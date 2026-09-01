# API/E2E Execution Coverage Report

## Execution Round Meta

- Ticket: `BRD-UBUNTU24-001`
- Current API/E2E revision / round: `API-REV-004` / round 4 IR-003 re-entry
- Requirements / revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-doc.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` (`RER-006`)
- Investigation notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/investigation-notes.md`
- Design / architecture review: `N/A — approved direct low-risk route`
- Supplemental artifact: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Implementation / revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-revision-record.md` (`IR-003`)
- Code review / revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-revision-record.md` (`CRR-004` source Pass; `CRR-003` prior durable-test Pass)
- Prior API/E2E test review: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-test-review-report.md`
- Coverage investigation: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
- API/E2E revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Implementation under test: `6bbe7a9edab3d19a320ef53e2a99df0fb59b8eef`
- Prior round: `API-REV-003 — Fail / 89%`; `APIE2E-F-002` / AC-003
- Latest authoritative report: this file

## Latest Authoritative Result

- Result: `Pass`.
- Final validation confidence: `96%`.
- Default 95% target met: `Yes`.
- Final applicable category below 90%: `None`.
- Broader validation decision: `Required and completed`.
- Critical acceptance criteria lacking direct proof: `None within the API/E2E/pre-publication-local gate`.
- Required next recipient: `/code_reviewer` for proportional review of the round-4 durable source-contract update.
- Publication/server scope: no Docker Hub mutation; no AutoByteus server access or modification.

## Investigation And Execution Basis

- Investigation completed before durable coverage change and final execution: `Yes`.
- Prior failure rechecked first: `Yes — exact ./build-multi-arch.sh --no-cache on real Apple Silicon arm64`.
- Plan followed: `Yes`; exact host build, alias regression, loaded image, focused normal runtime, evidence and cleanup all completed.
- Evidence-driven coverage decision: updated `tests/validate-source-contract.sh` with one narrow assertion for the exact combined `arm64|aarch64)` alias. The temporary functional alias matrix was not added as a second durable shell harness because it would be disproportionate to the one-label production change.
- Reroute required: `Yes after Pass`, solely because repository-resident durable coverage changed and requires proportional review before Delivery.

## Compatibility / Legacy / Persistence Scope

- Invalid compatibility or legacy-retention behavior observed: `No`.
- Approved persisted-data decision: `Not Affected`; no migration or runtime fallback.
- Round-3 profile direct-use/recovery evidence remains valid; round-4 exact-command image profile write passes.
- Compatibility-only durable coverage: `None`.

## Changed Boundary And Evidence Matrix

| Scenario | Requirement / AC | Execution Surface | Evidence Type | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| AE2E-SCN-001 | AC-003; `APIE2E-F-002` | Exact real Apple Silicon script/BuildX/load/tags | Live / CLI | Pass | `evidence/host-round4-exact-apple-silicon-build.log` |
| AE2E-SCN-006 | AC-003/004 preserved aliases/tags/variant/push/error | Real script with controlled `uname`/`docker` boundaries | Temporary | Pass | `evidence/host-round4-alias-regression.log` |
| AE2E-SCN-002 | AC-001/003/006/010 | Exact-command loaded `1.4.0` image; durable image harness | Durable / Live | Pass | `evidence/host-round4-image-runtime-regression.log` |
| AE2E-SCN-003/005 | AC-005/006/010 focused regression | Normal entrypoint, Supervisor/VNC/websockify/DevTools/DOM/profile | Durable / Live / Desktop | Pass | `evidence/host-round4-image-runtime-regression.log` |
| AE2E-SCN-002–005 prior full matrix | AC-001–AC-010 | Round-3 clean platforms/variants/custom/input/recovery/indexes | Durable / Live / Desktop | Still Valid / Pass | Round-3 host evidence retained unchanged by IR-003 |

## Acceptance-Criteria Results

| AC | Result | Direct Evidence / Scope Note |
| --- | --- | --- |
| AC-001–AC-002 | Pass | Exact round-4 loaded Noble ARM64 image plus round-3 four-target evidence. |
| AC-003 | **Pass** | Exact supported Apple Silicon `./build-multi-arch.sh --no-cache` now selects `linux/arm64`, clean-builds, tags and loads. |
| AC-004 | Pass | Round-3 clean platform/variant builds and local indexes remain valid; controlled multi-platform push/variant composition passes. |
| AC-005–AC-006 | Pass | Loaded image and normal live runtime pass; custom identity remains proven by unchanged round-3 evidence. |
| AC-007 | Pass | IR-003 does not touch `zh`; round-3 real Pinyin/VNC evidence remains valid. |
| AC-008 | Pass | Round-3 persistence/recovery remains valid; round-4 exact-command runtime profile write passes. |
| AC-009–AC-010 | Pass | Updated source contract, docs and exact loaded Noble Python/tooling pass. |
| AC-011 | Ready for Delivery execution | Local API/E2E gate passes; remote publication/verification not performed here. |
| AC-012 | Deferred as designed | No server adoption before verified publication. |

## Commands And Results

| Order | Exact Command / Configuration | Result | Evidence |
| --- | --- | --- | --- |
| 1 | `./build-multi-arch.sh --no-cache` on real `uname -m=arm64` | Pass; BuildX `--load --no-cache --platform linux/arm64`; loaded `1.4.0` and `latest` | `evidence/host-round4-exact-apple-silicon-build.log` |
| 2 | Corrected Docker image inspection for both loaded tags | Pass; common digest `sha256:13d9dd...0051`, `linux/arm64` | Same log |
| 3 | `bash -n`; `git diff --check`; updated `tests/validate-source-contract.sh`; controlled alias/load/push/variant/tag/error matrix | Pass | `evidence/host-round4-alias-regression.log` |
| 4 | `tests/validate-image.sh autobyteus/chrome-vnc:1.4.0 default 1000 1000` | Pass | `evidence/host-round4-image-runtime-regression.log` |
| 5 | Task normal runtime plus `tests/validate-running-container.sh`, host VNC/websockify/DevTools and image/runtime identity | Pass | Same log |
| 6 | Restore pre-existing `latest`; remove task container/volume/tags | Pass | `evidence/host-round4-cleanup.log` |

The exact product command itself exited `0`. A first post-build evidence-only Go template used `join .RepoTags`, which Docker 29 rejected because its type was `[]interface{}`. The corrected `json .RepoTags` probe immediately passed and is authoritative. No product failure is attributed to the evidence formatter.

## Prior Failure Resolution

| Failure | Prior Result | Round-4 Resolution | Evidence |
| --- | --- | --- | --- |
| `APIE2E-F-002` / AC-003 | Confirmed implementation-owned; real `arm64` rejected before BuildX | Resolved: exact command reaches BuildX, clean builds, selects `linux/arm64`, applies both expected tags, loads one ARM64 image and passes image/runtime gates | Round-4 exact build and image/runtime logs |
| `APIE2E-F-001` | Resolved in IR-002 / prior rounds | Remains resolved in exact-command default image; `vncuser` 1000:1000 passes | Round-4 image/runtime log |

## Durable Coverage Changed

| Path | Change | Requirement / Boundary | Result |
| --- | --- | --- | --- |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-source-contract.sh` | Added exact assertion that `build-multi-arch.sh` contains the combined `arm64|aarch64)` mapping | REQ-003/005; AC-003; recurrence protection for `APIE2E-F-002` | Pass; proportional review required |

- Durable coverage added: none.
- Durable coverage removed: none.
- Prior round-3 changes to `tests/validate-image.sh` and `tests/validate-running-container.sh`: unchanged in round 4 and already `CRR-003 Pass`.
- Round-4 updated path attached/referenced for review: `Yes`.

## Confidence Scorecard

| Category | Post-Repository | Final | Change / Final Evidence | Residual Uncertainty |
| --- | ---: | ---: | --- | --- |
| Requirement and AC proof | 90% | 95% | Exact AC-003 command closes critical failure | Delivery-owned remote publication only |
| Changed-boundary directness | 95% | 100% | Real host exact wrapper/BuildX/load execution | None in local boundary |
| Cross-boundary realism / mock gap | 95% | 95% | Real build/image/services; doubles used only for other alias regression | Registry not invoked by API/E2E |
| Environment/configuration/identity/fixture fidelity | 95% | 95% | Real ARM64 host, loaded tags, preserved prior tag, task runtime/volume | None material |
| Failure/edge/lifecycle/recovery evidence | 90% | 95% | Exact failure recheck, aliases, unsupported host, live runtime and prior lifecycle | None material |
| User surface/browser/desktop confidence | 95% | 95% | Focused semantic render plus unchanged round-3 VNC/Pinyin evidence | None material |
| Durable regression coverage quality | 95% | 95% | Three scripts pass; one-line new assertion awaits review | Proportional review pending |

- Overall post-repository confidence: `94%`.
- Overall final confidence: `96%` (rounded from 95.7%).
- Confidence gain: exact real-host build/load and live loaded-image execution resolves the only critical gap.
- Every critical API/E2E criterion proven: `Yes`.
- Applicable final category below 90%: `None`.
- Default 95% target met: `Yes`.

## Broader Validation And Live Evidence

- Decision/mode: `Required`; real CLI/BuildX/image/live process/browser regression.
- Startup: exact documented script, loaded-image harness, normal `docker run`, bounded Supervisor readiness.
- Fixtures: task-owned profile volume; no account, authentication or secret.
- Browser/desktop: the real Chromium instance rendered the semantic `BRD-UBUNTU24-001` DOM through DevTools; VNC, websockify and host DevTools surfaces passed. IR-003 has no UI delta, so the round-3 authoritative Pinyin screenshot/journey remains sufficient.
- Platform/runtime: macOS ARM64 host; Docker `29.0.1`; BuildX `0.29.1`; loaded Ubuntu 24.04 ARM64 image; Python 3.12.3.

## Dependencies Mocked Or Emulated

No product dependency was mocked for the critical path. The exact command used real Docker/BuildX and repositories. Temporary `uname`/`docker` doubles exercised non-host aliases and command composition only; direct real `arm64` evidence is authoritative. Round-3 emulated AMD64/full local OCI index evidence remains valid.

## Cleanup

| Resource | Action / Result |
| --- | --- |
| Task runtime container and profile volume | Removed |
| Task-loaded `autobyteus/chrome-vnc:1.4.0` and backup tag | Removed |
| Pre-existing `autobyteus/chrome-vnc:latest` | Restored to original digest `sha256:f5a12a...1029` |
| Temporary alias doubles | Removed |
| Shared BuildX builder/cache | Retained; not globally pruned |
| Docker Hub / server repository | No mutation / no access |

## Result Summary And Route

| Result | Scenario IDs | Summary |
| --- | --- | --- |
| Pass | AE2E-SCN-001/002/003/005/006 | Exact failure path, aliases, loaded image, live runtime/browser and regression coverage pass. |
| Still Valid / Pass | Prior AE2E-SCN-002–005 | Full platform/variant/custom/input/recovery/index evidence unaffected by IR-003. |
| Out Of Scope For API/E2E | AC-011 remote / AC-012 server | Delivery publication/verification and later server ticket remain sequenced. |

Required recipient: `/code_reviewer` for proportional review of the one-line `tests/validate-source-contract.sh` update. If that review passes, the cumulative package may proceed to Delivery; no implementation rework is required.
