# Requirements Revision Record

The latest `requirements-doc.md` and `investigation-notes.md` remain authoritative.

## Revision Index

| Revision ID | Trigger / Round | Prior Status | Current Status | Affected Requirement / Behavior IDs | Result |
| --- | --- | --- | --- | --- | --- |
| RER-001 | Initial Ubuntu 24.04 minimal-base requirements baseline | N/A | Ready for Approval | REQ-001–REQ-006; BEH-001–BEH-003 | Evidence-backed baseline created and presented for explicit approval. |
| RER-002 | User clarification of “minimal” | Ready for Approval | Ready for Approval | ASM-002; DEC-001; scope boundary | Confirmed that minimal applies to the official base image; installed-feature pruning remains out of scope. |

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
