# API/E2E Revision Record

The latest `api-e2e-coverage-investigation.md` and `api-e2e-execution-coverage-report.md` remain authoritative.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Related Upstream Revision IDs | Prior Result / Confidence | Current Result / Confidence |
| --- | --- | --- | --- | --- |
| API-REV-001 | Implementation Engineer / `implementation-handoff.md` / round 1 | `RER-006`; `IR-001`; architecture/review revisions `N/A` | N/A | `Fail` / `49%` |
| API-REV-002 | Implementation Engineer / `IR-002` re-entry / round 2 | `RER-006`; `IR-002`; `CRR-001`; `API-REV-001` | `Fail` / `49%` | `Blocked — user-directed stop` / `58%` |
| API-REV-003 | Solution Designer / host Docker/BuildX continuation / round 3 | `RER-006`; `IR-002`; `CRR-001`; `API-REV-002` | `Blocked — user-directed stop` / `58%` | `Fail` / `89%` |
| API-REV-004 | Code Reviewer / `IR-003` + `CRR-004` re-entry / round 4 | `RER-006`; `IR-003`; `CRR-003`; `CRR-004`; `API-REV-003` | `Fail` / `89%` | `Pass` / `96%` |
| API-REV-005 | Code Reviewer / `IR-005` + `CRR-006` re-entry / round 5 | `RER-007`; `SR-001/002`; `ARCH-REV-002`; `IR-005`; `CRR-006`; `API-REV-004` | `Pass` / `96%` | `Pass` / `97%` |
| API-REV-006 | Code Reviewer / `CRR-007` bounded Local Fix / focused round 6 | `RER-007`; `IR-005`; `CRR-006/007`; `API-REV-005` | `Pass` / `97%` | `Pass` / `97%` |
| API-REV-007 | Code Reviewer / `IR-006/IR-007` + `CRR-010` / focused round 7 | `RER-007`; `IR-006/007`; `CRR-010`; `DR-005`; `API-REV-006` | `Pass` / `97%` | `Pass` / `97%` |

## Revision Entries

### API-REV-001 — Clean default Noble build exposes UID/GID collision

- Triggering role, report path, and round: Implementation Engineer; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; initial API/E2E round.
- Triggering finding or scenario IDs: `APIE2E-F-001`; `AE2E-SCN-001`–`AE2E-SCN-005`; AC-003.
- Related revision IDs: Requirements `RER-006`; implementation `IR-001`; architecture-design, architecture-review, code-review, and delivery revisions `N/A`.
- Why recorded: Establish the first completed executable-validation baseline and preserve the critical clean-build failure before rework.
- Coverage decisions/durable paths changed: Added `tests/validate-source-contract.sh`, `tests/validate-image.sh`, and `tests/validate-running-container.sh`; no tests updated or removed.
- Scenarios added, changed, removed, or rechecked: Added AE2E-SCN-001 through AE2E-SCN-005. Source validation passed. Clean default build failed. Built-image/runtime/browser scenarios were not reached.
- Command/environment/broader-validation delta: Installed Docker/BuildX/QEMU/Podman/Buildah. Nested Docker container execution was unavailable due outer read-only cgroups, so a task-isolated no-cache Podman/Buildah chroot build executed the exact Dockerfile and real repositories on ARM64. Official AMD64 and ARM64 base roots were separately inspected by digest.

#### Prior Failure Resolution

None — this is the initial baseline.

- Canonical artifacts updated: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`; this revision record.
- Prior result and confidence: `N/A`.
- Current result and confidence: `Fail` / `49%`.
- New or remaining failure IDs: `APIE2E-F-001` — official Ubuntu 24.04 platform roots already own UID/GID 1000 as `ubuntu`, so the Dockerfile's default `groupadd -g 1000 vncuser` exits status 4.
- Recommended recipient: Dynamic API/E2E failure recipient (normally `/software_engineering_team/code_reviewer`) for focused failure-origin review.
- Remaining risks/untested scope: AC-001 runtime, AC-004–AC-008, AC-010, and pre-publication readiness for AC-011/AC-012; no image was built, run, or published.

### API-REV-002 — Prior build failure resolved; matrix stopped for external continuation

- Triggering role, report path, and round: Implementation Engineer; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; API/E2E round 2 re-entry at commit `e604ffa`.
- Triggering finding or scenario IDs: `APIE2E-F-001`; AC-003; reused `AE2E-SCN-001` through `AE2E-SCN-005`.
- Related revision IDs: Requirements `RER-006`; implementation `IR-002`; failure-origin review `CRR-001`; prior API/E2E `API-REV-001`; architecture-design and architecture-review revisions `N/A`.
- Why recorded: Preserve the truthful partial rerun after the implementation Local Fix and the user's explicit direction to stop Podman validation and continue testing in another environment.
- Coverage decisions/durable paths changed: Updated `tests/validate-image.sh` so its heredoc runs with interactive stdin and so websockify is checked through installed distribution metadata plus its supported help surface. No coverage added or removed.
- Scenarios rechecked: AE2E-SCN-001 passed. The full exact no-cache ARM64 default build and built-image portion of AE2E-SCN-002/004 passed. Runtime/browser, `zh`, AMD64, full custom-ID, locale/input, persistence/recovery, and local multi-platform index portions were not tested after the user-directed stop.
- Command/environment/broader-validation delta: Podman/Buildah OCI isolation with cgroups disabled executed the exact Dockerfile and real dependencies successfully on native ARM64. A prior chroot attempt passed the identity step but hit a Node/libuv alternate-builder assertion; the OCI retry is authoritative. All task resources were cleaned.

#### Prior Failure Resolution

| Prior Scenario / Failure Reference | Previous Classification | Current Resolution | Evidence |
| --- | --- | --- | --- |
| `APIE2E-F-001` / AC-003 / ARM64 default clean build | Confirmed implementation-owned Local Fix (`CRR-001`) | Resolved for the full exact no-cache ARM64 default image: the build completes and UID/GID 1000 resolve to `vncuser`. | `evidence/build-default-arm64-oci-round2.log`; `evidence/image-default-arm64-round2.log` |

- Canonical artifacts updated: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`; this revision record.
- Prior result and confidence: `Fail` / `49%`.
- Current result and confidence: `Blocked — user-directed stop/external validation pending` / `58%`.
- New or remaining failure IDs: None. The remaining matrix is untested, not classified as a new implementation failure.
- Recommended recipient: User/external validation continuation; Delivery owns the requested remote branch push.
- Remaining risks/untested scope: default live runtime; ARM64 `zh`; AMD64 default/`zh`; full custom identity; service/browser/VNC/websockify/debugging; locale/input; persistence/recovery; and pre-publication AC-011/AC-012. No image publication or server adoption occurred.

### API-REV-003 — Host matrix closes prior gaps; Apple Silicon wrapper fails

- Triggering role, report path, and round: Solution Designer host-continuation request; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`; API/E2E round 3 at implementation commit `e604ffa` and branch checkpoint `951da03`.
- Triggering finding or scenario IDs: prior open `AE2E-SCN-002`–`AE2E-SCN-005`; new `APIE2E-F-002`; AC-003.
- Related revision IDs: requirements `RER-006`; implementation `IR-002`; failure-origin review `CRR-001`; prior API/E2E `API-REV-002`; design/architecture revisions `N/A` under the approved direct low-risk route.
- Why recorded: complete the user-requested host Docker/BuildX continuation, replace the round-2 external-continuation state with executable evidence, and preserve the confirmed supported-entry-surface failure.
- Environment delta: macOS ARM64 host with Docker Desktop client/server `29.0.1`, BuildX `v0.29.1-desktop.1`, and a `docker-container` builder reporting `linux/arm64` and `linux/amd64`. Docker/BuildX replaced Podman as requested.
- Coverage decisions/durable paths changed:
  - Updated `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-image.sh` so the `zh` English-default assertion includes the existing third `Default=True` line (`grep -A3`).
  - Updated `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-running-container.sh` to poll readiness without terminating on the first pre-ready state and to attach stdin (`docker exec -i`) for both heredoc assertion bodies.
  - No durable coverage added or removed.
- Scenarios rechecked: exact clean ARM64/AMD64 default/`zh` builds; built-image contracts; full custom `1234:1234`; default and `zh` live Supervisor/VNC/websockify/DevTools/Chromium; real Pinyin desktop input; profile persistence and stale Chromium/X recovery; local no-push multi-platform indexes for both variants.
- Result delta: every round-2 untested functional and release-readiness-local scenario passed. The exact documented Apple Silicon command `./build-multi-arch.sh --no-cache` failed before BuildX because `uname -m=arm64` is not accepted by the script's `x86_64|aarch64` mapping.

#### Prior Failure Resolution

| Prior Scenario / Failure Reference | Previous Classification | Current Resolution | Evidence |
| --- | --- | --- | --- |
| `APIE2E-F-001` / Noble default UID/GID collision | Resolved on round-2 ARM64 default | Remains resolved across clean ARM64/AMD64 default/`zh` images and the full custom-ID path. | Round-3 build and image logs under `requirements/ubuntu-24-minimal-base/evidence/` |
| Round-2 external-continuation gaps / AE2E-SCN-002–005 | Not Tested | Closed: platform/variant matrix, live runtime, custom identity, locale/input, browser/VNC, persistence/recovery, and local OCI indexes passed. | Canonical round-3 execution report and host-round3 evidence |

- Canonical artifacts updated:
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Prior result and confidence: `Blocked — user-directed stop/external validation pending` / `58%`.
- Current result and confidence: `Fail` / `89%`.
- New or remaining failure: `APIE2E-F-002 / AC-003` — the supported Apple Silicon local-build wrapper rejects `arm64` and exits `1` before BuildX execution. Direct clean ARM64 BuildX succeeds, isolating the wrapper mapping.
- Recommended recipient: `/code_reviewer` for focused failure-origin review plus proportional review of the two updated durable test files; then implementation correction and API/E2E re-entry.
- Remaining risks/untested scope: no remaining round-2 local executable gap. Docker Hub publication/remote manifest identity and server adoption remain intentionally untested and out of API/E2E scope; publication is not ready while AC-003 fails.

### API-REV-004 — Exact Apple Silicon build and focused regression pass

- Triggering role, report path, and round: Code Reviewer; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md` (`CRR-004`); API/E2E round 4 at implementation commit `6bbe7a9edab3d19a320ef53e2a99df0fb59b8eef`.
- Triggering finding/scenario: `APIE2E-F-002`; AC-003; AE2E-SCN-001; new temporary AE2E-SCN-006 alias regression.
- Related revisions: requirements `RER-006`; implementation `IR-003`; source review `CRR-004`; prior durable-test review `CRR-003`; prior API/E2E `API-REV-003`; design/architecture revisions `N/A` under the approved direct route.
- Why recorded: replace the round-3 failure with authoritative real-host evidence for the reviewed alias correction and preserve the proportionate regression/durable-coverage delta.
- Environment/command delta: on the real macOS ARM64 host, the exact command `./build-multi-arch.sh --no-cache` selected `linux/arm64`, executed a no-cache BuildX build, applied `autobyteus/chrome-vnc:1.4.0` and `:latest`, loaded one ARM64 image, and returned `0`. The loaded image and normal runtime/browser/service/profile regression gates passed.
- Coverage decision/durable path changed: updated `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-source-contract.sh` with one exact assertion for `arm64|aarch64)`. This protects the critical alias without adding a disproportionate Docker/uname-double harness. No durable coverage was added or removed; the prior two test corrections remain unchanged and `CRR-003 Pass`.
- Other regression evidence: independent controlled real-script matrix passed `arm64`, `aarch64`, `x86_64`, local load, no-cache, `zh`, multi-platform push, tag selection, and unsupported-host failure.

#### Prior Failure Resolution

| Prior Scenario / Failure | Previous Classification | Current Resolution | Evidence |
| --- | --- | --- | --- |
| `APIE2E-F-002` / AC-003 — Apple Silicon `arm64` rejected | Confirmed implementation-owned Local Fix; API/E2E Fail (`CRR-002`, `API-REV-003`) | Resolved. The exact supported command reaches BuildX, clean builds, selects/loads ARM64 with both expected tags, and the loaded image passes durable image/runtime gates. | `evidence/host-round4-exact-apple-silicon-build.log`; `evidence/host-round4-image-runtime-regression.log` |
| `APIE2E-F-001` — Noble UID/GID collision | Resolved previously | Remains resolved on the round-4 exact-command image (`vncuser` 1000:1000). | Round-4 image/runtime log |

- Canonical artifacts updated:
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Prior result and confidence: `Fail` / `89%`.
- Current result and confidence: `Pass` / `96%`.
- New or remaining failure IDs: `None`.
- Recommended recipient: `/code_reviewer` for proportional review of the round-4 `tests/validate-source-contract.sh` update; then Delivery if it passes.
- Remaining risk/deferred scope: no local API/E2E blocker. Docker Hub publication/remote manifest verification is Delivery-owned, and server adoption remains the separate post-publication ticket.

### API-REV-005 — Integrated Python 3.13/Supervisor matrix passes

- Triggering role, report path, and round: Code Reviewer; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md` (`CRR-006`); API/E2E round 5 at implementation/worktree HEAD `f902e80771b304916858314fa9484cab8f6f1843`.
- Triggering behavior/scenarios: RER-007 public Python 3.13 on Noble, separate OS Python ownership, one Python 3.13 `/opt/browser-tools` provider, Supervisor 4.3.0 normal-entrypoint execution, and full preserved build/runtime/browser/profile matrix; AE2E-SCN-001/002/003/006/007/008/009; AC-001–010/013.
- Related revisions: requirements `RER-007`; solution `SR-001`, `SR-002`; architecture `ARCH-REV-002`; implementation `IR-005`; source review `CRR-006`; prior API/E2E `API-REV-004`; prior test review `CRR-005` is pre-IR-005 context only.
- Why recorded: replace the pre-IR-005 API-REV-004 proof with direct executable evidence for the superseding Python 3.13/Supervisor provider and the complete integrated pre-publication-local regression gate.
- Environment/command delta: macOS Apple Silicon host; Docker Engine 29.0.1; BuildX v0.29.1-desktop.1; BuildKit v0.26.2; real ARM64 plus supported AMD64 emulation; clean default/`zh` builds; normal-entrypoint runtimes; local no-push multi-platform OCI outputs.
- Coverage decisions/durable paths changed:
  - Updated `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-source-contract.sh` for exact Deadsnakes Noble/Python 3.13/sole Supervisor/stable commands and assets/entrypoint/`gh`/legacy-rejection contracts.
  - Updated `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-image.sh` for public-versus-OS Python ownership, actual Deadsnakes Noble package/source layout, isolated tool owner/version/assets, `gh`, identity/variant/locale and no apt provider.
  - Updated `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-running-container.sh` for Supervisor 4.3.0 control/PID1/provider/log evidence and native/Rosetta-valid full-command-vector interpreter ownership while preserving process/protocol/DOM/profile checks.
  - Durable files added: none. Durable files removed: none.
- Scenarios rechecked: exact Apple ARM64 wrapper; aliases/tags/load/push composition; clean ARM64/AMD64 default/`zh`; custom 1234:1234; image/provider/tool/locale identity; normal and mobile-safe live runtime; VNC/websockify/DevTools/semantic Chromium; real Pinyin commit; profile persistence and stale-lock recovery; default/`zh` local AMD64+ARM64 OCI indexes.
- Result delta: the integrated IR-005 local/pre-publication gate passes at 97% confidence. AC-011 remote publication/verification and AC-012 server adoption remain sequenced outside this API/E2E round.

#### Prior Failure Resolution

| Prior Scenario / Failure | Previous Classification | Current Resolution | Evidence |
| --- | --- | --- | --- |
| `APIE2E-F-002` / AC-003 — Apple Silicon `arm64` wrapper | Resolved in IR-003/API-REV-004 | Remains resolved: exact real-host `./build-multi-arch.sh --no-cache` reaches BuildX, selects ARM64, clean-builds, tags/loads and passes current image/runtime gates. | `evidence/host-round5-build-arm64-default-retry1.log`; current image/runtime logs |
| `APIE2E-F-001` — Noble default UID/GID collision | Resolved in IR-002/prior rounds | Remains resolved across both architectures, both variants and custom 1234:1234 build/runtime. | Current build/image/custom runtime logs |
| Pre-IR-005 public Python 3.12/provider evidence | Superseded behavior, not a failure ID | Replaced by exact public Python 3.13, Noble OS Python separation, Deadsnakes origin and isolated Supervisor 4.3.0 evidence on both targets. | `evidence/host-round5-python-origin-and-tools.log`; image/runtime logs |

- Execution observations and corrections:
  - The first ARM64 default build hit an unrelated Ubuntu ports mirror/index `ncurses` 404 window; the exact no-cache command passed on controlled retry. No implementation failure was opened.
  - API/E2E corrected a nonexistent `python3.13-minimal` package assertion, native/Rosetta procfs assumptions, a temporary origin-probe quoting defect, and the omitted explicit `gh` assertion. All final durable/temporary reruns passed.
- Canonical artifacts updated:
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Prior result and confidence: `Pass` / `96%` (API-REV-004, pre-IR-005).
- Current result and confidence: `Pass` / `97%`.
- Broader-validation decision: `Required and completed`.
- New or remaining failure IDs: `None`.
- Recommended recipient: `/code_reviewer` for proportional review of the three updated durable test files; Delivery may resume only after that review passes.
- Remaining risk/deferred scope: mutable external build inputs and the observed transient Ubuntu mirror synchronization window; Docker Hub remote publication/manifest/runtime verification and separate server adoption were intentionally not performed.
- Cleanup: all task containers, volumes, image aliases and OCI archives removed; pre-existing `latest`/`zh` IDs restored; shared builder/cache retained; no Docker Hub or server-repository mutation.

### API-REV-006 — Exact source declarations reject prefix/suffix confounders

- Triggering role, report path, and round: Code Reviewer; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-test-review-report.md` (`CRR-007`); focused API/E2E round 6 at worktree HEAD `f902e80771b304916858314fa9484cab8f6f1843`.
- Triggering finding/scenario: `APIE2E-TEST-F-001`; AE2E-SCN-001; exact Python package/public-selector source contract for AC-006/AC-010.
- Related revisions: requirements `RER-007`; implementation `IR-005`; source review `CRR-006`; proportional test review `CRR-007`; prior API/E2E `API-REV-005`.
- Why recorded: close the bounded API/E2E-owned source-harness correctness defect without discarding or redundantly rerunning API-REV-005's successful broader product evidence.
- Coverage decision/durable path changed: updated only `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-source-contract.sh` after CRR-007. Added `assert_literal_line`; changed `python3.13`, `python3.13-dev`, `python3.13-venv`, `/usr/local/bin/python3`, and `/usr/local/bin/python` source declarations to full literal-line assertions. No file was added or removed. `tests/validate-image.sh` and `tests/validate-running-container.sh` were unchanged and retain their CRR-007 Pass.
- Focused execution: current source positive case; Bash syntax; ShellCheck excluding only intentional SC2016; five isolated negative fixtures covering generic-package suffixes, `libpython3.13-dev`, and `python`/`python3` selector-prefix confounders; diff hygiene.
- Result: every focused check passed. All tightened declarations exist in current source, so no implementation mismatch or Docker-rerun trigger was exposed.
- Broader-validation decision: `Not Required` for API-REV-006. API-REV-005's real Docker/BuildX/image/runtime/browser/desktop/profile/multi-platform evidence remains authoritative and completed.

#### Prior Finding Resolution

| Finding ID | Prior Status | Current Resolution | Evidence |
| --- | --- | --- | --- |
| `APIE2E-TEST-F-001` | CRR-007 Fail — API/E2E Local Fix; regex assertions accepted longer/different declarations | `Resolved in returned durable state; proportional re-review pending`. Literal-line assertions protect the exact package and selector declarations; all five confounding fixtures are rejected while current source passes. | `evidence/host-round6-source-contract-fix.log`, final authoritative focused section |

- Canonical artifacts updated:
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Prior result and confidence: `Pass` / `97%` (`API-REV-005`; CRR-007 separately failed the source-test discrimination review).
- Current result and confidence: `Pass` / `97%`.
- New or remaining implementation failure IDs: `None`.
- Recommended recipient: `/code_reviewer` for focused proportional re-review of `tests/validate-source-contract.sh` and the negative-discrimination evidence.
- Delivery/publication: still blocked pending review Pass; no Docker Hub or server-repository mutation.

### API-REV-007 — BuildX owns push authority; wrapper matrix passes without publication

- Triggering role, report path, and round: Code Reviewer; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md` (`CRR-010`); focused API/E2E round 7 at `14fb215b1ad0b48dd486658ca7fd7757ceb06d16`.
- Triggering behavior/scenario: DR-005 publication wrapper blocker; IR-006/IR-007; AE2E-SCN-010; SCN-002/SCN-005; REQ-003/005/008; AC-004 and AC-011 pre-publication wrapper boundary.
- Related revisions: requirements `RER-007`; solution `SR-001/SR-002`; architecture `ARCH-REV-002`; implementation `IR-006`, `IR-007`; code review `CRR-009`, `CRR-010`; prior API/E2E `API-REV-006`; delivery `DR-005`.
- Why recorded: replace the pre-IR-006 API/E2E wrapper conclusion with current non-publishing evidence for the removed Docker-info Username gate, exact BuildX command/status authority, and deterministic fixture lifecycle.
- Coverage investigation decision: `tests/validate-build-wrapper.sh` and `tests/validate-source-contract.sh` were `Still Valid / Execute`; image/runtime coverage and API-REV-005 product evidence were `Still Valid / Do Not Rerun` because production image/runtime sources did not change.
- Durable coverage changed by API/E2E: `None`. The implementation-added `tests/validate-build-wrapper.sh` passed unchanged after CRR-010; no file was added, updated, or removed by this round.
- Executed matrix: Bash/ShellCheck/source/durable harness/diff hygiene; obsolete-parser negative scan; arm64/aarch64/x86_64 load paths; default/zh; no-cache; immutable/rolling tags; default/zh multi-platform push composition; builder use/create; BuildX unavailable; unsupported architecture; mutually exclusive/unknown/empty inputs; local/push BuildX failure propagation; no false success; normal/assertion/command fixture cleanup.
- Result: all authoritative cases passed. No current push case called `docker info`; no real Docker or registry command was reachable; BuildX failure statuses 37/38 propagated; cleanup statuses 0/1/44 each left fixture count 0→0.
- Broader-validation decision: `Required and completed` through the real current wrapper with deterministic fake Docker/uname boundaries. A real registry push is prohibited in API/E2E and remains Delivery-owned.
- Full image/runtime rerun decision: `Not Required`; the wrapper-only delta exposed no command mismatch and all image/runtime sources are unchanged from API-REV-005.

#### Prior Finding / Blocker Resolution

| Finding / Blocker | Prior State | Current Resolution | Evidence |
| --- | --- | --- | --- |
| DR-005 publication wrapper blocker | Missing `docker info` Username falsely stopped a valid Docker Desktop credential-helper session before BuildX | `Resolved locally`; a no-Username presentation cannot block either fake push, and exact BuildX commands are reached. Real registry acceptance remains Delivery-owned. | `evidence/host-round7-build-wrapper-matrix.log` |
| `CR-F-001` | New deterministic wrapper harness leaked fixture directories | `Remains resolved`; normal 0, controlled assertion 1, and controlled command 44 each leave 0→0 fixtures. | Corrected authoritative lifecycle section of round-7 log |
| `APIE2E-TEST-F-001` | Python source assertions accepted confounders | `Remains resolved — unaffected`; current source contract passes. | API-REV-006/CRR-008; round-7 log |
| `APIE2E-F-001` / `APIE2E-F-002` | Historical identity/Apple alias failures | `Remain resolved`; current alias matrix passes and image source is unchanged. | API-REV-005 plus round-7 log |

- Temporary probe observation: the first round-7 controlled-assertion probe referenced an undefined variable before the intended assertion. Its traceback is superseded in the same log by the corrected authoritative lifecycle section using defined values. Corrected status/cleanup evidence passes; no durable or product finding was opened.
- Canonical artifacts updated:
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-execution-coverage-report.md`
  - `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Prior result and confidence: `Pass` / `97%` (`API-REV-006`, pre-IR-006).
- Current result and confidence: `Pass` / `97%`.
- New or remaining failure IDs: `None`.
- Recommended recipient: `/code_reviewer` to record the proportional test-code review as `Not Applicable` because API/E2E made no durable coverage change; Delivery follows that recorded result.
- Remaining scope: Delivery integrates/pushes IR-006/IR-007 as appropriate, performs the authorized default then zh Docker Hub publication, verifies all manifests/platform/variant runtime identities, completes release records and cleanup. Server adoption remains separate until AC-011 passes.
- Mutation/cleanup: zero task fixtures; no real Docker image/container/volume action; no Docker Hub request/mutation; no server-repository access.
