# Solution Revision Record

The latest `requirements-doc.md`, `investigation-notes.md`, `design-spec.md`, and listed supplements are authoritative. This record indexes solution rounds without duplicating them.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Finding IDs | Classification | Result |
| --- | --- | --- | --- | --- |
| SR-001 | Initial solution baseline established after Implementation Engineer RER-007 downstream re-entry | N/A | `Initial Baseline` with resolved `Requirement Gap` and addressed `Design Impact` | Revised Python 3.13/Noble/tool-ownership design is ready for architecture review; stale Python 3.12 target remains blocked. |
| SR-002 | Architecture Reviewer / `design-review-report.md` / `ARCH-REV-001` | `ARCH-F-001` | `Design Impact` | Active server-adoption intake and DEC-003 dependency wording are aligned; corrected cumulative package is ready for architecture re-review. |

## Revision Entries

### SR-001 — Noble Python 3.13 and isolated operational-tool baseline

- Triggering role, report path, and round: Initial solution-design baseline created after Implementation Engineer reported the user-approved Python 3.13 supersession following `IR-004`/`DR-003`; related reports are `implementation-handoff.md`, `implementation-revision-record.md`, and `delivery-revision-record.md` in this ticket folder.
- Triggering finding IDs: `N/A` for initial baseline. Context classification was downstream `Requirement Gap / Design Impact`.
- Prior authoritative result: `N/A` for solution-design history. The prior requirements route was RER-006 direct implementation with no design artifact; integrated source at `cc30abf` implemented the now-superseded Python 3.12 target.
- Current authoritative result: `RER-007` is approved/revised; design selects public Python 3.13 from stable Deadsnakes Noble packages, preserves Noble's `/usr/bin/python3`, and places Supervisor 4.3.0/websockify/uv in one `/opt/browser-tools` Python 3.13 environment exposed through stable `/usr/local` commands/assets. Ready for architecture review.
- Why this baseline or revision entry is recorded: The explicit user decision invalidated the old direct-route implementation and exposed an ownership boundary across OS Python, public developer Python, Supervisor, pip-installed operational tools, entrypoint launch, and stable web assets. A formal solution package did not previously exist.
- Resolution: Updated REQ-007 and affected behavior/AC/scenario/quality/dependency/routing sections; refreshed current-state investigation at `cc30abf`; verified Deadsnakes Noble Python 3.13 availability on AMD64/ARM64 and the proposed isolated boundary on ARM64; designed a clean-cut single-provider implementation and complete integrated validation matrix.
- Approved behavior or requirement IDs affected: BEH-001–BEH-002; REQ-007; AC-006, AC-010–AC-011, new AC-013; SCN-003; QR-005; ASM-003; DEC-002. All other RER-006-approved IDs are preserved.
- Canonical artifacts and sections updated: `requirements-doc.md` (`RER-007`); `requirements-revision-record.md` (`RER-007`); complete current `investigation-notes.md`; new `design-spec.md`.
- Supplemental artifacts updated, added, or removed: Added `evidence/solution-sr001-python313-noble-probe.log` and `evidence/solution-sr001-python313-noble-amd64-availability.log`; retained `server-base-image-adoption-follow-up.md` unchanged.
- Downstream and architecture-review impact: Former direct route is revoked. `/architecture_reviewer` must pass the design before `/implementation_engineer` changes source. The final implementation then returns through source review, API/E2E coverage investigation/execution, proportional review of any durable coverage changes, and Delivery. Publication/finalization/server adoption remain blocked.
- Next recipient or routing: `/architecture_reviewer` with the complete cumulative solution package and triggering implementation/delivery evidence.
- Remaining gaps or risks: External package mutability; full final default/zh × AMD64/ARM64 build/runtime matrix; configured identity, service/browser/profile/locale/mobile-safe coverage; build/load/push/tag checks; and post-gate publication/manifests remain downstream.


### SR-002 — Align the active server-adoption intake with the approved release

- Triggering role, report path, and round: Architecture Reviewer; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/design-review-report.md`; `ARCH-REV-001`, round 1.
- Triggering finding IDs: `ARCH-F-001`.
- Prior authoritative result: `Fail — Design Impact`. The structural Python 3.13/Noble design otherwise passed, but the active current server-adoption supplement still instructed publication/inherited validation of public Python 3.12 and the requirements dependency table incorrectly said DEC-003 awaited approval.
- Current authoritative result: The current follow-up brief now requires the verified Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 `1.4.0`/`1.4.0-zh` artifact, distinguishes Noble's internal distribution Python from the public runtime, and remains deferred, separate, and non-authorizing. DEC-003 is consistently recorded as approved/resolved. The design explicitly inventories this documentation/intake replacement. Ready for architecture re-review.
- Why this baseline or revision entry is recorded: SCN-005 makes the follow-up intake a reachable current handoff artifact after AC-011. Leaving its old public Python 3.12 target would contradict RER-007 and send the later ticket the wrong validation contract.
- Resolution: Rewrote `server-base-image-adoption-follow-up.md` sequence, activation identity, consumer validation targets, scope/non-goals, and required evidence; corrected the Docker Hub dependency-table row in `requirements-doc.md`; updated investigation evidence/supplement state; added the brief to the design behavior map, intended change, removal plan, off-spine/documentation allocation, draft/final file responsibilities, target mapping, sequence, and implementation guidance.
- Approved behavior or requirement IDs affected: No approved behavior changed. Corrections protect REQ-007–REQ-009, AC-011–AC-013, BEH-002–BEH-003, and SCN-005.
- Canonical artifacts and sections updated: `requirements-doc.md` External Contracts/Dependencies, Supplemental Artifacts, and architecture-review status; `investigation-notes.md` meta/source/payload/supplement/implication/downstream notes; `design-spec.md` behavior/supplement/removal/documentation/file/change inventories; `server-base-image-adoption-follow-up.md`; this revision record.
- Supplemental artifacts updated, added, or removed: Updated `server-base-image-adoption-follow-up.md`; no new supplement added or removed. Existing Noble probe logs remain unchanged.
- Downstream and architecture-review impact: No source design changes. `/architecture_reviewer` must re-review SR-002 with ARCH-F-001 as the only prior open finding. Implementation remains blocked until a Pass.
- Next recipient or routing: `/architecture_reviewer` for round-2 re-review with the cumulative package, `design-review-report.md`, and `architecture-review-revision-record.md`.
- Remaining gaps or risks: Same downstream execution risks as SR-001: mutable remote packages; final default/zh × AMD64/ARM64 build/runtime matrix; configured identity, services/browser/profile/locale/mobile-safe behavior; tags/load/push; and post-gate publication/manifests.
