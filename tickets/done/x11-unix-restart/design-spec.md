# Design Spec

## Solution And Approval Basis

- Current solution revision ID: `SR-001`
- Approved requirements baseline / revision, who approved, and approval reference: `requirements-doc.md` at `SR-001`, approved by the Solution Designer within the Task direction, user informed in the Solution Designer conversation on 2026-11-21
- Behavior-defining supplements and their approval references: None
- User approval of the design, when the direction requires it: `Not required`
- Design status: `Ready`
- Canonical investigation-notes path: `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart/tickets/in-progress/x11-unix-restart/investigation-notes.md`
- Authorities read (design reading gate; 2026-11-21): `references/architecture-design.md`, `references/design-principles.md`; project `DESIGN.md`: `Created: /Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart/DESIGN.md` (the repository had none); no `AGENTS.md` in the repository, so no pointer line is added
- Project design-principle conflicts or discrepancies: None

## Current-State Read

The node desktop is one container-start lifecycle owned by this image (investigation notes, Architecture Investigation Findings):

`docker start/restart` → `/entrypoint.sh` (root; the AutoByteus server image's entrypoint hands over to it) → `exec supervisord` (PID 1) → `[program:tigervnc]` runs `start-vnc.sh` as `vncuser` (and again on every Supervisor restart) → `exec Xvnc :99` → XFCE, Chromium, CopyQ and websockify connect to `:99`.

The X socket directory `/tmp/.X11-unix` has two owners that disagree:
- `Dockerfile` L184-189 builds it `vncuser`-owned.
- Any root X server in the node makes it `root:root` (reproduced). `start-vnc.sh` L9-10 then insists on changing its mode, which only the owner may do. The mode is already 1777, so the change is unnecessary.
- `entrypoint.sh` L94-97 clears the stale `:99` lock and socket but never sets the directory's state.

Both the restart path (BEH-003) and the in-life Supervisor restart path (BEH-004) fail at the same `chmod`.

## Task Size And Architectural Risk (Mandatory)

- Task size: `Small`
- Size rationale and supporting evidence: three image files change by a few lines each: `start-vnc.sh` (one block), `entrypoint.sh` (one block) and `Dockerfile` (one line removed). Plus one new test script, small additions to two existing test scripts, a README section, `VERSION`, and the new project `DESIGN.md`. All within the existing owners. Prototype of the image change: investigation notes, Runtime findings.
- Architectural risk: `Low`
- Risk rationale and supporting evidence:
  - The design keeps the same programs, users, ports, Supervisor graph and server-image interface, and adds no persistence or new contract.
  - The directory's mode stays 1777. Only its owner changes, to the X convention that root X servers already produce.
  - Deployment mechanics are unchanged: same build and release scripts, gated release.
  - Uncertainty is closed by reproduction. The prototype recovers in-life, after restart and after kill/start; the unfixed image fails the same probe.
- Escalation trigger if implementation or validation discovers new impact:
  - any program other than tigervnc needs a change;
  - the server image source needs a change;
  - root ownership breaks a non-root X client;
  - the fix depends on Docker run flags beyond those `run-container.sh` uses.
  Any of these returns a `Design Impact` to the Solution Designer.

## Architecture Investigation Evidence

| Source / Command / Probe | Exact Path / Reference | Observation | Design Decision Supported | Remaining Uncertainty |
| --- | --- | --- | --- | --- |
| Code | `start-vnc.sh` L9-10 | Unconditional `chmod 1777 /tmp/.X11-unix` as vncuser under `set -euo pipefail` | Launcher chmods only its own directory and checks usability | None |
| Code | `entrypoint.sh` L1-2 (`set -eo pipefail`), L94-97 | Root start step; clears `:99` artifacts only | Entrypoint sets the directory state at every start | None |
| Code | `Dockerfile` L184-189 | `chown -R ${USER_UID}:${USER_GID} /tmp/.X11-unix` | Build the same state as start (`root:root 1777`) | None |
| Code | superrepo `Dockerfile.monorepo` L73, server `entrypoint.sh` (hands over to `/entrypoint.sh`) | Server image inherits both scripts unchanged | No superrepo change (DEC-004) | None |
| Probe | `probe/x11-takeover-restart-probe.sh` on beta (control) and prototype overlay | Control fails in-life and after restart; prototype passes both, plus kill/start | Both changes are needed, and they suffice | None |
| Code | `tests/validate-running-container.sh` | Full runtime check of one running container | New restart check reuses it after each recovery step | None |

## Intended Change

Make `root:root 1777` the one defined state of `/tmp/.X11-unix`, established by root at build time and at every container start. Make `start-vnc.sh` change the directory's mode only when it owns it, and otherwise check it is usable and fail with a clear message. Add a durable restart/takeover check, source and image assertions, the README recovery note and `VERSION` 1.4.2.

## Change Scope (Mandatory)

- In scope: UC-001..UC-004. Areas: the image's X startup (`entrypoint.sh`, `start-vnc.sh`, `Dockerfile` X11 line), its validation scripts (`tests/`), README recovery section, `VERSION`, and the new root `DESIGN.md`.
- Derived consumers: `N/A`. No stored or shared structure changes. The server image consumes `/entrypoint.sh` and `start-vnc.sh` unchanged in interface.
- Deliberately left alone:
  - `base.conf` and the other programs;
  - the `:99` stale lock/socket logic in both scripts (BEH-005 preserved; REQ-006);
  - other displays' leftover locks/sockets (harmless, investigation notes);
  - Chromium flags;
  - the superrepo (DEC-004);
  - `/dev/shm` setup on the same Dockerfile line (unchanged).
- Follow-ups: FU-001 (`depends_on` in `base.conf` is not a Supervisor option).

## Relevant Behavior And Production-Path Map (Mandatory)

| Behavior ID | Kind | Approved Requirement / Intent And Acceptance-Criteria IDs | Approved Trigger Or Governing Contract | Relevant Existing Behavior And Evidence Reference | Approved Change Or Preserved Outcome | Target Production Path / Lifecycle And Spine ID(s) |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | REQ-002, REQ-004 / AC-001 | Container start | All up; dir vncuser-owned | All up; dir `root:root 1777` | DS-001 |
| BEH-002 | Operational | REQ-001 / AC-002..AC-004 | Root X server in the node | Takes dir as root | Preserved; now a no-op on ownership | — (outside the image's path) |
| BEH-003 | Operational | REQ-001, REQ-004 / AC-002, AC-006, AC-007 | Container restart after takeover | tigervnc FATAL chain | All up | DS-001 |
| BEH-004 | Operational | REQ-001, REQ-004 / AC-003, AC-006, AC-007 | Supervisor restarts Xvnc after takeover | tigervnc BACKOFF | All up | DS-002 |
| BEH-005 | Operational | REQ-006 / AC-004 | Abrupt stop | `:99` artifacts cleared | Preserved, also after takeover | DS-001 |
| BEH-006 | Operational | REQ-003 / AC-005 | Unusable dir | raw chmod error | Clear message, exit non-zero | DS-002 |

## Relevant Supplemental Task Artifacts

| Artifact Path | Purpose | Related Requirement / Acceptance-Criteria IDs | Relationship To This Design | Status / Approval Applicability |
| --- | --- | --- | --- | --- |
| `probe/x11-takeover-restart-probe.sh` | Reproduction; server-composition proof driver | AC-006 | The fix must turn it green on the overlay image | Evidence tool |
| `probe/server-overlay.Dockerfile` | Throwaway server-composition image | AC-006 | Used with the probe | Evidence tool |

## Task Design Health Assessment (Mandatory)

- Change posture: `Bug Fix`
- Current design issue found: `Yes`
- Structural triggers that fire:
  - **Several kinds or forms** (Principle 1): the launcher serves two entry forms, container start and in-life Supervisor restart. Both are traced (DS-001, DS-002) and both are covered by the launcher change; the entrypoint change covers only the first, by design.
  - Ruled out:
    - Repeated coordination: the directory state is set by one owner per lifecycle step. The entrypoint sets it; the launcher only checks it.
    - Empty indirection: no new layer.
    - Behavior by absence: the launcher's failure is an explicit check with its own message, not a fallback.
    - Legacy cleanup: the old unconditional chmod is removed, not kept beside the new path.
- Deliberate deviations from a principle: None
- Root cause classification: `Missing Invariant`. The image owns the X socket directory but never defines its state, and the launcher enforces a stricter rule (ownership) than it needs (usability).
- Refactor needed now: `No`
- Evidence: the owners are right. The root entrypoint owns container-start state and the vncuser launcher owns Xvnc's launch; only the rule is missing or wrong (investigation notes).
- Design response: the entrypoint defines and sets the invariant (`root:root 1777`) at every start; the build sets the same state; the launcher checks the invariant's essential part (writable + sticky) and changes the mode only when it owns the directory.
- Refactor rationale: no structural change needed; files stay well under size limits.
- Intentional deferrals and residual risk: FU-001 only.

## Terminology

- **X socket directory**: `/tmp/.X11-unix`. **Takeover**: a root X server changing its owner to root. **In-life restart**: Supervisor restarting `tigervnc` without a container restart. No project glossary found.

## Legacy Removal Policy (Mandatory)

- Obsolete legacy paths and files in this scope: the unconditional `chmod 1777 /tmp/.X11-unix` in `start-vnc.sh`; the `chown` of `/tmp/.X11-unix` to vncuser in `Dockerfile`.
- Compatibility wrappers, dual paths, or legacy fallbacks this design keeps: `None`

## Persisted Data / State Transition Decision

- Decision: `Not Affected`. Only `/tmp` in the container's writable layer changes; the entrypoint normalizes whatever an existing container left there at its next start, so upgraded and new containers converge with no migration.

## Data-Flow Spine Inventory

| Spine ID | Scope | Related Behavior ID(s) | Start | End | Governing Owner | Why It Matters |
| --- | --- | --- | --- | --- | --- | --- |
| DS-001 | Primary End-to-End | BEH-001, BEH-003, BEH-005 | Container start/restart | Desktop programs `RUNNING` | `entrypoint.sh` → Supervisor | Restart path of the incident |
| DS-002 | Primary End-to-End | BEH-004, BEH-006 | Supervisor (re)starts `tigervnc` | `Xvnc :99` listening, dependants reconnect | `start-vnc.sh` | In-life path; the launcher must not depend on the entrypoint having run recently |

## Primary Execution Spine(s)

- DS-001: `docker start/restart → server entrypoint (server image only) → /entrypoint.sh: set X socket directory root:root 1777, clear stale :99 lock/socket → supervisord → start-vnc.sh → Xvnc :99 → XFCE / Chromium / CopyQ / websockify`
- DS-002: `Xvnc exits → supervisord autorestart → start-vnc.sh: check X socket directory, stale :99 check → Xvnc :99 → dependants restarted by Supervisor`

## Spine Narratives (Mandatory)

| Spine ID | Short Narrative | Main Domain Subject Nodes | Governing Owner | Key Off-Spine Concerns |
| --- | --- | --- | --- | --- |
| DS-001 | At every container start, root puts the X socket directory into its defined state before anything else uses it, then Supervisor starts the desktop. Whatever a previous life left (a takeover, an abrupt stop) is gone at this point. | X socket directory, `:99` lock/socket | `entrypoint.sh` | None |
| DS-002 | When Xvnc restarts in a running container, the directory may have been taken over since the start. The launcher does only what vncuser may do: create the directory if it is missing, fix the mode if it owns it, and otherwise check it is writable and sticky. Then it starts Xvnc. | X socket directory | `start-vnc.sh` | Clear failure message (BEH-006) |

## Spine Actors / Main-Line Nodes

`/entrypoint.sh`, `supervisord`, `start-vnc.sh`, `Xvnc :99`.

## Ownership Map

- `entrypoint.sh` (root): owns the X socket directory's container-start state (new invariant) and the stale `:99` cleanup (existing).
- `start-vnc.sh` (vncuser): owns launching `Xvnc :99`. It checks that the directory is usable and never changes anything it does not own.
- `Dockerfile`: owns the built state, which equals the container-start state.
- `tests/validate-restart-recovery.sh` (new): owns proving DS-001/DS-002 recovery after a takeover against a running throwaway container. It reuses `validate-running-container.sh` for the full runtime check.

## Thin Entry Facades / Public Wrappers (If Applicable)

N/A. The server image's entrypoint is an existing hand-over and is unchanged.

## Removal / Decommission Plan (Mandatory)

| Item To Remove / Decommission | Why It Becomes Unnecessary | Replaced By Which Owner / File / Structure | Notes |
| --- | --- | --- | --- |
| `chmod 1777 /tmp/.X11-unix` (unconditional) in `start-vnc.sh` L10 | Wrong rule; root cause | Owned-only chmod + usability check in `start-vnc.sh` | — |
| `chown -R ${USER_UID}:${USER_GID} /tmp/.X11-unix` in `Dockerfile` L189 | Conflicts with the defined `root:root` state | Built as root (default) + entrypoint invariant | Keep the `/dev/shm` lines |

## Return Or Event Spine(s) (If Applicable)

N/A.

## Bounded Local / Internal Spines (If Applicable)

`start-vnc.sh` directory check: `missing → mkdir -m 1777` → `owned → chmod 1777` → `not writable or not sticky → message, exit 1` → existing stale `:99` check → `exec Xvnc`.

## Off-Spine Concerns Around The Spine

| Off-Spine Concern | Related Spine ID(s) | Serves Which Owner | Responsibility | Why It Exists | Risk If Misplaced On Main Line |
| --- | --- | --- | --- | --- | --- |
| Restart/takeover validation | DS-001, DS-002 | Image maintainers | Prove recovery on a built image | REQ-005 | — |

## Ownership Boundaries

The base image owns the whole desktop stack, including the X socket directory. The server image only adds its program and hands over to `/entrypoint.sh`. Agents' root X servers are outside the image and are tolerated, not controlled.

## Boundary Encapsulation Map

| Authoritative Boundary | Internal Owned Mechanism(s) It Encapsulates | Upstream Callers That Must Use The Boundary | Forbidden Bypass Shape | If Boundary API Is Too Thin, Fix By |
| --- | --- | --- | --- | --- |
| `/entrypoint.sh` | Container-start runtime state | Server image entrypoint (`exec /entrypoint.sh`) | Downstream images re-implementing X setup | Extend `entrypoint.sh` here |

## Dependency Rules

- `start-vnc.sh` must not assume the entrypoint ran since the last takeover (DS-002); it must not use `sudo`.
- Tests: `validate-restart-recovery.sh` may call `validate-running-container.sh`; not the reverse.
- Process-wide bindings, registries, singletons: `None`.

## Interface Boundary Mapping

| Interface / API / Query / Command / Method | Subject Owned | Responsibility | Accepted Identity Shape(s) | Notes |
| --- | --- | --- | --- | --- |
| `tests/validate-restart-recovery.sh CONTAINER [default|zh] [EXPECTED_UID]` | One throwaway running container | Takeover + in-life + restart + kill/start recovery | Container name; must carry label `chrome-vnc.test=throwaway` | Same argument shape as `validate-running-container.sh`, which it calls |

## Interface Boundary Check

| Interface | Responsibility Is Singular? | Identity Shape Is Explicit? | Ambiguous Selector Risk | Corrective Action |
| --- | --- | --- | --- | --- |
| `validate-restart-recovery.sh` | Yes | Yes | Low | Label guard refuses non-throwaway containers |

## Main Domain Subject Naming Check

| Node / Subject | Current / Proposed Name | Name Is Natural And Self-Descriptive? | Same Meaning And Name Everywhere? | Naming Drift Risk | Corrective Action |
| --- | --- | --- | --- | --- | --- |
| Restart check | `tests/validate-restart-recovery.sh` | Yes | Yes (`validate-*` family) | Low | — |
| Directory variable | `x11_dir` in `start-vnc.sh` | Yes | Yes | Low | — |

## Existing Capability / Subsystem Reuse Check

| Need / Concern | Existing Capability Area / Subsystem | Decision | Why | If New, Why Existing Areas Are Not Right |
| --- | --- | --- | --- | --- |
| Container-start state | `entrypoint.sh` | Extend | Already does the stale X cleanup as root | — |
| Runtime validation | `tests/validate-running-container.sh` | Reuse | Full runtime check after each recovery step | — |
| Restart/takeover driving | none | Create New | `validate-running-container.sh` deliberately checks one running container without restarting it; restarting and killing is a different responsibility | — |
| Built-image check of the launcher | `tests/validate-image.sh` | Extend | Runs the image without Supervisor, as AC-005 needs | — |

## Subsystem / Capability-Area Allocation

| Subsystem / Capability Area | Owns Which Concerns | Related Spine ID(s) | Governing Owner(s) Served | Decision | Notes |
| --- | --- | --- | --- | --- | --- |
| Image startup scripts | Directory state, Xvnc launch | DS-001, DS-002 | `entrypoint.sh`, `start-vnc.sh` | Extend | — |
| Validation scripts | Source, image, runtime, restart checks | — | Maintainers | Extend + one new file | — |

## Draft File Responsibility Mapping

See Final File Responsibility Mapping (the draft did not change).

## Reusable Owned Structures Check

N/A. Nothing is repeated. The directory path appears once per script, with its own role in each.

## Shared Structure / Data Model Tightness Check

N/A.

## Final File Responsibility Mapping

| File | Owning Subsystem / Capability Area | Owner / Boundary | Concrete Concern | Why This Is One File | Reuses Shared Structure? |
| --- | --- | --- | --- | --- | --- |
| `entrypoint.sh` | Startup | Root start step | + X socket directory invariant | Existing owner | — |
| `start-vnc.sh` | Startup | Xvnc launcher | Directory check replaces chmod | Existing owner | — |
| `Dockerfile` | Build | Image | Built directory state | Existing | — |
| `tests/validate-restart-recovery.sh` | Validation | Restart check | Takeover/in-life/restart/kill-start | One responsibility | Calls `validate-running-container.sh` |
| `tests/validate-image.sh` | Validation | Image check | + dir state; + AC-005 launcher checks | Existing owner | — |
| `tests/validate-source-contract.sh` | Validation | Source contract | + assertions (below) | Existing owner | — |
| `README.md` | Docs | — | Recovery section | Existing | — |
| `VERSION` | Release | — | `1.4.2` | — | — |
| `DESIGN.md` (new) | Docs | Project | Project design rules | Project document | — |

## Applied Patterns (If Any)

None.

## Target Subsystem / Folder / File Mapping

| Path | Kind | Owner / Boundary | Responsibility | Why It Belongs Here | Must Not Contain |
| --- | --- | --- | --- | --- | --- |
| `entrypoint.sh` | File | Root start | Before the stale `:99` cleanup, add one block under a comment that explains the invariant: `mkdir -p /tmp/.X11-unix`, `chown root:root /tmp/.X11-unix`, `chmod 1777 /tmp/.X11-unix` | Runs as root at every start, before Supervisor | Removal of other displays' artifacts |
| `start-vnc.sh` | File | Launcher | Replace L9-10 with the check shown in Examples | Runs on every Xvnc (re)start | `sudo`, chown, an unconditional chmod |
| `Dockerfile` L184-189 | File | Build | Drop `chown -R … /tmp/.X11-unix` (and its trailing `&& \` join); keep mkdir/chmod 1777 of `/tmp/.X11-unix` and `/dev/shm` | Build runs as root, so the owner is root | — |
| `tests/validate-restart-recovery.sh` | File (new) | Restart check | Usage like `validate-running-container.sh`. Refuse a container without label `chrome-vnc.test=throwaway`. Steps: (1) assert dir `root root 1777`; (2) takeover: `docker exec` a root `Xvnc :150 -SecurityTypes=None -rfbport 5950` in the background, wait for `/tmp/.X11-unix/X150`, assert dir `root:root`; (3) in-life: `pkill -u vncuser -x Xvnc`, wait for `tigervnc` `RUNNING` with a new PID, then run `validate-running-container.sh`; (4) takeover again, `docker restart`, run `validate-running-container.sh`, assert dir `root root 1777` and no `changing permissions of '/tmp/.X11-unix'` line in `/var/log/supervisor/supervisord.log`; (5) takeover again, `docker kill -s KILL`, `docker start`, run `validate-running-container.sh`. Print `PASS: …` at the end; `FAIL: <step>` and exit 1 otherwise. | Restart/kill is a different responsibility than the single-life runtime check | Container creation (the caller creates the throwaway container, as for the existing scripts) |
| `tests/validate-image.sh` | File | Image check | Assert `/tmp/.X11-unix` is `root root 1777` in the built image. AC-005: with the dir `chmod 0755` (root), `su -s /bin/bash vncuser -c /usr/local/bin/start-vnc.sh` exits non-zero, prints the directory/owner/mode message and starts no Xvnc. With the dir removed, the launcher (backgrounded) creates it with mode 1777 and Xvnc `:99` appears; stop it after. | Image-level, no Supervisor | — |
| `tests/validate-source-contract.sh` | File | Source contract | `start-vnc.sh` has no line matching `^chmod 1777 /tmp/\.X11-unix` and contains an `-O` ownership test on the directory variable; `entrypoint.sh` contains `chown root:root /tmp/.X11-unix` and `chmod 1777 /tmp/.X11-unix`; `Dockerfile` has no `chown` of `/tmp/.X11-unix`; README mentions `/tmp/.X11-unix` in the recovery section | Guards REQ-005 | — |
| `README.md` "Reliable Recovery After Host/Daemon Restart" | File | Docs | Add: the X socket directory is kept `root:root 1777` and a root X server in the container no longer stops the desktop. For running containers of images before `1.4.2`: `docker exec <container> sh -c 'chown vncuser:vncuser /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && supervisorctl restart tigervnc xfce chrome copyq'` (tested, investigation notes). Point to the new restart check in the testing notes if README lists the tests. | Existing section | — |
| `VERSION` | File | Release | `1.4.2` | Repo convention (DEC-002) | — |
| `DESIGN.md` | File (new) | Project | Created by the Solution Designer in this ticket | Project document | Ticket history |

## Folder Boundary Check

| Path / Folder | Intended Structural Depth | Ownership Boundary Is Clear? | Mixed-Layer Or Over-Split Risk | Justification / Corrective Action |
| --- | --- | --- | --- | --- |
| repo root scripts, `tests/` | Mixed Justified (existing flat layout) | Yes | Low | Existing layout kept |

## Concrete Examples / Shape Guidance (Mandatory When Needed)

| Topic | Good Example | Bad / Avoided Shape | Why The Example Matters |
| --- | --- | --- | --- |
| Launcher check | see block below | `chmod 1777 /tmp/.X11-unix` unconditionally; `sudo chmod …`; `chmod … \|\| true` (hides a truly unusable directory) | Only what vncuser may do, plus a clear reason |

```bash
x11_dir="/tmp/.X11-unix"
# The entrypoint keeps this directory root:root 1777, and any root X server in the
# container takes it over as root, so change its mode only when we own it.
if [ ! -d "$x11_dir" ]; then
  mkdir -m 1777 "$x11_dir"
fi
if [ -O "$x11_dir" ]; then
  chmod 1777 "$x11_dir"
fi
if [ ! -w "$x11_dir" ] || [ ! -k "$x11_dir" ]; then
  echo "$x11_dir must be a world-writable sticky directory (mode 1777); found owner $(stat -c '%U:%G' "$x11_dir"), mode $(stat -c '%a' "$x11_dir")." >&2
  exit 1
fi
```

Keep the existing `socket_file` and `lock_file` variables; the socket path may use `$x11_dir`.

## Backward-Compatibility Rejection Log (Mandatory)

| Candidate Compatibility Mechanism | Why It Was Considered | Rejection Decision | Clean-Cut Replacement / Removal Plan |
| --- | --- | --- | --- |
| Keep vncuser ownership and re-chown to vncuser at start | Smallest diff from today | Rejected | Root X servers take it back mid-life (BEH-004); `root:root 1777` instead |
| `chmod … \|\| true` in the launcher | One-line hack | Rejected | Explicit usability check (REQ-003) |

## Derived Layering (If Useful)

N/A.

## Change / Refactor Sequence

1. `start-vnc.sh` check; `entrypoint.sh` invariant; `Dockerfile` line.
2. `tests/validate-source-contract.sh` and `tests/validate-image.sh` additions; new `tests/validate-restart-recovery.sh`.
3. README section; `VERSION` 1.4.2.
4. Build the default image locally (`docker build` / `./build-multi-arch.sh` local load, no `--push`), run source, image, running-container and restart checks in throwaway containers (`--cap-add SYS_ADMIN --security-opt seccomp=unconfined`, label `chrome-vnc.test=throwaway`). Run the restart check against the unfixed base `1.4.1` (`autobyteus/chrome-vnc@sha256:b2fde77f…96f4`, pulled locally) as the control (AC-007). Run the probe with `probe/server-overlay.Dockerfile` (AC-006).

## Key Tradeoffs

- Root ownership vs vncuser ownership: root follows the X convention, and root X servers enforce it anyway (DEC-001).
- A new restart script vs extending `validate-running-container.sh`: restarting and killing a container is a separate, destructive responsibility, so it gets its own guarded script.

## Risks

- RSK-001/RSK-002 (amd64, zh not run locally): accepted per DEC-003; release builds both.
- The label guard means the old `validate-running-container.sh` callers are unaffected; the new script refuses unlabelled containers by design.

## Guidance For Implementation

- Reproduction to start from: `tickets/in-progress/x11-unix-restart/probe/x11-takeover-restart-probe.sh IMAGE NAME`. The unfixed image fails it; the fix must turn it green (all running in-life and after restart, 0 chmod failures). The new `tests/validate-restart-recovery.sh` is its durable form.
- Never touch `autobyteus-server-0/1/2`. Never push. Remove throwaway containers and images when done (list them in the handoff).
- The repository has no `TESTING.md` or `RELEASE.md`. Per the team's project-documents rule, API/E2E creates `TESTING.md` and delivery creates `RELEASE.md` in this ticket.
