# API/E2E Revision Record

The latest `api-e2e-coverage-investigation.md` and `api-e2e-execution-coverage-report.md` remain authoritative.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Related Upstream Revision IDs | Prior Result / Confidence | Current Result / Confidence |
| --- | --- | --- | --- | --- |
| API-REV-001 | Implementation Engineer / `implementation-handoff.md` / round 1 | `RER-006`; `IR-001`; architecture/review revisions `N/A` | N/A | `Fail` / `49%` |

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
