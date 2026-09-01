# Implementation Revision Record

The current source and `implementation-handoff.md` remain authoritative.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Finding IDs | Classification | Related Revision IDs | Result |
| --- | --- | --- | --- | --- | --- |
| IR-001 | Requirements Engineer / approved BRD-UBUNTU24-001 package / initial implementation | N/A | `Initial Baseline` | `AD-REV: N/A`; `ARCH-REV: N/A`; `CRR: N/A`; `API-REV: N/A`; `DR: N/A` | Ubuntu 24.04/Python 3.12 source implementation completed and ready for direct API/E2E validation. |
| IR-002 | Code Reviewer / `code-review-report.md` / API/E2E failure-origin round 1 | `APIE2E-F-001` | `Local Fix` | `AD-REV: N/A`; `ARCH-REV: N/A`; `CRR-001`; `API-REV-001`; `DR: N/A` | Noble's base `ubuntu` identity is cleanly superseded before creating the required default or custom `vncuser` identity; focused checks pass. |
| IR-003 | Code Reviewer / `code-review-report.md` / API/E2E failure-origin round 2 | `APIE2E-F-002` | `Local Fix` | `SR: RER-006`; `ARCH-REV: N/A`; `CRR-002`, `CRR-003`; `API-REV-003`; `DR: N/A` | The local-load host switch recognizes Apple Silicon `arm64` as `linux/arm64` while preserving Linux ARM64, AMD64, tags, variants, load, and push behavior; focused implementation checks pass. |
| IR-004 | Delivery Engineer / `delivery-revision-record.md` / latest-base refresh round | `DR-003` | `Local Fix` | `SR: RER-006`; `ARCH-REV: N/A`; `CRR-004`, `CRR-005`; `API-REV-004`; `DR-003` | Latest `origin/main` is intentionally integrated: approved Noble/Python 3.12/1.4.0 behavior is retained, and applicable current-base `gh` plus Chromium-wrapper changes are incorporated; focused checks pass. |

## Revision Entries

### IR-001 — Implement Ubuntu 24.04 and Noble-native Python 3.12 baseline

- Triggering role, report path, and round: Requirements Engineer; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-doc.md`; initial implementation round.
- Triggering finding IDs: N/A.
- Classification: `Initial Baseline`.
- Prior authoritative result: N/A.
- Current authoritative result: Implementation complete; direct API/E2E validation required.
- Related architecture design revision IDs: N/A — direct route.
- Related architecture-review revision IDs: N/A — direct route.
- Related code-review revision IDs: N/A — direct Medium/Low route.
- Related API/E2E revision IDs: N/A.
- Related delivery revision IDs: N/A.
- Why this baseline or implementation revision is recorded: Establish the first completed source implementation for the approved browser-image `1.4.0`/`1.4.0-zh` Ubuntu 24.04 migration.
- Approved behavior or requirement IDs affected: BEH-001–BEH-003; REQ-001–REQ-009; SCN-001–SCN-005.
- Implementation delta: Replaced the official Ubuntu base tag with `ubuntu:24.04`; replaced Deadsnakes/Python 3.11 with Noble's Python 3.12 package family; installed `websockify` and `uv` in an isolated virtual environment; gave websockify a stable data path; propagated the configured runtime UID path through Supervisor; updated image documentation and version identity.
- Changed files or areas: `Dockerfile`, `base.conf`, `entrypoint.sh`, `README.md`, `VERSION`.
- Local validation and result: Bash syntax, whitespace/error checks, targeted obsolete-reference scans, Supervisor config parsing and custom-XDG interpolation, line-count guardrails, and implementation diff self-review passed. Docker/BuildX is unavailable in this environment, so image build/runtime/platform checks were not executed here.
- Next recipient or routing: Dynamic handoff rule for direct API/E2E validation.
- Remaining limitations or risks: Clean default/`zh` builds, AMD64/ARM64 execution, runtime/profile smoke tests, and all publication/manifests/published-identity checks remain downstream. XtraDeb, NodeSource, PyPI, Ubuntu repositories, and Docker Hub are mutable external dependencies.

### IR-002 — Resolve official Noble default UID/GID collision

- Triggering role, report path, and round: Code Reviewer; `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/code-review-report.md`; API/E2E failure-origin review round 1.
- Triggering finding IDs: `APIE2E-F-001`.
- Classification: `Local Fix`.
- Prior authoritative result: `Fail` — the official Noble base already owns UID/GID 1000 as `ubuntu`, so `groupadd -g 1000 vncuser` stopped the clean build.
- Current authoritative result: Implementation-owned correction complete; focused default/custom identity builds pass; full API/E2E re-execution remains required.
- Related architecture design revision IDs: N/A — direct route.
- Related architecture-review revision IDs: N/A — direct route.
- Related code-review revision IDs: `CRR-001`.
- Related API/E2E revision IDs: `API-REV-001`.
- Related delivery revision IDs: N/A.
- Why this baseline or implementation revision is recorded: Close the confirmed Noble base identity collision without changing the public `vncuser` name or default/configurable UID/GID contract.
- Approved behavior or requirement IDs affected: BEH-001; BEH-002 identity prerequisite; REQ-003–REQ-005; AC-003; AC-006; SCN-001.
- Implementation delta: The Dockerfile now conditionally removes Noble's superseded `ubuntu` account/group before creating `vncuser` with `USER_UID`/`USER_GID`. No fallback identity, alternate public name, or build/runtime contract was added.
- Changed files or areas: `Dockerfile:94-107`; current implementation handoff/revision evidence.
- Local validation and result: Existing durable source-contract test, Bash syntax, diff hygiene, and obsolete-reference scan passed. Task-isolated chroot builds from the real official ARM64 `ubuntu:24.04` base exercised the production identity mechanism with default `1000:1000` and representative custom `1234:1234`; each asserted that both numeric lookups resolve to `vncuser` and passed. Durable log: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/evidence/implementation-ir-002-identity-check.log`.
- Next recipient or routing: Dynamic handoff rules after the confirmed `Medium`/`Low` classification recheck.
- Remaining limitations or risks: The focused builds validate only the corrected identity boundary. API/E2E must recheck `APIE2E-F-001`/AC-003 first and then execute the remaining variant/platform/runtime/browser/custom-ID/persistence matrix. Publication and server adoption remain blocked.

### IR-003 — Recognize the Apple Silicon ARM64 host spelling

- Triggering role, report path, and round: Code Reviewer; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md`; API/E2E failure-origin review round 2.
- Triggering finding IDs: `APIE2E-F-002`.
- Classification: `Local Fix`.
- Prior authoritative result: `Fail` — on the documented Apple Silicon surface, `./build-multi-arch.sh --no-cache` selected local `--load`, received `uname -m=arm64`, and exited before `docker buildx build` because only `aarch64` was mapped to `linux/arm64`.
- Current authoritative result: Implementation-owned correction complete; focused command-composition checks pass. The overall API/E2E result remains `Fail` until the exact AC-003 command is rerun successfully after source review.
- Related solution revision IDs: `RER-006`.
- Related architecture-review revision IDs: `N/A — approved direct route`.
- Related code-review revision IDs: `CRR-002` for the confirmed implementation defect; `CRR-003` for the separate passing review of API/E2E-owned durable test corrections.
- Related API/E2E revision IDs: `API-REV-003`.
- Related delivery revision IDs: `N/A`.
- Why this baseline or implementation revision is recorded: Close the confirmed supported-entry-surface alias omission without changing the established wrapper owner or any approved build, platform, variant, tag, load, or push contract.
- Approved behavior or requirement IDs affected: `BEH-001`; `SCN-001`; `REQ-003`; `REQ-005`; `AC-003`.
- Implementation delta: Changed the existing ARM local-load case label in `build-multi-arch.sh` from `aarch64)` to `arm64|aarch64)`, normalizing both supported host spellings to the existing canonical Docker platform `linux/arm64`. No other build logic or test code changed.
- Changed files or areas: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/build-multi-arch.sh:81`; current implementation handoff and revision record; focused evidence at `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/implementation-ir-003-architecture-alias-check.log`.
- Local validation and result: Bash syntax and ShellCheck passed. Controlled script invocations proved `arm64 --no-cache -> --load --no-cache --platform linux/arm64`, retained `aarch64 -> linux/arm64`, retained `x86_64 -> linux/amd64`, retained multi-platform `--push` and default/`zh` tag/variant behavior, and retained the explicit unsupported-host failure. The existing source-contract check and `git diff --check` passed.
- Next recipient or routing: `/code_reviewer` for source review before API/E2E resumes.
- Remaining limitations or risks: The focused check used controlled command doubles and does not satisfy AC-003. API/E2E must rerun `APIE2E-F-002`/AC-003 first and then its applicable regression gate. Delivery, Docker Hub publication, remote manifest verification, and server adoption remain blocked. The API/E2E-owned round-3 test/report/evidence changes were preserved unchanged by IR-003.

### IR-004 — Integrate the latest base without regressing the approved Noble release

- Triggering role, report path, and round: Delivery Engineer; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/delivery-revision-record.md`; delivery integration refresh `DR-003`.
- Triggering finding IDs: `DR-003` latest-base merge blocker.
- Classification: `Local Fix`.
- Prior authoritative result: `Blocked` — Delivery protected the review/API-E2E-passed candidate at `ffda31a1edaf1d67c45310474aee465886f1b3e2`, but `git merge --no-ff origin/main` at `fb0f59372254b853e85c69046aa921f1d59d96c7` conflicted in `Dockerfile`, `README.md`, `VERSION`, and `base.conf` and was aborted.
- Current authoritative result: Latest tracked `origin/main` is merged into the ticket branch with all overlaps intentionally resolved. Focused implementation checks pass; the integrated state requires source review and API/E2E before Delivery may resume.
- Related solution revision IDs: `RER-006`.
- Related architecture-review revision IDs: `N/A — approved direct route`.
- Related code-review revision IDs: `CRR-004` source pass and `CRR-005` durable-test pass for the pre-integration candidate.
- Related API/E2E revision IDs: `API-REV-004` (`Pass`, pre-integration candidate).
- Related delivery revision IDs: `DR-003`.
- Why this baseline or implementation revision is recorded: Preserve the approved Ubuntu 24.04/Python 3.12/browser-image `1.4.0` contract while incorporating applicable fixes and additions that landed on the current base after the ticket branch point.
- Approved behavior or requirement IDs affected: `BEH-001`–`BEH-003`; `REQ-001`–`REQ-008`; `SCN-001`–`SCN-004`; `AC-001`–`AC-011`. `REQ-009`/`AC-012` remain a delivery sequencing boundary and no server source changed.
- Implementation delta: Re-ran `git merge --no-ff origin/main`; retained `ubuntu:24.04`, Noble-native Python 3.12 packages, `/opt/browser-tools`, stable websockify assets, version `1.4.0`, dynamic configured-UID runtime paths, and `/usr/bin/supervisord`; incorporated the current-base `gh` package and `start-chrome.sh` wrapper, including its `AUTOBYTEUS_NODE_PROFILE=mobile-safe` `--no-sandbox` behavior; wired Supervisor to the wrapper; and accepted the current-base historical ticket artifacts. Rejected active-source regressions to Ubuntu 22.04, Python 3.13, pip-installed Supervisor 4.3.0, fixed UID 1000 paths, Python-version-specific websockify assets, and version `1.3.8`.
- Changed files or areas: `Dockerfile`, `base.conf`, `entrypoint.sh`, new `start-chrome.sh`, current-base historical files under `tickets/`, current implementation handoff/revision record, and `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/implementation-ir-004-latest-base-integration-check.log`. `README.md` and `VERSION` conflict resolutions retain the ticket values and therefore have no net content delta from the ticket parent.
- Local validation and result: Merge-parent identity, conflict-marker/whitespace checks, Bash syntax, ShellCheck, the existing source-contract harness, rejected-assumption scans, Noble tool/Supervisor/websockify assertions, `gh`/Chromium-wrapper integration, normal and `mobile-safe` Chromium argument composition, runtime/platform/variant/port preservation, and source-size guardrails passed. Delivery-owned `DR-003` artifacts were hash-verified byte-for-byte unchanged, and no durable test file changed.
- Next recipient or routing: `/code_reviewer` for integrated-source review before API/E2E re-entry.
- Remaining limitations or risks: Implementation checks do not rebuild or run the integrated image. API/E2E must determine and execute the applicable integration regression matrix, including the new Chromium wrapper and `mobile-safe` path. Delivery, Docker Hub publication, remote manifests/runtime identity, explicit user verification, finalization, and server adoption remain blocked.
