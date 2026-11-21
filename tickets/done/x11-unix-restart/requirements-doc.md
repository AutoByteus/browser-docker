# Requirements Document

## Document Status

- Status: `Approved`
- Current solution revision ID: `SR-001`
- Package identifier: `x11-unix-restart`
- Request / ticket: Project Task `autobyteus-596` (Project `project_a1377344-25db-482a-97cc-ecfdb0fb495a`)
- Requested by: `/project_task_manager` (run `project_task_manager_7c8dce0c4a8b44f88e776a83809dee03`), dispatched on the founder's word
- Requirements owner: Solution Designer
- Date: 2026-11-21
- Approved by and reference: `Solution Designer within the direction (user informed)`; reference: Solution Designer conversation message of 2026-11-21 reporting the approved requirements and decisions DEC-001..DEC-005 (solution-revision-record `SR-001`)
- Exact approved requirements baseline / solution revision: this document at `SR-001`
- Behavior-defining supplements and their approved versions: None (the `probe/` files are evidence tools)

## Problem And Desired Outcome

- Problem: The node desktop of a Docker node (TigerVNC `Xvnc :99` and the XFCE, Chromium and CopyQ programs that depend on it) does not start when `/tmp/.X11-unix` is owned by root. `start-vnc.sh` runs as `vncuser` and unconditionally does `chmod 1777 /tmp/.X11-unix` under `set -e`. Linux refuses a mode change by a non-owner (EPERM), so the script exits before Xvnc starts. Supervisor retries 20 times and gives up, and the dependants go `FATAL`. Any root X server in the node, such as an agent's `xvfb-run` or `Xvnc :102`, takes the directory over as root. `/tmp` survives `docker restart`, so from then on every container restart, and every Supervisor restart of Xvnc, fails.
- Affected actors or systems: the founder viewing the node desktop (app or VNC viewer); agents using the node's Chromium; agents running their own root X servers; the `autobyteus/chrome-vnc` image (default and `zh`) and the AutoByteus server image built on it.
- Desired outcome: the node desktop comes up on every container start and on every Supervisor restart of Xvnc, whoever owns the X socket directory, while a root X server can still run alongside it.
- Observable definition of success: in throwaway containers of the fixed image, after a root X server has taken `/tmp/.X11-unix`, both `docker restart` and an abrupt kill-and-start bring all Supervisor programs to `RUNNING`, and the image's running-container validation passes. A Supervisor restart of Xvnc in the running container gives the same result.

## Relevant Current And Desired Behavior

| Behavior ID | Kind | Related Scenario IDs | Evidence-Backed Current Behavior | Desired Behavior | Intentionally Preserved Behavior | Investigation Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | SCN-001 | Fresh start: all programs `RUNNING`; dir `vncuser:vncuser 1777` | All programs `RUNNING`; dir in its defined state `root:root 1777` | Program set, users, ports, display `:99` | investigation-notes Probe "fresh start" |
| BEH-002 | Operational | SCN-002 | A root X server makes the dir `root:root 1777` | Unchanged (X convention); harmless to the node desktop | Root X servers can still run on other displays | Reproduced |
| BEH-003 | Operational | SCN-003 | Restart after BEH-002: tigervnc BACKOFF/FATAL; xfce, chrome, copyq FATAL | All programs `RUNNING` | — | Reproduced (control) |
| BEH-004 | Operational | SCN-004 | Supervisor restart of Xvnc after BEH-002: tigervnc BACKOFF | tigervnc and the desktop back to `RUNNING` | Supervisor autorestart policy | Reproduced (control) |
| BEH-005 | Operational | SCN-005 | Abrupt stop leaves `:99` lock/socket; cleared at start / by start-vnc.sh when no live X server owns them | Unchanged, also after a takeover | Refusal to start a duplicate `:99` while a live X server holds the lock | `entrypoint.sh`, `start-vnc.sh`, README |
| BEH-006 | Operational | SCN-006 | A dir that is not sticky world-writable and not vncuser's: no explicit handling (chmod error) | `start-vnc.sh` exits non-zero with a message naming the directory, its owner and mode | — | Design decision DEC-001 |

## Stakeholders, Actors, And Outcomes

| Actor / Stakeholder | Goal Or Responsibility | Required Outcome | Important Constraint |
| --- | --- | --- | --- |
| Founder | Use and watch the node desktop | Desktop available after any restart | His running nodes are not touched by this work |
| Agents in a node | Use Chromium over DevTools; run their own X servers as root | Chromium available; their X servers do not break the node desktop | — |
| Image maintainers / release | Publish `chrome-vnc` and server images | Clear release and rollout steps | Release only on the founder's word |

## Scope Guardrail (Mandatory)

### In-Scope Use Cases

| Use-Case ID | Use Case | Related Scenario IDs |
| --- | --- | --- |
| UC-001 | Node desktop starts on container start, including restarts after a root X server took the X socket directory | SCN-001, SCN-003, SCN-005 |
| UC-002 | Node desktop recovers when Supervisor restarts Xvnc in a running container after such a takeover | SCN-004 |
| UC-003 | An unusable X socket directory fails with a clear reason | SCN-006 |
| UC-004 | Operators can recover a running node of an older image, and know how the fix reaches the server image | SCN-007 |

### Out Of Scope

- The AutoByteus server image source (superrepo): no change in this ticket. Bumping its base digest is release work after the founder's word (DEC-004).
- Other displays' leftover locks/sockets (e.g. root `:102`): X servers already discard stale locks of dead processes; not part of this failure.
- The Supervisor `depends_on` key and program ordering; Chromium sandbox/capability flags.
- Publishing any image, and touching `autobyteus-server-0/1/2`.

### Non-Goals

- Preventing agents from running root X servers.
- Changing how agents' isolated-app recipes pick displays.

### Preserved Behavior Boundary

BEH-002 (root X servers still work), BEH-005 (stale `:99` handling and duplicate refusal), REQ-006, and every check in `tests/validate-image.sh`, `tests/validate-running-container.sh` and `tests/validate-source-contract.sh` that the change does not deliberately update.

### Prerequisites

None.

| Prerequisite ID | Finding And Evidence | Blocks (REQ / AC IDs) | Sent To (agent) / Task Key | Status (written down / sent / delivered) |
| --- | --- | --- | --- | --- |
| — | — | — | — | — |

### Review Authority

- Every blocking `Design Impact` or implementation-correction finding must cite an approved requirement, acceptance criterion, or preserved-behavior ID that it protects.
- A finding that would introduce new product behavior, policy, threat model, migration obligation, compatibility promise, or operational contract is a `Requirement Gap`; it requires explicit user approval before becoming authoritative.
- An adjacent concern outside the approved boundary may be recorded as a non-blocking risk, recommendation, or follow-up. It is not a required design correction, unless it is a prerequisite.
- A downstream reviewer comment does not amend this requirements basis.

## Requirements

| Requirement ID | Requirement | Related Behavior IDs | Priority / Criticality | Rationale | Feasibility Evidence | Source / Decision Reference |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001 | Xvnc `:99` starts as `vncuser` whenever `/tmp/.X11-unix` is a sticky world-writable directory, whichever user owns it. | BEH-003, BEH-004 | Critical | Root cause | Prototype probe: in-life and restart both `RUNNING` | Task direction |
| REQ-002 | At every container start, before Supervisor starts, `/tmp/.X11-unix` exists as `root:root` with mode 1777, whatever its earlier owner or mode; the image is built with the same state. | BEH-001, BEH-003 | High | One defined state; the X convention that root X servers produce anyway | Prototype probe | DEC-001 |
| REQ-003 | When `/tmp/.X11-unix` is not usable by `vncuser` (missing write access or sticky bit, and not `vncuser`'s to fix), `start-vnc.sh` exits non-zero before starting Xvnc, with one message naming the directory, its owner and its mode. When it is missing, it is created with mode 1777. | BEH-006 | Medium | A clear reason instead of a raw `chmod` error | N/A | DEC-001 |
| REQ-004 | After a root X server has taken the directory, the whole desktop (`tigervnc`, `xfce`, `chrome`, `copyq`, `websockify` and the other programs) reaches `RUNNING` after `docker restart`, after an abrupt kill and start, and after a Supervisor restart of Xvnc. | BEH-003, BEH-004, BEH-005 | Critical | The incident | Prototype probe and the kill/start and in-life checks (investigation) | Task direction |
| REQ-005 | The repository has a repeatable check that reproduces the takeover and proves REQ-004 against a built image in throwaway containers, and the source contract guards against an unconditional `chmod` of the directory in `start-vnc.sh`. | BEH-003, BEH-004 | High | Keep the fix from regressing | N/A | Task direction ("verify with a real Docker build and container restart test") |
| REQ-006 | Stale `:99` lock/socket recovery and the duplicate-server refusal keep working as today. | BEH-005 | High | Preserved | N/A | — |
| REQ-007 | The README documents the directory's state and a recovery command for running containers of older images; `VERSION` is `1.4.2`; release notes state that the server image picks up the fix only after a base release and a server-image digest bump and rebuild. | — | Medium | Operators' rollout | N/A | DEC-002, DEC-004, DEC-005 |

## Acceptance Criteria

| Acceptance-Criteria ID | Related Requirement IDs | Related Behavior / Scenario IDs | Preconditions / Trigger | Observable Expected Outcome | Important Alternate Or Failure Outcome | Verification Intent |
| --- | --- | --- | --- | --- | --- | --- |
| AC-001 | REQ-002, REQ-004 | BEH-001 / SCN-001 | Fresh throwaway container of the image built from the branch (default variant) | `tests/validate-running-container.sh` passes; `/tmp/.X11-unix` is `root root 1777` | — | Real `docker build` (local arm64) + throwaway container with `--cap-add SYS_ADMIN --security-opt seccomp=unconfined` |
| AC-002 | REQ-001, REQ-004 | BEH-003 / SCN-003 | Root X server (e.g. `Xvnc :102` as root) has made the dir `root:root`; `docker restart` | All programs `RUNNING` within 120 s; `validate-running-container.sh` passes; no `changing permissions of '/tmp/.X11-unix'` line in `supervisord.log` | — | Same throwaway container |
| AC-003 | REQ-001, REQ-004 | BEH-004 / SCN-004 | Takeover as in AC-002; then `vncuser`'s Xvnc `:99` is killed in the running container | Supervisor brings `tigervnc` back to `RUNNING`, and all programs are `RUNNING` within 120 s | — | Same throwaway container |
| AC-004 | REQ-001, REQ-004, REQ-006 | BEH-005 / SCN-005 | Takeover; container killed with SIGKILL (stale `:99` lock and socket left), then started | All programs `RUNNING`; `validate-running-container.sh` passes | — | Same throwaway container |
| AC-005 | REQ-003 | BEH-006 / SCN-006 | `/tmp/.X11-unix` root-owned with mode 0755 (and, separately, missing); `start-vnc.sh` run as `vncuser` | 0755: exit non-zero, one message naming the directory, owner and mode, no Xvnc started. Missing: created with mode 1777 and Xvnc starts. | — | Throwaway container, no Supervisor needed |
| AC-006 | REQ-004 | SCN-003, SCN-004 | Server-image composition: throwaway image `FROM autobyteus/autobyteus-server:beta` with the branch's `start-vnc.sh` and `entrypoint.sh` (`probe/server-overlay.Dockerfile`) | `probe/x11-takeover-restart-probe.sh` shows all running at fresh start, in-life and after restart, and 0 chmod failures | — | Throwaway container; image never pushed |
| AC-007 | REQ-005 | SCN-003, SCN-004 | The repository's new restart check run against the unfixed base `1.4.1` image (control), then the fixed image | Control: fails on the restart/in-life step; fixed: passes | — | Throwaway containers |
| AC-008 | REQ-005, REQ-006 | — | `tests/validate-source-contract.sh`, `tests/validate-image.sh` | Both pass; the source contract fails if `start-vnc.sh` changes the directory's mode without an ownership check | — | Local run |
| AC-009 | REQ-007 | SCN-007 | Docs | README section and release notes present as REQ-007 says; `VERSION` reads `1.4.2`; the README recovery command, run in a throwaway container of the unfixed image after a takeover, brings the desktop back | — | Throwaway container of the unfixed image |

## Relevant Scenarios And Journeys

| Scenario ID | Kind | Actor / Initiator / Governing Contract | Coherent Goal Or Governing Event | Supported Trigger / Entry Surface | Starting Condition | Product-Level Steps Or Event Sequence | Expected Outcome | Supported Alternate / Error Behavior | Scenario Validity | Independent Evidence / Decision Reference | Related Requirement / AC IDs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SCN-001 | Operational | Operator | Start a node | `docker run` / compose up | New container | entrypoint → Supervisor → desktop | Desktop up | — | Supported Normal Scenario | README, compose | REQ-002, REQ-004 / AC-001 |
| SCN-002 | Operational | Agent in the node (root) | Run its own X server for tests | `xvfb-run -a …` or `Xvnc :<n>` as root | Node running | X server takes the socket dir as root | Its X server runs; node desktop unaffected | — | Supported Normal Scenario | superrepo `docs/isolated-app-instances.md` root-container recipe | REQ-001 / AC-002..AC-004 |
| SCN-003 | Operational | Operator / Docker | Restart a node | `docker restart`, daemon restart, `restart: unless-stopped` | SCN-002 happened | Container restarts with `/tmp` kept | Desktop up | — | Supported Normal Scenario | Live incident 2026-11-21 | REQ-001, REQ-004 / AC-002, AC-006, AC-007 |
| SCN-004 | System | Supervisor | Recover a crashed Xvnc | `autorestart=true` | SCN-002 happened | Xvnc exits; Supervisor restarts `start-vnc.sh` | Desktop back | — | Supported Normal Scenario | `base.conf` | REQ-001, REQ-004 / AC-003, AC-006 |
| SCN-005 | Operational | Host | Abrupt stop | Power loss, daemon crash | SCN-002 happened | Kill; start | Desktop up | Live `:99` holder → refuse duplicate (preserved) | Supported Normal Scenario | README recovery section | REQ-004, REQ-006 / AC-004 |
| SCN-006 | System | Supervisor | Start Xvnc with an unusable socket dir | Any | Dir not sticky/writable and not vncuser's | start-vnc.sh checks | Clear failure | — | Supported Explicit Edge Scenario (operability: diagnosable failure) | DEC-001 | REQ-003 / AC-005 |
| SCN-007 | Operational | Operator | Recover a running node of an older image; roll out the fix | `docker exec` (root); release | Desktop FATAL after takeover | Documented command; later, release + digest bump | Desktop back; fix rolled out | — | Supported Normal Scenario | README existing recovery section pattern | REQ-007 / AC-009 |

## UI, Interaction, And Experience Requirements

- Applicable: `No`. N/A — not applicable for all Product design fields.

## Quality And Non-Functional Requirements

| Quality ID | Related Requirement / AC IDs | Area | Measurable Requirement Or Constraint | Conditions / Scope | Verification Intent |
| --- | --- | --- | --- | --- | --- |
| QR-001 | REQ-004 / AC-002..AC-004 | Reliability | All programs `RUNNING` within 120 s of the trigger | Local Docker Desktop arm64 | Restart check |
| QR-002 | REQ-002 | Security | Directory mode never wider than 1777 and sticky bit always set | All paths | AC-001, AC-005 |

## Data Continuity And Acceptable Loss

- Persisted or external data affected: `No`. Only `/tmp` in the container's writable layer; Chromium profile and data volumes untouched.

## External Contracts And Dependencies

| Contract / Dependency | Required Behavior Or Constraint | Evidence / Authority | Uncertainty Or Risk |
| --- | --- | --- | --- |
| libxtrans socket directory handling (TigerVNC Xvnc, Ubuntu 24.04) | Root X server sets owner to root; non-root X server works in a `root:root 1777` dir | Reproduced (investigation) | None |
| AutoByteus server image | Builds `FROM autobyteus/chrome-vnc@<digest>` and hands over to `/entrypoint.sh` | superrepo `Dockerfile.monorepo`, server `entrypoint.sh` | Fix reaches nodes only after release + digest bump |

## Supplemental Artifacts

| Artifact Path | Purpose | Related Requirement / AC IDs | Status | Approval Applicability / State |
| --- | --- | --- | --- | --- |
| `probe/x11-takeover-restart-probe.sh` | Reproduction and server-composition proof driver | AC-006 | Current | Evidence tool |
| `probe/server-overlay.Dockerfile` | Throwaway server-composition image | AC-006 | Current | Evidence tool |

## Assumptions

| Assumption ID | Assumption | Why It Is Necessary | Validation Plan / Owner | Status |
| --- | --- | --- | --- | --- |
| ASM-001 | The founder's nodes failed the way the throwaway reproduction fails | Live containers are off limits | Same log line, same supervisor states (Task text vs reproduction) | Confirmed by matching evidence |

## Decisions

| Decision ID | Question | Why It Matters | Options / Evidence | Reasoning And Recommendation | Decision Owner | Status |
| --- | --- | --- | --- | --- | --- | --- |
| DEC-001 | Who should own `/tmp/.X11-unix`, and what does `start-vnc.sh` do when it is not its own? | Two owners disagreeing is the root cause | (a) keep vncuser and re-chown at start; root X servers take it back mid-life, so the in-life path still fails. (b) `root:root 1777` at build and every start + launcher chmods only its own dir and otherwise checks usability. (c) Launcher uses `sudo chmod`: gives the launcher a privilege it should not need. | (b): matches the X convention every root X server enforces, so no tug-of-war, and covers both the restart and in-life paths. The check turns an unusable dir into a clear message. Recommend (b). | Solution Designer | Decided |
| DEC-002 | Version | Release tooling reads `VERSION` | Repo convention: the fix commit bumps `VERSION` (1.4.1 in `6d4aa75`) | Patch fix, `1.4.2`. Bumping the file does not publish anything. | Solution Designer | Decided |
| DEC-003 | Evidence for amd64 and the `zh` variant | Release is multi-arch, two variants | Local host arm64; zh build is slow; the change is two shell scripts and one Dockerfile line, identical across arch and variant | Accept a low bounded risk: prove on default/arm64 locally. The release build (founder-gated) builds both variants for both architectures and runs the image checks. Untested scope: amd64 and zh runtime before release. | Solution Designer | Decided |
| DEC-004 | Does the superrepo change in this ticket? | Done-when names "base branch(es)" | Server image pins the base by digest; the new digest exists only after publication | No superrepo change now. Release step after the founder's word: publish `1.4.2`/`1.4.2-zh`, then bump `system-level.json` `baseImages`, the `Dockerfile.monorepo` default and `systemInputsSha256`, rebuild and publish the server image, recreate nodes. Reported as release instructions. | Solution Designer | Decided |
| DEC-005 | How do running nodes recover before the release? | Founder's node is down now | Root `docker exec` can fix the directory's owner and restart the programs | Document `docker exec <c> sh -c 'chown vncuser:vncuser /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && supervisorctl restart tigervnc xfce chrome copyq'` (owner back to vncuser, since the old launcher needs to own it). The founder runs it himself; this team does not touch his containers. | Solution Designer | Decided |
| DEC-006 | Publish the release? | Hard to undo | — | Only on the founder's explicit word (Task direction). | User | Needs user at release time (not for these requirements) |

## Traceability

| Requirement ID | Use-Case IDs | Behavior IDs | Acceptance-Criteria IDs | Scenario IDs | Supplemental / Product Design Evidence |
| --- | --- | --- | --- | --- | --- |
| REQ-001 | UC-001, UC-002 | BEH-003, BEH-004 | AC-002, AC-003 | SCN-002..SCN-004 | probe |
| REQ-002 | UC-001 | BEH-001 | AC-001 | SCN-001 | — |
| REQ-003 | UC-003 | BEH-006 | AC-005 | SCN-006 | — |
| REQ-004 | UC-001, UC-002 | BEH-003..BEH-005 | AC-002..AC-004, AC-006 | SCN-003..SCN-005 | probe |
| REQ-005 | UC-001, UC-002 | BEH-003, BEH-004 | AC-007, AC-008 | SCN-003, SCN-004 | — |
| REQ-006 | UC-001 | BEH-005 | AC-004, AC-008 | SCN-005 | — |
| REQ-007 | UC-004 | — | AC-009 | SCN-007 | — |

## Architecture Phase Input

- Approved scenario IDs: SCN-001..SCN-007.
- Constraints: throwaway containers only, never `autobyteus-server-0/1/2`; no push; Chromium needs `--cap-add SYS_ADMIN --security-opt seccomp=unconfined` in tests.
- Deferred to design: where the restart check lives and how it reuses `validate-running-container.sh`.
- Technical facts verified: takeover by a root X server; EPERM path; prototype fix works in both paths and after kill/start.
- Known risks: RSK-001, RSK-002 (DEC-003).

## Readiness Check

### Content Ready For Approval

- Relevant current behavior is evidence-backed: `Yes`
- Desired and preserved behavior are explicit: `Yes`
- Scope and non-goals are clear: `Yes`
- Requirements and acceptance criteria are testable and traceable: `Yes`
- Applicable scenarios are covered with validity and evidence: `Yes`
- Product design and supplemental evidence is integrated consistently: `N/A`
- Applicable UI/UX approval and final visual-reference basis are recorded: `N/A`
- Material assumptions and decisions are visible, each decision with reasoning and recommendation: `Yes`
- Content ready for approval: `Yes`
- Remaining content blocker: None

### Approved Basis Ready For Design

- Approval recorded: `Yes` (Solution Designer within the direction; user informed 2026-11-21)
- Exact requirements and supplement approval basis recorded: `Yes`
- Approved requirements package ready for architecture design: `Yes`
- Remaining blocker: None
