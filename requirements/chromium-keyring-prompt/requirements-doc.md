# Requirements Document

## Document Status

- Status: `Approved`
- Current solution revision ID: `SR-004`
- Package identifier: `BRD-KEYRING-PROMPT-001`
- Request / ticket: Disable the "Choose password for new keyring" popup in AutoByteus server Docker nodes (user, 2026-09-24)
- Requirements owner: Solution Designer
- Date: 2026-09-25
- Approval state and reference: **Approved** by the user on 2026-09-25 ("approve.") in reply to the Solution Designer recommendation "remove the keyring and also keep the Chromium flag" with defaults: release base 1.4.1 (default + zh, amd64 + arm64) then rebuild server images; one-time re-login acceptable in nodes where a keyring password was typed; "Restore pages?" bubble in a separate ticket. Release-trigger mechanics delegated to the Solution Designer by the user on 2026-09-25 ("trigger rebuild manually or no? but you know it") → DEC-005.
- Exact approved requirements baseline / solution revision: This document at `SR-004`.
- Behavior-defining supplements and their approved versions: None

## Problem And Desired Outcome

- Problem: Since the Ubuntu 24.04 browser base (`autobyteus/chrome-vnc:1.4.0`, and server images built on it), every node shows a modal GNOME keyring dialog ("Choose password for new keyring … Default Keyring") at Chromium startup. Chromium 151 asks the Secret Service for its encryption key; `gnome-keyring` (a separate daemon, pulled in unintentionally as an apt *Recommends* of desktop extras) has no keyring and prompts. While it is pending, website navigation does not complete (observed ≥ 90 s), so agents are blocked until a human answers.
- Affected actors or systems: AutoByteus agents driving Chromium over DevTools and running tools in the node; operators viewing nodes via VNC/noVNC; server URL-opening bridge.
- Desired outcome: The node is an agent-operated machine that never stops on an interactive keyring dialog: the interactive keyring service is not shipped, and Chromium never uses an OS keyring — as on 1.3.x.
- Observable definition of success: On a fresh node, after startup and opening a website, no keyring dialog or keyring daemon exists, the page loads, and any keyring request fails immediately.

## Relevant Current And Desired Behavior

| Behavior ID | Kind | Related Scenario IDs | Evidence-Backed Current Behavior | Desired Behavior | Intentionally Preserved Behavior | Investigation Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | System | SCN-001 | Chromium startup triggers a pending keyring-creation dialog | No keyring dialog at any Chromium start | Chromium autostart, DevTools 9222/9223, profile volume + stale-lock recovery, mobile-safe `--no-sandbox` profile, XFCE/VNC/noVNC desktop | RUN-001/002 |
| BEH-002 | System/User | SCN-002 | Navigation stalls while the dialog is pending | Navigation completes without human interaction | Agent browser tools / `open-vnc-browser-url.sh` behavior | RUN-003/004 |
| BEH-003 | User | SCN-003 | Typing a password creates a container-layer keyring (lost on re-create) while the profile volume persists | No keyring exists or is used | — | DATA-001 |
| BEH-004 | Operational | SCN-001 | 1.3.x: no keyring provider, no dialog | Match 1.3.x (no interactive keyring service) | — | RUN-006 |
| BEH-005 | System | SCN-004 | 1.4.0: a keyring client run as `vncuser` raises the same dialog and hangs (probe E); root clients are rejected by the session bus (RUN-011) | Any keyring client (root or `vncuser`) fails immediately — no provider exists | — | RUN-008/009/011 |

## Stakeholders, Actors, And Outcomes

| Actor / Stakeholder | Goal Or Responsibility | Required Outcome | Important Constraint |
| --- | --- | --- | --- |
| AutoByteus agent | Browse via DevTools; run CLI tools | Pages load; tools never wait on a GUI dialog | DevTools contract unchanged |
| Operator | Observe/assist nodes via VNC | No spurious OS dialogs | — |
| Image maintainer | Release default/zh, amd64/arm64 | Fix applies to all variants and reaches server images | Base image is the single owner |

## Scope Guardrail (Mandatory)

### In-Scope Use Cases

- UC-001: Unattended Chromium startup in the browser base image and all images built on it (default + zh, amd64 + arm64).
- UC-002: Opening websites in that Chromium via DevTools, `xdg-open`/server bridge, or the desktop.
- UC-003: Any process in the node requesting the system keyring.
- UC-004: Publishing the fixed base image and getting it into the AutoByteus server images and existing nodes.

### Out Of Scope

- The "Restore pages? Chromium didn't shut down correctly" bubble (separate ticket, user decision DEC-004).
- Removing or slimming other desktop packages beyond `gnome-keyring`, `libpam-gnome-keyring` and the package that hard-depends on it (`evolution-data-server`).
- Turning off apt Recommends globally (`--no-install-recommends`).
- AutoByteus server **source** changes (the server image only needs a rebuild/re-publish).
- Pinning the server's base image to an immutable version/digest (tracked separately in the Ubuntu-24 adoption follow-up brief).

### Non-Goals

- Providing OS-keyring-grade encryption for browser cookies/passwords or tool credentials inside agent containers.

### Preserved Behavior Boundary

- BEH-001 preserved column; REQ-003; AC-004.

### Review Authority

- Blocking findings must cite REQ/AC/BEH IDs here; new policy is a Requirement Gap needing user approval.

## Requirements

| Requirement ID | Requirement | Related Behavior IDs | Priority / Criticality | Rationale | Source / Decision Reference |
| --- | --- | --- | --- | --- | --- |
| REQ-001 | Chromium must never use an OS keyring (Secret Service / portal / KWallet) on any launch path (supervisor autostart, `xdg-open`/server bridge, desktop launcher), independent of which packages are installed. | BEH-001, BEH-003 | Must | Agent-operated node; guard against keyring re-installation | Approval 2026-09-25; RUN-004/010 |
| REQ-002 | Website navigation must complete without human interaction after container start. | BEH-002 | Must | Dialog blocks agents | RUN-003/004 |
| REQ-003 | Existing behaviors are preserved: autostart, DevTools 9222/9223, persistent profile + stale-lock recovery, mobile-safe profile, XFCE/VNC/noVNC desktop, documented utilities, default/zh variants on amd64/arm64. | BEH-001 | Must | Avoid regressions | Existing contracts |
| REQ-004 | Browser-stored secrets are protected by Chromium's built-in (`basic`) store. | BEH-001 | Must | Only store needing no interactive unlock | Approval 2026-09-25 (DEC-001) |
| REQ-005 | The fix ships as browser base `1.4.1` (default + zh; amd64 + arm64; rolling `latest`/`zh` updated) and reaches the AutoByteus server images (default + zh) and the operator's existing nodes. | — | Must | Fix must reach running agents | Approval 2026-09-25 (DEC-002); DEC-005 |
| REQ-006 | The image must not ship an interactive keyring (Secret Service) provider, so every keyring request from any process fails immediately. | BEH-004, BEH-005 | Must | Agents cannot answer dialogs | Approval 2026-09-25 (DEC-001); RUN-007/009 |

## Acceptance Criteria

| Acceptance-Criteria ID | Related Requirement IDs | Related Behavior / Scenario IDs | Preconditions / Trigger | Observable Expected Outcome | Important Alternate Or Failure Outcome | Verification Intent |
| --- | --- | --- | --- | --- | --- | --- |
| AC-001 | REQ-001, REQ-006 | BEH-001 / SCN-001 | Fresh container (empty profile) started normally | No `gcr-prompter` or `gnome-keyring-daemon` process; no `org.freedesktop.secrets` activation in the session D-Bus log; Chromium main process carries `--password-store=basic` | — | Runtime check per variant/arch |
| AC-002 | REQ-002 | BEH-002 / SCN-002 | Navigate Chromium over DevTools to an `http://` page | Page renders within 30 s; still no dialog | — | Runtime check |
| AC-003 | REQ-001 | SCN-002 | Every Chromium launch goes through `/usr/bin/chromium` | Flag present for supervisor launch; the same drop-in applies to `xdg-open`/desktop launches | — | Image + runtime check |
| AC-004 | REQ-003 | BEH-001 | Existing validation suites | `tests/validate-*.sh` pass for default + zh (amd64 + arm64 image checks); DevTools on 9223, VNC, noVNC, profile write unchanged | — | Existing tests |
| AC-005 | REQ-004 | SCN-003 | Node re-created on an existing profile volume | Chromium starts without dialog; sites whose cookies were keyring-encrypted may need one re-login | — | Documented |
| AC-006 | REQ-005 | SCN-005 | Release | `autobyteus/chrome-vnc:1.4.1`, `latest`, `1.4.1-zh`, `zh` published for amd64 + arm64; server images (default + zh) re-published on the new base and pass AC-001/002/007; operator nodes upgraded | — | Release/validation evidence |
| AC-007 | REQ-006 | BEH-005 / SCN-004 | Node running; request the Secret Service (`org.freedesktop.secrets`) as `vncuser` | Fails within 2 s with "not provided by any .service files"/ServiceUnknown; no dialog | — | Runtime check |
| AC-008 | REQ-006 | BEH-004 | Built image | `gnome-keyring` and `libpam-gnome-keyring` not installed; no `org.freedesktop.secrets` D-Bus service file; `chromium` and XFCE still installed | — | Image check |

## Relevant Scenarios And Journeys

| Scenario ID | Kind | Actor / Initiator / Governing Contract | Coherent Goal Or Governing Event | Supported Trigger / Entry Surface | Starting Condition | Product-Level Steps Or Event Sequence | Expected Outcome | Supported Alternate / Error Behavior | Scenario Validity | Independent Evidence / Decision Reference | Related Requirement / AC IDs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SCN-001 | System | Container runtime / supervisor | Node becomes ready | `docker run` / restart | Fresh or existing profile volume | Desktop + Chromium start | Browser ready, no dialog | — | Supported Normal Scenario | RUN-001/002 | REQ-001/003/006, AC-001/004/008 |
| SCN-002 | User/System | Agent or operator | Open a website | DevTools, server bridge, desktop | Node ready | Tab opens and navigates | Page loads unattended | — | Supported Normal Scenario | RUN-003/004; user screenshot | REQ-001/002, AC-002/003 |
| SCN-003 | Operational | Operator | Upgrade an existing node | `autobyteus-docker upgrade --all` | Profile volume may hold keyring-encrypted values | Pull, re-create with same volumes | No dialog; possible one-time re-login | — | Supported Normal Scenario | DATA-001; RUN-013 | REQ-004, AC-005 |
| SCN-004 | System | Agent / any process | Store a credential via the system keyring | e.g. `gh auth login`, git credential helper, Python `keyring` | Node ready | Tool asks the Secret Service | Immediate failure; tool uses its own fallback | — | Supported Normal Scenario | RUN-008/009/011 | REQ-006, AC-007 |
| SCN-005 | Operational | Image maintainer | Ship the fix | Base release, server re-publish, node upgrade | 1.4.0-based images in use | Publish base → re-publish server → upgrade nodes | All nodes run the fixed base | — | Supported Normal Scenario | RUN-013 | REQ-005, AC-006 |

## UI, Interaction, And Experience Requirements

- Applicable: `No`
- All prototype/UI fields: N/A — not applicable.

## Quality And Non-Functional Requirements

| Quality ID | Related Requirement / AC IDs | Area | Measurable Requirement Or Constraint | Conditions / Scope | Verification Intent |
| --- | --- | --- | --- | --- | --- |
| QR-001 | REQ-001/006, AC-001/007 | Reliability | Zero keyring prompts across startup and navigation; keyring requests fail in ≤ 2 s | default/zh × amd64/arm64 | Runtime check |
| QR-002 | REQ-004 | Security | Accepts Chromium built-in key protection for browser secrets and file-based fallback for tool credentials | All nodes | Approved 2026-09-25 |

## Data Continuity And Acceptable Loss

- Persisted or external data affected: `Yes`
- Data or state that must be preserved: The Chromium profile volume (history, bookmarks, extensions, preferences, cookies stored with the built-in key) and all other node volumes.
- Loss acceptable (approved): Cookie/password values encrypted with a keyring-held key (only where an operator typed a keyring password, e.g. `autobyteus-server-0`) become unreadable → one-time re-login for those sites.
- Constraints: None beyond the above.
- Unknowns: None blocking.

## External Contracts And Dependencies

| Contract / Dependency | Required Behavior Or Constraint | Evidence / Authority | Uncertainty Or Risk |
| --- | --- | --- | --- |
| Chromium `--password-store=basic` | Disables all keyring providers | Chromium source (TECH-005/006), docs | Future semantics change → caught by AC-001 |
| xtradeb Chromium wrapper `/etc/chromium.d` | Sources drop-ins for all launches | TECH-003 | Packaging change → caught by AC-001/003 |
| Ubuntu 24.04 package graph | `gnome-keyring` is only Recommended except by `evolution-data-server` | RUN-007/012 | Future hard dependency → caught by AC-008 |
| Server image | `FROM autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` (`latest` / `zh`) | superrepo Dockerfile | Needs re-publish (DEC-005) |
| Node launcher | `autobyteus-docker upgrade --all` pulls and re-creates keeping volumes | RUN-013 | — |

## Supplemental Artifacts

| Artifact Path | Purpose | Related Requirement / AC IDs | Status | Approval Applicability / State |
| --- | --- | --- | --- | --- |
| `investigation-notes.md` | Evidence | All | Current | Evidence only |
| `evidence/*.png`, `evidence/probe-chromium-d-dropin.txt` | Reproduction and fix probes | AC-001..003 | Final | Evidence only |

## Assumptions

| Assumption ID | Assumption | Why It Is Necessary | Validation Plan / Owner | Status |
| --- | --- | --- | --- | --- |
| ASM-001 | No non-Chromium process in the image prompts for a keyring once the provider is removed | Otherwise a dialog could persist | Probes F/G; AC-001/007 | Supported by evidence |

## Open Decisions And Questions

| Decision / Question ID | Question | Why It Matters | Options / Evidence | Decision Owner | Status |
| --- | --- | --- | --- | --- | --- |
| DEC-001 | How to disable the prompt? | Security posture + blast radius | Remove `gnome-keyring` + `libpam-gnome-keyring` **and** Chromium `--password-store=basic` on all launch paths | User | **Approved 2026-09-25** |
| DEC-002 | Where to ship? | Release path | Base `1.4.1` (default + zh; amd64 + arm64) → server images rebuilt on it | User | **Approved 2026-09-25** |
| DEC-003 | One-time re-login acceptable? | Data continuity | Yes | User | **Approved 2026-09-25** |
| DEC-004 | "Restore pages?" bubble | Scope | Separate ticket | User | **Approved 2026-09-25** |
| DEC-005 | How does the server image pick up the new base? | Release mechanics | No server code change. Manually run only the **Server Docker Release** workflow (`workflow_dispatch`) for the latest published release tag (default, then `publish_zh=true`), instead of cutting a new `v*` tag that would also fire desktop/Android/iOS/gateway releases. Then `autobyteus-docker upgrade --all` for local nodes. | Solution Designer (delegated by user 2026-09-25) | Decided; user may override |

## Traceability

| Requirement ID | Use-Case IDs | Behavior IDs | Acceptance-Criteria IDs | Scenario IDs | Supplemental / Prototype Evidence |
| --- | --- | --- | --- | --- | --- |
| REQ-001 | UC-001, UC-002 | BEH-001, BEH-003 | AC-001, AC-003 | SCN-001, SCN-002 | probes A/B |
| REQ-002 | UC-002 | BEH-002 | AC-002 | SCN-002 | probes A/B |
| REQ-003 | UC-001 | BEH-001 | AC-004 | SCN-001 | — |
| REQ-004 | UC-001 | BEH-001 | AC-005 | SCN-003 | — |
| REQ-005 | UC-004 | — | AC-006 | SCN-003, SCN-005 | RUN-013 |
| REQ-006 | UC-003 | BEH-004, BEH-005 | AC-001, AC-007, AC-008 | SCN-001, SCN-004 | probes E/F/G |

## Architecture Phase Input

- Approved scenario IDs: SCN-001..005.
- Constraints: REQ-003 preserved behaviors; flag must cover all Chromium launch paths; base image is the single owner.
- Deferred to design: exact file/placement, test additions, release sequencing.
- Technical facts to verify: zh variant package graph; amd64 build.
- Known risks: RSK-001, RSK-002, RSK-004.

## Readiness Check

### Content Ready For Approval

- Relevant current behavior is evidence-backed: `Yes`
- Desired and preserved behavior are explicit: `Yes`
- Scope and non-goals are clear: `Yes`
- Requirements and acceptance criteria are testable and traceable: `Yes`
- Applicable scenarios are covered with validity and evidence: `Yes`
- Prototype and supplemental evidence is integrated consistently: `N/A`
- Applicable UI/UX approval and final visual-reference basis are recorded: `N/A`
- Material assumptions and open decisions are visible: `Yes`
- Content ready for user approval: `Yes`
- Remaining content blocker: None

### Approved Basis Ready For Design

- User approval received: `Yes` (2026-09-25)
- Exact requirements and supplement approval basis recorded: `Yes` (SR-004)
- Approved requirements package ready for architecture design: `Yes`
- Remaining blocker: None
