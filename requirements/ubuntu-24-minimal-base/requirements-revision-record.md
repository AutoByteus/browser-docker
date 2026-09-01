# Requirements Revision Record

The latest `requirements-doc.md` and `investigation-notes.md` remain authoritative.

## Revision Index

| Revision ID | Trigger / Round | Prior Status | Current Status | Affected Requirement / Behavior IDs | Result |
| --- | --- | --- | --- | --- | --- |
| RER-001 | Initial Ubuntu 24.04 minimal-base requirements baseline | N/A | Ready for Approval | REQ-001–REQ-006; BEH-001–BEH-003 | Evidence-backed baseline created and presented for explicit approval. |
| RER-002 | User clarification of “minimal” | Ready for Approval | Ready for Approval | ASM-002; DEC-001; scope boundary | Confirmed that minimal applies to the official base image; installed-feature pruning remains out of scope. |
| RER-003 | Python runtime modernization question | Ready for Approval | Ready for Approval | REQ-004, REQ-007; BEH-002; AC-006, AC-010; SCN-003; ASM-003; DEC-002 | Proposed Ubuntu-native Python 3.12 instead of current Deadsnakes Python 3.11 or a newer PPA-only interpreter. |
| RER-004 | User agreement on Python 3.12 | Ready for Approval | Ready for Approval | REQ-007; ASM-003; DEC-002 | Python 3.12 selection confirmed; complete-package approval remains pending. |
| RER-005 | Two-ticket upstream-first delivery sequence | Ready for Approval | Ready for Approval | REQ-008–REQ-009; AC-011–AC-012; SCN-005; DEC-003; scope boundary | Browser image publication is the first ticket; server/all-in-one adoption is a separate dependent follow-up. |

## Revision Entries

### RER-001 — Ubuntu 24.04 LTS minimal OCI base baseline

- Triggering user feedback, prototype package, downstream feedback, or investigation evidence: User requested replacement of the too-old Ubuntu 22 base with the stable minimal Ubuntu 24 base in `/home/autobyteus/workspace/browser-docker`.
- Prior authoritative status (`N/A` for `RER-001`): N/A
- Current authoritative status: Ready for Approval
- Requirement, behavior, acceptance-criteria, scenario, or decision IDs affected: Initial creation of REQ-001–REQ-006, BEH-001–BEH-003, AC-001–AC-009, SCN-001–SCN-004, ASM-001–ASM-003, and DEC-001.
- Scenario-basis or scenario-validity changes: Initial supported operational/system/contract scenario basis recorded from repository build, run, and documentation surfaces.
- Why this baseline or revision was recorded: Establish an unambiguous, testable scope that upgrades the official base release without silently deleting existing image capabilities.
- Canonical artifact sections changed: All initial sections in `requirements-doc.md` and `investigation-notes.md`.
- Supplemental artifacts added, changed, or removed: This revision record was added; no product-design artifacts apply.
- Prototype evidence or product decisions incorporated: N/A — no Product Design request.
- User approval impact: Explicit approval is still required, particularly for the interpretation that “minimal” refers to the official minimal Ubuntu OCI rootfs rather than installed-feature pruning.
- Downstream architecture or direct-implementation route impact: Routing assessment is intentionally deferred until approval; current evidence suggests a bounded base/dependency compatibility change, subject to the formal post-approval assessment.
- Remaining gaps, assumptions, or blocked decisions: ASM-001/ASM-002 and DEC-001 require user approval; Docker/BuildX validation is unavailable in the requirements environment.
- Next action or recipient: User reviews and explicitly approves or revises the baseline.

### RER-002 — Minimal-base terminology confirmed

- Triggering user feedback, prototype package, downstream feedback, or investigation evidence: User clarified, “minimal is the base version itself.”
- Prior authoritative status (`N/A` for `RER-001`): Ready for Approval
- Current authoritative status: Ready for Approval
- Requirement, behavior, acceptance-criteria, scenario, or decision IDs affected: ASM-002 and DEC-001; no REQ/BEH/AC/SCN behavior changed.
- Scenario-basis or scenario-validity changes: None.
- Why this baseline or revision was recorded: Convert the only material scope interpretation from an assumption into a user-confirmed decision.
- Canonical artifact sections changed: Document approval reference, Assumptions, Open Decisions, Readiness Check, Initial Request And Clarifications, Source Log, and risk/assumption record.
- Supplemental artifacts added, changed, or removed: None.
- Prototype evidence or product decisions incorporated: N/A — no Product Design request.
- User approval impact: The base-image meaning of “minimal” is confirmed. Explicit approval of the complete requirements baseline remains pending.
- Downstream architecture or direct-implementation route impact: No change; post-approval routing assessment remains required.
- Remaining gaps, assumptions, or blocked decisions: Explicit approval of the complete requirements baseline; executable Docker/BuildX validation remains downstream.
- Next action or recipient: User explicitly approves or revises the complete baseline.

### RER-005 — Separate browser release from server adoption

- Triggering user feedback, prototype package, downstream feedback, or investigation evidence: User proposed creating a separate browser Docker ticket, building and publishing its new base version to Docker Hub, and only then working on server updates.
- Prior authoritative status (`N/A` for `RER-001`): Ready for Approval
- Current authoritative status: Ready for Approval
- Requirement, behavior, acceptance-criteria, scenario, or decision IDs affected: New REQ-008–REQ-009, AC-011–AC-012, SCN-005, DEC-003, and scope/release/dependency boundaries.
- Scenario-basis or scenario-validity changes: Added the supported upstream-release-before-downstream-adoption operational scenario.
- Why this baseline or revision was recorded: Establish independent repository ownership, validation, publication, rollback evidence, and a stable dependency identity before server adoption.
- Canonical artifact sections changed: Desired Outcome, scope/non-goals, Requirements, Acceptance Criteria, Scenarios, Dependencies, Supplemental Artifacts, Open Decisions, Traceability, Downstream Input, Readiness Check, and corresponding investigation evidence.
- Supplemental artifacts added, changed, or removed: Added `server-base-image-adoption-follow-up.md`.
- Prototype evidence or product decisions incorporated: N/A — no Product Design request.
- User approval impact: Two-ticket sequencing is confirmed. Complete first-ticket approval and its proposed `1.4.0`/`1.4.0-zh` version identity remain pending.
- Downstream architecture or direct-implementation route impact: First ticket routes only browser repository work and publication. Server repository work must enter through a new requirements package after AC-011 is satisfied.
- Remaining gaps, assumptions, or blocked decisions: Explicit complete-package approval, including DEC-003; Docker/BuildX and Docker Hub validation remain downstream.
- Next action or recipient: User approves or revises the browser-image ticket package and recommended release identity.

### RER-003 — Recommend Noble-native Python 3.12

- Triggering user feedback, prototype package, downstream feedback, or investigation evidence: User asked whether current Python 3.11 should move to Python 3.12 or 3.13 because newer libraries increasingly use those versions.
- Prior authoritative status (`N/A` for `RER-001`): Ready for Approval
- Current authoritative status: Ready for Approval
- Requirement, behavior, acceptance-criteria, scenario, or decision IDs affected: REQ-004, new REQ-007, BEH-002, AC-006, new AC-010, SCN-003, ASM-003, and DEC-002.
- Scenario-basis or scenario-validity changes: SCN-003 now includes using Python 3.12 and preserving Python-installed runtime services/tools.
- Why this baseline or revision was recorded: Python 3.11 was previously a preservation constraint; the user explicitly reopened it. Canonical evidence shows 3.12 is Ubuntu 24.04's official/default Python, while 3.13 would require a non-default source on Noble.
- Canonical artifact sections changed: Desired Outcome, behavior/scope/requirements/acceptance/scenario/quality/dependency/assumption/decision/traceability/downstream/readiness sections and corresponding investigation evidence.
- Supplemental artifacts added, changed, or removed: None.
- Prototype evidence or product decisions incorporated: N/A — no Product Design request.
- User approval impact: Explicit approval is required for proposed REQ-007 selecting Python 3.12.
- Downstream architecture or direct-implementation route impact: Python source, installation, `pip` isolation, and hard-coded websockify path now require validation; routing remains pending approval.
- Remaining gaps, assumptions, or blocked decisions: User decision on Python 3.12 recommendation and complete-baseline approval; Docker/BuildX validation remains downstream.
- Next action or recipient: User accepts Python 3.12 and approves the complete baseline, or selects a different version for revision.

### RER-004 — Python 3.12 selection confirmed

- Triggering user feedback, prototype package, downstream feedback, or investigation evidence: User stated, “i agree with Python 3.12.”
- Prior authoritative status (`N/A` for `RER-001`): Ready for Approval
- Current authoritative status: Ready for Approval
- Requirement, behavior, acceptance-criteria, scenario, or decision IDs affected: REQ-007 priority/decision reference, ASM-003, and DEC-002.
- Scenario-basis or scenario-validity changes: None; the proposed SCN-003 behavior is now user-confirmed.
- Why this baseline or revision was recorded: Convert the Python 3.12 recommendation into an explicit user decision without treating agreement on one decision as approval of the entire requirements package.
- Canonical artifact sections changed: Document approval reference, Requirements, Assumptions, Open Decisions, Readiness Check, Initial Request And Clarifications, Source Log, and assumption record.
- Supplemental artifacts added, changed, or removed: None.
- Prototype evidence or product decisions incorporated: N/A — no Product Design request.
- User approval impact: REQ-007's version choice is explicitly confirmed; the complete requirements package still requires explicit approval.
- Downstream architecture or direct-implementation route impact: No change from RER-003; Python 3.12 is now the required selection once the package is approved.
- Remaining gaps, assumptions, or blocked decisions: Explicit approval of the complete requirements baseline; Docker/BuildX validation remains downstream.
- Next action or recipient: User explicitly approves or revises the complete baseline.
