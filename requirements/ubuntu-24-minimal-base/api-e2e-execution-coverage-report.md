# API/E2E Execution Coverage Report

## Execution Round Meta

- Requirements Doc: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-doc.md`
- Investigation Notes / Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/investigation-notes.md`; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-revision-record.md`
- Design / Architecture Review Artifacts: `N/A — not applicable; approved direct route`
- Supplemental Artifact: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Implementation Handoff / Revision: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-revision-record.md` (`IR-002`)
- Failure-Origin Review / Revision: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/code-review-report.md`; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/code-review-revision-record.md` (`CRR-001`)
- Coverage Investigation: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
- API/E2E Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Current API/E2E Revision ID / Round: `API-REV-002` / `2`
- Trigger: Implementation Engineer re-entry at commit `e604ffa` after the `APIE2E-F-001` Local Fix.
- Prior Round Reviewed: `Yes — API-REV-001, Fail / 49%.`
- Latest Authoritative Round: This file.

## Routing Classification

- Task size: `Medium`
- Architectural risk: `Low`
- Input route: `Direct Low-Risk`
- Successful-output route: `Delivery`
- Proportional test-code review: `Not Required — direct low-risk route`; this round is not a Pass.

## Investigation And Execution Basis

- Investigation completed before execution: `Yes`; the round-2 prior-failure-first plan was added before commands ran.
- Plan followed: `Partially`. Repository checks, the mandatory prior-failure recheck, a full ARM64 default build, and built-image validation ran. The user then explicitly directed API/E2E not to continue Podman validation and requested remote-branch availability for testing elsewhere.
- Coverage decisions revised: `tests/validate-image.sh` required two test-owned corrections: `-i` so its heredoc executes, and a package-supported websockify metadata/help probe because websockify 0.13.0 exposes no `--version` option.
- New implementation failure: `None observed`.
- Result basis: required critical matrix coverage is incomplete; therefore this cannot be a Pass. The formal result is `Blocked — user-directed stop/external validation pending`, not a product failure and not a claim that all execution was impossible in the current environment.

## Compatibility / Legacy / Persistence Scope

- Invalid backward-compatibility or legacy-retention behavior observed: `No`.
- Approved persisted-data decision: `Not Affected`.
- Persisted-data transition verified: `No — representative reuse/recovery lifecycle was not reached before the user-directed stop`.
- Compatibility-only durable coverage added: `No`.

## Changed Boundary And Evidence Matrix

| Scenario ID | Requirement / AC | Execution Surface | Evidence Type | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| AE2E-SCN-001 | Source portions AC-001–AC-004, AC-009–AC-012 | Repository Bash/static/config assertions | Durable | Pass | `evidence/repository-checks-round2.log` |
| AE2E-SCN-004 | Prior `APIE2E-F-001`; AC-003; ARM64 default | Exact no-cache Dockerfile build with real dependencies under Podman/Buildah OCI isolation | Live / Temporary | Pass | `evidence/build-default-arm64-oci-round2.log` |
| AE2E-SCN-002 | AC-001, AC-003, default portion AC-006, AC-010 | Completed ARM64 default image | Durable / Live | Pass | `tests/validate-image.sh`; `evidence/image-default-arm64-round2.log` |
| AE2E-SCN-003 | AC-005–AC-008, AC-010 runtime | Supervisor/process/VNC/WebSocket/DevTools/profile | Durable / Live | Not Tested | User-directed stop before runtime execution. |
| AE2E-SCN-004 remaining | AC-004, AC-007, pre-publication AC-011/AC-012 | ARM64 `zh`, AMD64 default/`zh`, local no-push multi-platform indexes | Live / Temporary | Not Tested | User-directed stop. |
| AE2E-SCN-005 | AC-005, AC-007 | Semantic Chromium rendering and supporting desktop/VNC evidence | Browser / Desktop | Not Tested | User-directed stop. |
| Custom identity/recovery portions of AE2E-SCN-002/003 | AC-006, AC-008 | Full 1234:1234 build/runtime and persisted-volume/stale-lock lifecycle | Live / Lifecycle | Not Tested | User-directed stop. |

## Acceptance-Criteria Result Matrix

| AC | Result | Direct Evidence / Remaining Gap |
| --- | --- | --- |
| AC-001 | Partial Pass | ARM64 default completed image directly reports Ubuntu 24.04 Noble; remaining targets untested. |
| AC-002 | Pass | Exact official `ubuntu:24.04` base; no alternate base. |
| AC-003 | Partial Pass | Full no-cache ARM64 default build passed and UID/GID 1000 resolve to `vncuser`; complete target matrix not run. |
| AC-004 | Not Tested / incomplete | AMD64 and `zh` full builds not run. |
| AC-005 | Partial Pass | Built-image Python/tool contents passed; live service/browser surface not run. |
| AC-006 | Partial Pass | Default identity passed; full custom-ID build/runtime not run. |
| AC-007 | Not Tested | `zh` image/input path not run. |
| AC-008 | Not Tested | Persistence/recovery lifecycle not run. |
| AC-009 | Pass | Source and README identity scan passed. |
| AC-010 | Partial Pass | Noble Python 3.12 package ownership, isolated tools, `uv`, websockify passed on ARM64 default; runtime/other targets untested. |
| AC-011 pre-publication | Not Ready | Source tag/version/platform contract passed; complete executable gate did not. No push by API/E2E. |
| AC-012 pre-publication | Not Ready | No remote image/manifests/digests verified; server adoption remains deferred. |

## Commands And Execution Results

| Order | Command / Configuration | Result | Evidence |
| --- | --- | --- | --- |
| 1 | Bash syntax; `git diff --check`; `tests/validate-source-contract.sh`; exact IR-002 grep assertions; obsolete scan; task-isolated Supervisor parser with `XDG_RUNTIME_DIR=/run/user/1234` | Pass | `evidence/repository-checks-round2.log`. An earlier parser attempt read the outer host include; the successful task-isolated retry is authoritative. |
| 2 | `podman ... build --arch arm64 --no-cache --layers=false --isolation=chroot ... IMAGE_VARIANT=default` | Alternate-builder failure after identity passed | `evidence/build-default-arm64-round2.log`; Node/libuv fd assertion during npm, not treated as product failure because OCI retry passed. |
| 3 | `podman ... build --arch arm64 --no-cache --layers=false --isolation=oci --runtime crun --runtime-flag cgroup-manager=disabled ... IMAGE_VARIANT=default` | Pass | `evidence/build-default-arm64-oci-round2.log` |
| 4 | Completed-image UID/GID probe and corrected `tests/validate-image.sh localhost/brd-ubuntu24:arm64-default default 1000 1000` | Pass | `evidence/image-default-arm64-round2.log` |

## Validation Confidence Scorecard

| Category | Post-Repository | Final | Change / Basis | Residual Uncertainty |
| --- | ---: | ---: | --- | --- |
| Requirement and AC proof | 40% | 55% | Full ARM64 default build/image closed prior failure and some image contracts | Critical runtime, variant, architecture, custom-ID, input, and recovery proof missing |
| Changed-boundary directness | 75% | 85% | Exact Dockerfile and real completed ARM64 image | No complete matrix or live runtime |
| Cross-boundary realism / mock gap | 40% | 50% | Real base/package/tool integration; no mocks | Services/browser/network/profile not run |
| Environment/configuration/identity/fixture fidelity | 75% | 80% | Native ARM64, official base, no cache, real repositories/default identity | No Docker BuildX, AMD64, custom runtime, or profile fixture |
| Failure/edge/lifecycle/recovery evidence | 45% | 50% | Prior UID collision directly resolved | Restart/recovery/custom/variant edges missing |
| User surface/browser/desktop confidence | 0% | 0% | No round-2 browser or VNC journey | Entire live user surface remains open |
| Durable regression coverage quality | 75% | 85% | Source and corrected image harness passed | Runtime harness unexecuted |

- Overall post-repository confidence: `50%` (rounded simple average).
- Overall final confidence: `58%` (rounded from 57.9%).
- Default 95% target met: `No`.
- Critical acceptance criteria directly proven: `No`.
- Applicable categories below 90%: `All`.

## Broader Validation Decision And Execution

- Decision: `Required`.
- Completed broader evidence: full exact no-cache ARM64 default image build and image-level identity/package/tool assertions.
- Planned but not completed: ARM64 `zh`; AMD64 default/`zh`; custom identity; live Supervisor/browser/VNC/websockify/debugging; locale/input; persistence/recovery; no-push multi-platform index inspection.
- Stop reason: the user explicitly asked API/E2E not to resume Podman validation and requested testing in another environment.
- Environment note: nested Docker remained unavailable because the outer cgroup filesystem is read-only, but Podman OCI successfully built and ran the image-level checks. The result is not attributed to an unavoidable environment blocker.
- Fixtures/accounts/secrets: no external account or secret used; runtime/profile fixture work did not start.

## Desktop / Browser And Lifecycle Status

No live Chromium/XFCE/VNC/websockify/DevTools journey ran in round 2. No assertion is made about the running Supervisor graph, GUI input behavior, persistence, restart, or stale-lock recovery. No existing desktop/profile was modified.

## Tests Implemented Or Updated

| Path / Scenario | Change | Result | Notes |
| --- | --- | --- | --- |
| `tests/validate-image.sh` / AE2E-SCN-002 | Updated | Pass on ARM64 default | Added interactive stdin for heredoc execution; used websockify distribution metadata plus supported `--help`. |
| `tests/validate-source-contract.sh` / AE2E-SCN-001 | Reused unchanged | Pass | Existing durable source contract remains valid. |
| `tests/validate-running-container.sh` / AE2E-SCN-003 | Reused unchanged | Not Tested | Required live runtime was stopped at user direction. |

- Durable paths added this round: none.
- Durable paths updated this round: `/home/autobyteus/workspace/browser-docker/tests/validate-image.sh`.
- Durable paths removed: none.
- Proportional test review: `Not Required — direct low-risk route`; result did not pass.

## Evidence Artifacts

| Path | Purpose |
| --- | --- |
| `requirements/ubuntu-24-minimal-base/evidence/repository-checks-round2.log` | Repository/static/config checks and corrected isolated parser evidence |
| `requirements/ubuntu-24-minimal-base/evidence/build-default-arm64-round2.log` | Chroot-builder deviation after the IR-002 identity step passed |
| `requirements/ubuntu-24-minimal-base/evidence/build-default-arm64-oci-round2.log` | Authoritative full ARM64 default no-cache build success |
| `requirements/ubuntu-24-minimal-base/evidence/image-default-arm64-round2.log` | Prior-failure identity probe, harness corrections, and final image-contract pass |

## Dependencies Mocked Or Emulated

No product dependency was mocked. Podman/Buildah OCI executed the exact Dockerfile because nested Docker/BuildX container execution could not use the outer read-only cgroups. QEMU/binfmt was prepared but AMD64 work was stopped before execution; no AMD64 claim is made.

## Cleanup

| Resource | Action | Result |
| --- | --- | --- |
| Podman/Buildah containers, stores, wrapper, and config | Removed | Pass; no task process/store remains |
| Task-created `/dev/net/tun` | Removed | Pass |
| Task-enabled binfmt registration and mount | Disabled/unmounted | Pass |
| Docker Hub | No mutation | Pass |
| AutoByteus server repository | No write | Pass |

## Prior Failure Resolution

| Prior Failure | Resolution | Evidence |
| --- | --- | --- |
| `APIE2E-F-001` / AC-003 — Noble base UID/GID 1000 collision | Resolved for the full exact no-cache ARM64 default image at `e604ffa`; UID/GID 1000 map to `vncuser` | `evidence/build-default-arm64-oci-round2.log`; `evidence/image-default-arm64-round2.log` |

## Result Summary

| Result | Scenario IDs | Summary |
| --- | --- | --- |
| Pass | AE2E-SCN-001; ARM64-default portions of AE2E-SCN-002/004 | Repository contract, exact default build, prior identity failure recheck, and built-image contract passed. |
| Blocked / Not Tested | Remaining AE2E-SCN-002–005 | User directed the stage to stop and continue testing externally before the required matrix was complete. |

## Recommended Recipient

`User/external validation continuation`. The user-requested remote push is Delivery-owned. No successful validation or release-readiness handoff is claimed.

## Latest Authoritative Result

- Result: `Blocked — user-directed stop/external validation pending`.
- Final validation confidence: `58%`.
- Default 95% confidence target met: `No`.
- Any applicable category below 90%: `Yes — all seven`.
- Broader validation decision: `Required but stopped at explicit user direction after partial ARM64 default success`.
- Critical ACs lacking direct proof: complete AC-003/AC-004 matrix, runtime portions of AC-005/AC-006/AC-010, AC-007, AC-008, and pre-publication readiness for AC-011/AC-012.
- Required next recipient: `User request / external testing; Delivery owns the requested remote push`.
- Notes: No new implementation failure was found. `APIE2E-F-001` is resolved for the full ARM64 default image. No publication or server-adoption claim is made.
