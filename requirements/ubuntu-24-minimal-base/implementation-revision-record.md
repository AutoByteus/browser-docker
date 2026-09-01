# Implementation Revision Record

The current source and `implementation-handoff.md` remain authoritative.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Finding IDs | Classification | Related Revision IDs | Result |
| --- | --- | --- | --- | --- | --- |
| IR-001 | Requirements Engineer / approved BRD-UBUNTU24-001 package / initial implementation | N/A | `Initial Baseline` | `AD-REV: N/A`; `ARCH-REV: N/A`; `CRR: N/A`; `API-REV: N/A`; `DR: N/A` | Ubuntu 24.04/Python 3.12 source implementation completed and ready for direct API/E2E validation. |
| IR-002 | Code Reviewer / `code-review-report.md` / API/E2E failure-origin round 1 | `APIE2E-F-001` | `Local Fix` | `AD-REV: N/A`; `ARCH-REV: N/A`; `CRR-001`; `API-REV-001`; `DR: N/A` | Noble's base `ubuntu` identity is cleanly superseded before creating the required default or custom `vncuser` identity; focused checks pass. |

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
