# Solution Revision Record

## Revision Index

| Revision ID | Phase | Trigger / Report / Round | Finding IDs | Prior Status | Current Status | Affected Behavior / Requirement IDs | Result |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SR-001 | Requirements | Initial coherent baseline from user report 2026-09-24 | N/A | N/A | Ready for Approval | BEH-001..004; REQ-001..005; AC-001..006 | Root cause confirmed; fix direction validated by probe; awaiting user decisions DEC-001..004 |
| SR-002 | Mixed (Requirements + Evidence) | User clarification 2026-09-24: agent-operated node must never block on the keyring | N/A | Ready for Approval | Ready for Approval | BEH-005 (new); REQ-001 (broadened); REQ-006 (new); AC-007 (new); SCN-004 (new); DEC-001 | Scope broadened from Chromium-only to all processes; recommendation A+B backed by probes E/F/G |
| SR-003 | Mixed (Requirements + Evidence) | User decision 2026-09-24: prefer simple solution (Chromium flag only) | N/A | Ready for Approval | Ready for Approval | REQ-001 (narrowed to Chromium), REQ-006 (now preserved fail-fast for root tools), BEH-005, SCN-004/005, AC-007, DEC-001, RSK-003 | Uninstall dropped; RUN-011 shows root agent tools already fail fast |
| SR-004 | Requirements | User approval 2026-09-25 ("approve.") of recommendation: remove keyring + keep Chromium flag; release defaults; release trigger delegated | N/A | Ready for Approval | Approved | REQ-001 (flag independent of packages), REQ-005 (server + nodes), REQ-006 (no provider; any process fails fast), AC-001..008, SCN-001..005, DEC-001..005 | Approved baseline |
| SR-005 | Design | Architecture design after SR-004 approval | N/A | N/A (no design) | Design Ready | All approved IDs | `design-spec.md` Ready; task_size Small; architectural_risk Low |

## Revision Entries

### SR-001 — Keyring prompt root cause and proposed unattended-browser requirements

- Phase and classification: `Initial Baseline`
- Triggering user feedback: User screenshot and request "how to disable it, please analyse" (2026-09-24); clarification that the base image lives in `/Users/normy/autobyteus_org/browser_docker`.
- Triggering finding IDs: N/A
- Prior authoritative requirements/design status: N/A
- Current authoritative requirements/design status: Requirements `Ready for Approval`; design not started.
- IDs affected: BEH-001..004, REQ-001..005, AC-001..006, SCN-001..003, DEC-001..004.
- Scenario-basis changes: N/A (baseline).
- Why recorded: First coherent requirements baseline presented for user approval.
- Canonical sections changed: All (new) — `requirements-doc.md`, `investigation-notes.md`.
- Supplemental artifacts added: `evidence/user-report-keyring-prompt.png`, `evidence/probe-a-control-prompt-blocks-navigation.png`, `evidence/probe-b-password-store-basic-loads.png`, `evidence/probe-c-cancel-unblocks-navigation.png`, `evidence/probe-chromium-d-dropin.txt`.
- Prototype evidence: N/A.
- Intended behavior changed: N/A (baseline).
- Approval impact: Pending explicit user approval; no approved baseline yet.
- Behavior-defining supplements: None.
- Affected design/review basis: N/A.
- Post-design classification: N/A before design completion.
- Applied handoff-rule outcome: None — routine approval hold in the requirements conversation.
- Downstream impact: None yet.
- Remaining gaps: DEC-001 (mechanism/security posture), DEC-002 (release path), DEC-003 (one-time re-login acceptance), DEC-004 (restore-pages bubble scope).
- Next action: Obtain user decisions and approval, then produce `design-spec.md`.

### SR-002 — Agent-first scope: no process may block on a keyring

- Phase and classification: `Refinement` (intended-behavior change proposed by the user; evidence added)
- Triggering user feedback: "I want to disable the key ring … the server Docker is supposed to be used by the agent itself … the agent is not like a human … suddenly they are blocked … Do we just disable the key ring or what?" (2026-09-24)
- Triggering finding IDs: N/A
- Prior authoritative requirements/design status: Requirements `Ready for Approval` (SR-001); design not started.
- Current authoritative requirements/design status: Requirements `Ready for Approval` (SR-002); design not started.
- IDs affected: BEH-005 (new), REQ-001 (broadened to all processes), REQ-006 (new, fail-fast), AC-007 (new), SCN-004 (new), UC-003 (new), QR-001/QR-002, DEC-001 (recommendation A+B).
- Scenario-basis changes: Added SCN-004 (agent-run keyring clients) as `Supported Normal Scenario`.
- Why recorded: The user clarified the node is agent-operated; probe RUN-008 showed the Chromium-only fix still lets any other keyring-using tool hang on the same dialog.
- Canonical sections changed: requirements-doc (status, problem/outcome, behavior table, actors, scope, requirements, ACs, scenarios, quality, DEC-001, traceability, readiness); investigation-notes (RUN-007..010, stakeholder evidence).
- Supplemental artifacts: None added (probe commands and results recorded inline in investigation notes).
- Intended behavior changed: `Yes` (broadened scope).
- Approval impact: Needs explicit user confirmation of the SR-002 baseline (DEC-001 A+B; DEC-002..004) before design.
- Affected design/review basis: N/A (no design yet).
- Post-design classification: N/A.
- Applied handoff-rule outcome: None — routine approval hold.
- Remaining gaps: User confirmation of DEC-001..DEC-004.
- Next action: On approval, mark requirements Approved, then produce `design-spec.md`.

### SR-003 — Simple solution: Chromium never uses a keyring; keep gnome-keyring installed

- Phase and classification: `Refinement` (user decision on DEC-001; evidence added)
- Triggering user feedback: "The password store equals basic basically stops popping up the key stuff … If the simple solution works, then I would go for the simple solution instead of … uninstall this key ring … is that key ring a separate library?" (2026-09-24)
- Triggering finding IDs: N/A
- Prior authoritative requirements/design status: Requirements `Ready for Approval` (SR-002); design not started.
- Current authoritative requirements/design status: Requirements `Ready for Approval` (SR-003); design not started.
- IDs affected: REQ-001 (narrowed to Chromium, all launch paths), REQ-006 (reframed: preserve root fail-fast), BEH-005, SCN-004 (root agent path), SCN-005 (new, manual vncuser tool — Unsupported/Contrived for this node), AC-007 (root probe), QR-001/002, DEC-001 (decided: flag only), RSK-003 (new), scope Out-Of-Scope (uninstall).
- Scenario-basis changes: SCN-004 re-grounded on RUN-011; SCN-005 recorded as out-of-scope residual.
- Why recorded: User chose the simple solution; RUN-011 shows server-run (root) agent tools are rejected by the desktop session bus, so the Chromium flag alone covers the agent path.
- Canonical sections changed: requirements-doc (status, outcome, BEH-005, actors, scope, REQ-001/006, AC-007, scenarios, quality, assumptions, DEC-001, traceability, readiness); investigation-notes (RUN-011, RSK-003, stakeholder evidence).
- Supplemental artifacts: None.
- Intended behavior changed: `Yes` (scope narrowed vs SR-002).
- Approval impact: Needs explicit user approval of SR-003 (DEC-002..004 defaults) before design.
- Affected design/review basis: N/A.
- Post-design classification: N/A.
- Applied handoff-rule outcome: None — routine approval hold.
- Remaining gaps: DEC-002..DEC-004 confirmation.
- Next action: On approval, mark requirements Approved and produce `design-spec.md`.

### SR-004 — Approved: remove the keyring provider and pin Chromium to the basic store

- Phase and classification: `Refinement` → `Approved` baseline
- Triggering user feedback: After asking whether the keyring is a separate program and whether our base image installs it, the user asked for the Solution Designer's recommendation and approved it on 2026-09-25 ("approve."). The user then asked how the server image picks up the fix ("trigger rebuild manually or no? but you know it"), delegating release mechanics (DEC-005).
- Triggering finding IDs: N/A
- Prior authoritative requirements/design status: Requirements `Ready for Approval` (SR-003); design not started.
- Current authoritative requirements/design status: Requirements `Approved` (SR-004).
- IDs affected: REQ-001 (Chromium flag independent of installed packages), REQ-005 (base 1.4.1 → server re-publish → node upgrade), REQ-006 (no provider shipped; any process fails fast), AC-001..AC-008, SCN-001..SCN-005 (SCN-005 = release; former vncuser-only residual removed), DEC-001..DEC-005, UC-004.
- Scenario-basis changes: SCN-004 generalized to any process; new SCN-005 (release).
- Why recorded: Explicit user approval; supersedes SR-003's flag-only decision.
- Canonical sections changed: requirements-doc (entire document rewritten to approved state); investigation-notes (RUN-012, RUN-013).
- Supplemental artifacts: None added.
- Intended behavior changed: `Yes` (vs SR-003) — approved.
- Approval impact, exact approved requirements baseline and user-approval reference: `requirements-doc.md` @ SR-004; user "approve." 2026-09-25; DEC-005 delegated 2026-09-25.
- Behavior-defining supplement versions: None.
- Affected design/review basis: N/A (design produced next).
- Post-design classification: N/A.
- Applied handoff-rule outcome: N/A.
- Remaining gaps: None.
- Next action: Architecture design.

### SR-005 — Architecture design

- Phase and classification: `Design` (initial design on approved basis)
- Triggering: SR-004 approval.
- Prior authoritative requirements/design status: Requirements `Approved` (SR-004); no design.
- Current authoritative requirements/design status: Requirements `Approved` (SR-004); `design-spec.md` `Ready`.
- IDs affected: All approved IDs mapped (behavior map DS-001..DS-003).
- Canonical sections changed: `design-spec.md` (new); investigation-notes (RSK-004, RSK-005, meta status).
- Intended behavior changed: `No`.
- Approval impact: None (design realizes SR-004).
- Post-design task-size/risk classification and rationale: `task_size=Small`, `architectural_risk=Low` — one repository, configuration-level change within existing owners, restores the probed known-good 1.3.x state; release via existing scripts/workflows; approved security/persistence effects. Escalation triggers recorded in the design.
- Applied handoff-rule outcome / result-file reference: see `handoff-architecture-design-complete.md`.
- Downstream and architecture-review impact: Per handoff rules.
- Remaining gaps: None.
- Next action: Route per handoff rules.
