# API/E2E Revision Record

The latest `api-e2e-coverage-investigation.md` and `api-e2e-execution-coverage-report.md` remain authoritative.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Related Upstream Revision IDs | Prior Result / Confidence | Current Result / Confidence |
| --- | --- | --- | --- | --- |
| API-REV-001 | Implementation Engineer / `implementation-handoff.md` / round 1 | `RER-006`; `IR-001`; architecture/review revisions `N/A` | N/A | `Fail` / `49%` |
| API-REV-002 | Implementation Engineer / `IR-002` re-entry / round 2 | `RER-006`; `IR-002`; `CRR-001`; `API-REV-001` | `Fail` / `49%` | `Blocked — user-directed stop` / `58%` |

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
