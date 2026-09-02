# Design Spec

## Document Meta

- Ticket: `BRD-UBUNTU24-001`
- Worktree: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base`
- Branch / current starting revision: `requirements/ubuntu-24-minimal-base` / `cc30abff0769553c84fb1ebb453c28e6123f4218`
- Requirements basis: `requirements-doc.md` (`RER-007`, approved revised)
- Solution revision: `solution-revision-record.md` (`SR-002`)
- Status: `Ready for architecture re-review after ARCH-F-001 correction`

## Current-State Read

The current integrated candidate is structurally coherent for the superseded RER-006 target: `Dockerfile` starts from `ubuntu:24.04`, installs Noble Python 3.12 and distribution Supervisor, uses a Python 3.12 `/opt/browser-tools` virtual environment for websockify/`uv`, exposes stable websockify assets, preserves configured identity and dynamic XDG/DBus paths, and incorporates current main's `gh` and `start-chrome.sh` behavior. `build-multi-arch.sh` continues to own platform/variant/tag/load/push orchestration. `entrypoint.sh` continues to own runtime preparation and the final Supervisor exec. `base.conf` owns the service graph.

Current `origin/main` independently proved Python 3.13 from Deadsnakes on Ubuntu 22.04 and later fixed the Python 3.13 Supervisor crash by pip-installing Supervisor 4.3.0 and launching `/usr/local/bin/supervisord`. It also published 1.3.7/1.3.8 default and `zh` manifests for AMD64/ARM64. That evidence justifies the compatible Supervisor version and public launch boundary, but its global pip plus `/usr/bin/python3` `update-alternatives` shape should not be copied into Noble: Canonical treats Noble's `/usr/bin/python3` as distribution-owned, and the main shape would mix OS and application tool ownership.

The user has superseded Python 3.12 with Python 3.13. The current candidate therefore cannot advance. The design must combine the ticket's Ubuntu 24.04/configured-identity/stable-path work with main's proven Python 3.13/Supervisor compatibility behavior without creating two Python owners, two Supervisor providers, a global-pip mutation, or a version-coupled public web asset path.

## Intended Change

- Retain Canonical `ubuntu:24.04`, release `1.4.0`, all current variants, architectures, tools, runtime/service behavior, build flags, tag behavior, and publication sequencing.
- Re-add the stable Deadsnakes PPA for Noble and install `python3.13`, `python3.13-dev`, and `python3.13-venv` for AMD64/ARM64.
- Keep Noble's `/usr/bin/python3` distribution-owned; expose Python 3.13 as the image's public `python3` and `python` commands through `/usr/local/bin` symlinks to `/usr/bin/python3.13`.
- Rebuild `/opt/browser-tools` with `/usr/bin/python3.13`; install `supervisor==4.3.0`, websockify, and `uv` there.
- Remove distribution Supervisor from the explicit apt payload and expose both `supervisord` and `supervisorctl` from `/opt/browser-tools` through `/usr/local/bin`.
- Change `entrypoint.sh` to exec `/usr/local/bin/supervisord`; retain the existing Supervisor configuration and stable `/usr/local/share/websockify` asset boundary.
- Update README and downstream durable validation assumptions to Python 3.13/Supervisor 4.3.0 while preserving all other contracts. Align the active deferred server-adoption intake brief to the same published identity without authorizing server source changes.

## Relevant Behavior And Production-Path Map (Mandatory)

| Behavior ID | Kind | Approved Requirement / Intent And AC IDs | Approved Trigger Or Governing Contract | Relevant Existing Behavior And Evidence | Approved Change Or Preserved Outcome | Target Production Path / Lifecycle And Spine ID(s) |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | REQ-001–REQ-003, REQ-005, REQ-008; AC-001–AC-004, AC-011 | Maintainer invokes supported build/load/push flow. | Integrated `cc30abf` already preserves Noble, 1.4.0, variants, platforms, tags; current payload still selects Python 3.12. | Retain the entire build/release contract while composing Python 3.13 and its isolated tools on both architectures. | CLI -> Build Contract -> BuildX -> Dockerfile Composition -> OCI image/index -> local daemon or registry (`DS-001`, `DS-003`, `DS-004`). |
| BEH-002 | System | REQ-004–REQ-005, REQ-007; AC-005–AC-008, AC-010, AC-013 | Container starts through supported entrypoint/run/Compose surfaces. | Candidate uses distribution Supervisor/Python 3.12; main proves Supervisor 4.3.0 fixes Python 3.13 crash; Noble ARM64 probe proves separated public/distro interpreters and venv tools. | Public Python is 3.13; compatible isolated Supervisor owns the unchanged service graph; configured identity, XDG/DBus, Chrome/VNC/websockify/DevTools, zh, mobile-safe, and profile/recovery outcomes remain unchanged. | Docker runtime -> entrypoint -> isolated Supervisor -> service graph -> browser/VNC/debugging/profile outcomes (`DS-002`, `DS-005`). |
| BEH-003 | Contract | REQ-006, REQ-009; AC-009, AC-011–AC-012 | User reads README/image identity or activates the approved SCN-005 follow-up after publication. | Current README reports Ubuntu 24.04/Python 3.12, and SR-001 initially overlooked the same stale Python 3.12 statement in the active deferred server-adoption brief. | README, image identity, and the later-ticket intake consistently identify Ubuntu 24.04, public Python 3.13, Supervisor 4.3.0, and verified 1.4.0 default/zh artifacts; the brief stays deferred, separate, and non-authorizing. | Source docs/image metadata -> maintainer/user observation; verified publication identity -> later-ticket intake (`DS-003`, `DS-006`). |

## Relevant Supplemental Task Artifacts

| Artifact Path | Purpose | Related Requirement / AC IDs | Relationship To This Design | Status / Approval Applicability |
| --- | --- | --- | --- | --- |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` | Requirement history through RER-007. | All | Establishes the superseding user decision and revoked direct route. | Current; approved behavior. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | Separate server-ticket boundary and later intake identity. | REQ-007–REQ-009; AC-011–AC-013 | Carries the verified Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 identity from SCN-005 without modifying downstream source in this ticket. | Current — corrected in SR-002; sequencing approved; deferred/non-authorizing. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-probe.log` | ARM64 Noble feasibility of public Python 3.13 plus isolated Supervisor/websockify/uv. | REQ-007; AC-006, AC-010, AC-013 | Proves the proposed interpreter/tool ownership shape is feasible. | Evidence only; approval N/A. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-amd64-availability.log` | AMD64 Noble package candidates. | REQ-003, REQ-007; AC-004, AC-010 | Supports target-platform feasibility; full image execution remains downstream. | Evidence only; approval N/A. |

## Task Design Health Assessment (Mandatory)

- Change posture: `Behavior Change` with a bounded runtime-provider refactor after downstream requirement re-entry.
- Current design issue found: `Yes` in the prospective merged target, not as an unrelated defect in `cc30abf`.
- Root cause classification: `Boundary Or Ownership Issue` plus `Legacy Or Compatibility Pressure`.
- Refactor needed now: `Yes`.
- Evidence: the superseding Python target crosses the Dockerfile's interpreter and pip ownership, `entrypoint.sh`'s Supervisor provider, `base.conf`'s web asset consumption, and tests' runtime identity. Main's Python 3.13 path globally mutates `/usr/bin/python3`; the ticket's Noble path isolates tools but selects obsolete 3.12 and distribution Supervisor.
- Design response: make Noble `/usr/bin/python3` the OS-owned internal interpreter, `/usr/local/bin/python3` and `/usr/local/bin/python` thin public selectors for 3.13, and `/opt/browser-tools` the sole owner of Python-installed operational services/tools. Make `/usr/local/bin/supervisord` the single runtime supervisor entrypoint.
- Refactor rationale: this clean cut is required to satisfy Python 3.13 without a mixed or brittle hybrid. It reuses existing files and boundaries; no new application subsystem is needed.
- Intentional deferrals and residual risk: websockify/`uv` remain unpinned as in current behavior, so remote package mutability remains a validation/release risk. Server tag adoption remains a separate ticket. No in-scope behavior depends on a known-bad boundary after this change.

## Terminology

- **OS-owned Python**: `/usr/bin/python3` and Ubuntu modules required by Noble packages.
- **Public developer Python**: shell-resolved `python3`/`python`, intentionally selected at `/usr/local/bin` and required to report 3.13.
- **Operational tools environment**: `/opt/browser-tools`, rooted in `/usr/bin/python3.13`, containing Supervisor 4.3.0, websockify, and `uv`.
- **Stable asset boundary**: `/usr/local/share/websockify`, a version-independent symlink computed from the installed websockify module at build time.

## Design Reading Order

Follow current state and behavior first; then the removal and interpreter/tool ownership decision; then build/runtime/release spines; finally the file changes and validation matrix. This is a compact operational repository, so the existing flat root layout is retained where each file already has a singular responsibility.

## Legacy Removal Policy (Mandatory)

- Policy: `No backward compatibility; remove legacy code paths.`
- Required removals: stale Python 3.12 developer-package/install assertions; explicit apt distribution Supervisor provider; `/usr/bin/supervisord` runtime exec; any global pip install against selected/system Python; any `/usr/bin/python3` `update-alternatives` replacement; any version-specific public websockify asset path; stale tests/docs/follow-up intake text that prohibit Deadsnakes or require public Python 3.12.
- No fallback between `/usr/local/bin/supervisord` and `/usr/bin/supervisord` is allowed.
- No dual public Python version is retained: public commands select 3.13; OS scripts can continue to call the explicit distribution path they own.

## Persisted Data / State Transition Decision (Mandatory)

- Stored subject, location, representative shape, and approximate volume: user Chromium profile at `/home/vncuser/.config/chromium`; arbitrary browser-managed files; user-dependent volume.
- Relevant code-model, serialization, semantic, or physical-store change: none.
- Normal reader/writer behavior and representative evidence: Chromium reads/writes the profile; entrypoint removes only supported stale lock artifacts; Docker preserves the mounted volume across recreation.
- Required semantics and invariants under direct use: same profile state survives container recreation and stale-lock recovery remains effective.
- Physical-store, privacy/security, disposal/rebuild, and operational constraints: profile state must not be silently discarded; disposable image layers/test containers may be rebuilt.
- Decision: `Not Affected`.
- Decision rationale: interpreter and operational-tool provider changes do not transform stored profile data. A migration would add risk without benefit.
- Acceptance criteria or design constraints supported: AC-008 and the preserved runtime lifecycle in AC-005/AC-013.

### Migration Plan

N/A — no migration is required.

## Data-Flow Spine Inventory

| Spine ID | Scope | Related Behavior IDs | Start | End | Governing Owner | Why It Matters |
| --- | --- | --- | --- | --- | --- | --- |
| DS-001 | Primary End-to-End | BEH-001 | Maintainer build CLI | Loaded local image | `build-multi-arch.sh` build contract | Preserves local architecture selection, variant, tags, and no-cache/load behavior. |
| DS-002 | Primary End-to-End | BEH-002 | Docker starts image | Browser/VNC/debugging/profile outcomes available | `entrypoint.sh` runtime bootstrap, then Supervisor service graph | Carries the changed Supervisor/provider boundary into real user-visible runtime. |
| DS-003 | Primary End-to-End | BEH-001 | Maintainer publication command | Verified multi-arch registry manifests/runtime identities | Build script plus Delivery publication boundary | Governs immutable/rolling tags and the dependency gate for server adoption. |
| DS-004 | Bounded Local | BEH-001, BEH-002 | Dockerfile runtime package layer | Coherent public Python/tool commands and assets in image | `Dockerfile` image composition | Prevents mixed Python/Supervisor ownership. |
| DS-005 | Bounded Local | BEH-002 | Entrypoint profile/runtime preparation | Supervisor exec after safe state preparation | `entrypoint.sh` | Preserves configured identity, XDG/DBus, VNC/profile locks, and startup sequencing. |
| DS-006 | Primary End-to-End | BEH-003 | README/image inspection | Correct Ubuntu/Python/Supervisor identity observed | Repository documentation/image composition | Keeps durable docs and runtime truth aligned. |

## Primary Execution Spine(s)

- `DS-001`: Maintainer CLI -> build contract parsing -> BuildX builder/platform selection -> Dockerfile composition -> OCI image -> local daemon tags.
- `DS-002`: Docker runtime -> `/entrypoint.sh` -> identity/XDG/profile preparation -> `/usr/local/bin/supervisord` -> unchanged Supervisor service graph -> VNC/websockify/DevTools/browser/profile outcomes.
- `DS-003`: Maintainer `--push` -> BuildX AMD64/ARM64 builds -> default/zh manifest assembly -> Docker Hub tags -> digest/runtime verification -> server-ticket dependency identity.
- `DS-006`: Maintainer/user -> README or image shell -> Ubuntu/Python/Supervisor/version observation -> accurate operational understanding.

## Spine Narratives (Mandatory)

| Spine ID | Short Narrative | Main Domain Subject Nodes | Governing Owner | Key Off-Spine Concerns |
| --- | --- | --- | --- | --- |
| DS-001 | Existing build wrapper selects supported local architecture and tags, then Dockerfile composes the new Python 3.13/tool boundary into a loaded 1.4.0 image. | Build request, platform/variant contract, image composition, loaded image | `build-multi-arch.sh` | Remote repositories, docs, durable tests. |
| DS-002 | Entrypoint prepares the same runtime/profile state, then execs the sole compatible Supervisor, which starts the unchanged service graph and surfaces browser/VNC/debugging capabilities. | Container start, runtime state, Supervisor, services, endpoints/profile | `entrypoint.sh` then Supervisor config | Python command selectors, zh, mobile-safe, evidence collection. |
| DS-003 | Existing push flow builds both architectures for each variant, publishes immutable and rolling tags, and verification records manifests and runtime identity before server adoption. | Push request, platform images, manifest, registry identity | Build script / Delivery boundary | Registry credentials, release evidence. |
| DS-004 | Dockerfile installs PPA Python beside Noble's OS Python, selects public developer commands in `/usr/local`, creates one 3.13 venv, and exposes all operational tools/assets through stable paths. | Package source, interpreters, venv, public commands/assets | `Dockerfile` | PPA/PyPI mutability. |
| DS-005 | Entrypoint preserves UID/GID, XDG/DBus, VNC, and profile-lock setup before replacing itself with the isolated Supervisor daemon. | Identity, runtime dirs, locks, Supervisor exec | `entrypoint.sh` | Mounted profile and logs. |
| DS-006 | Documentation and built identity consistently describe the final supported runtime. | README/image identity | Repository documentation owner | Release notes later. |

## Spine Actors / Main-Line Nodes

- `build-multi-arch.sh`: owns supported CLI semantics, platform selection, tags, load/push decision, and BuildX invocation.
- `Dockerfile`: owns the immutable image composition and runtime/provider path layout.
- `entrypoint.sh`: owns pre-service runtime preparation and the authoritative Supervisor handoff.
- `/opt/browser-tools` Supervisor 4.3.0: owns service process supervision after entrypoint handoff.
- `base.conf`: owns program declarations, ordering/dependencies, environments, and stable service commands.
- Docker Hub publication/verification: owns released artifact identity, not source behavior.

## Ownership Map

| Node | Owns | Must Preserve | Must Not Own |
| --- | --- | --- | --- |
| Build contract | CLI flags, local/multi-platform selection, image tags | Default/zh, AMD64/ARM64, Apple/Linux ARM aliases, load/push | Python package layout or runtime process behavior. |
| Image composition | Apt/PPA/PyPI/npm packages, users, filesystem/public paths, copied configs | Noble base, all current payload/tools, coherent Python/tool boundary | Runtime lifecycle sequencing after container start. |
| Runtime bootstrap | Identity, XDG/DBus, VNC/profile cleanup, final exec | Configured UID/GID and recovery | Package selection or fallback Supervisor choice. |
| Supervisor service graph | Service declaration/order/restart/log contracts | Existing programs/endpoints and dynamic environment | Interpreter installation or profile migration. |
| Release boundary | Registry tags/manifests/digests and post-publish verification | 1.4.0/default/zh/AMD64/ARM64 | Server repository adoption. |

## Thin Entry Facades / Public Wrappers

| Facade / Entry Wrapper | Governing Owner Behind It | Why It Exists | Must Not Secretly Own |
| --- | --- | --- | --- |
| `/usr/local/bin/python3`, `/usr/local/bin/python` symlinks | Installed `/usr/bin/python3.13` developer interpreter | Stable public commands with PATH precedence while preserving OS Python. | Package management, version fallback, or mutation of `/usr/bin/python3`. |
| `/usr/local/bin/supervisord`, `/usr/local/bin/supervisorctl` symlinks | `/opt/browser-tools` Supervisor 4.3.0 | Stable runtime/admin commands from one provider. | Dual provider selection or automatic fallback. |
| `/usr/local/bin/websockify`, `/usr/local/bin/uv` symlinks | `/opt/browser-tools` | Preserve public command names independent of venv internals. | Tool installation policy. |
| `/usr/local/share/websockify` symlink | Installed websockify package directory in `/opt/browser-tools` | Keep `base.conf` independent of Python minor-version paths. | Runtime discovery/fallback across arbitrary directories. |

## Removal / Decommission Plan (Mandatory)

| Item To Remove / Decommission | Why It Becomes Unnecessary | Replaced By | Scope | Notes |
| --- | --- | --- | --- | --- |
| Explicit apt `supervisor` package | Creates a second provider and the stale `/usr/bin/supervisord` path. | Supervisor 4.3.0 in `/opt/browser-tools` | In This Change | Dockerfile already creates required config/log directories. |
| `/usr/bin/supervisord` exec | Incompatible/stale owner for revised runtime. | `/usr/local/bin/supervisord` | In This Change | No fallback. |
| Python 3.12 developer packages/venv creation | Contradicts revised REQ-007. | Deadsnakes Python 3.13 and 3.13 venv | In This Change | Noble OS Python remains transitively/explicitly available internally. |
| `python-is-python3` public selection | Points `/usr/bin/python` at Noble 3.12 and blurs public ownership. | `/usr/local/bin/python` -> `/usr/bin/python3.13` | In This Change | Do not mutate `/usr/bin`. |
| Global pip/update-alternatives Python 3.13 approach from main | Risks replacing OS interpreter and mixing tools with system packages on Noble. | `/usr/local` selectors plus `/opt/browser-tools` | In This Change | Reuse behavior, not unsafe mechanism. |
| Python-minor-specific websockify public path | Couples service config to installation internals. | `/usr/local/share/websockify` | In This Change | Current candidate already has the correct stable shape. |
| Stale 3.12 durable assertions/docs | Would reject the approved target or produce false confidence. | RER-007-aligned assertions/docs | API/E2E/docs stages | Durable edits return through Code Review. |
| Stale Python 3.12 server-adoption intake | Would hand AC-011 output into a later ticket that validates the superseded runtime and omits Supervisor 4.3.0. | Current `server-base-image-adoption-follow-up.md` aligned to Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 and exact 1.4.0 identities | In This Change | Keep status deferred, separate, and non-authorizing; no server source changes. |

## Return Or Event Spine(s)

- Build/runtime failures return through process exit status and logs; no new event protocol is introduced.
- Supervisor status and service logs remain the operational return path from DS-002.
- Publication verification returns manifest digests and per-platform runtime identity to Delivery and the later server-ticket intake.

## Bounded Local / Internal Spines

- Parent owner `Dockerfile` (`DS-004`): stable Deadsnakes PPA -> Python 3.13 packages -> `/usr/local` Python selectors -> Python 3.13 venv -> isolated operational packages -> stable command/asset symlinks. This ordering ensures all public paths target completed owned artifacts.
- Parent owner `entrypoint.sh` (`DS-005`): configured identity -> XDG/DBus directories -> VNC/profile lock recovery -> Supervisor socket directory -> `exec /usr/local/bin/supervisord`. This keeps existing recovery complete before services begin.

## Off-Spine Concerns Around The Spine

| Off-Spine Concern | Related Spine IDs | Serves Which Owner | Responsibility | Why It Exists | Risk If Misplaced On Main Line |
| --- | --- | --- | --- | --- | --- |
| Deadsnakes/PyPI availability | DS-001, DS-004 | Image composition | Supply external runtime packages. | Python 3.13 is not Noble's default developer package. | Build orchestration would absorb package internals. |
| Configured UID/GID and Noble ubuntu-account removal | DS-001, DS-002, DS-005 | Image composition/runtime bootstrap | Preserve default and custom identity. | Noble reserves 1000. | Python change could regress unrelated identity. |
| zh locale/input | DS-001, DS-002 | Image composition/service graph | Preserve optional packages/config/fcitx lifecycle with English default. | Variant contract. | Core Python path would become variant-specific. |
| Mobile-safe Chrome wrapper | DS-002 | Service graph | Add `--no-sandbox` only for approved environment value. | Integrated main behavior. | Supervisor/Python concern would absorb browser policy. |
| Durable coverage/evidence | All | Review/validation owners | Assert behavior and preserve proof. | Required gate. | Product source would contain test-only branching. |
| Documentation and later-ticket intake | DS-003, DS-006 | Repository/release contract | Keep README, published identity evidence, and the deferred server-adoption brief consistent with RER-007. | SCN-005 carries the verified artifact into a later requirements package. | Runtime code should not own prose; the brief must not authorize downstream changes. |

## Ownership Boundaries

`Dockerfile` is the authoritative composition boundary. It may know the PPA, interpreter paths, venv, package versions, and public filesystem layout. Callers must not reconstruct those internals.

`entrypoint.sh` is the authoritative runtime-preparation boundary. Docker starts it; after state preparation it hands control to the single public Supervisor daemon. It must not probe multiple Supervisor paths.

`base.conf` is the authoritative service-graph contract. It consumes only stable public commands/assets and must not refer into `/opt/browser-tools/lib/python3.13/site-packages`.

`build-multi-arch.sh` remains the authoritative build/release command boundary. Python changes do not alter flags, platforms, variants, or tags.

## Boundary Encapsulation Map

| Authoritative Boundary | Internal Owned Mechanisms | Upstream Callers | Forbidden Bypass Shape | If API Too Thin, Fix By |
| --- | --- | --- | --- | --- |
| Dockerfile image layout | PPA, apt packages, `/opt/browser-tools`, `/usr/local` selectors/assets | BuildX | `base.conf` referencing venv site-packages or package-manager paths | Add/adjust a stable `/usr/local` path in Dockerfile. |
| Entrypoint | Runtime directories, locks, socket prep, Supervisor exec | Docker ENTRYPOINT / downstream image delegation | Docker config or downstream consumer launching `/usr/bin/supervisord` directly | Strengthen entrypoint contract; do not add a second startup path. |
| Supervisor service graph | Program commands, environments, priorities, restart/log policy | `supervisord` | Python installation code or version discovery inside `base.conf` | Expose stable command/assets during image composition. |
| Build wrapper | Builder, platforms, tags, load/push | Maintainer/CI | External scripts duplicating tag/variant rules for this ticket | Extend the wrapper only if a supported CLI contract is missing. |

## Dependency Rules

1. `build-multi-arch.sh` may invoke BuildX on the repository Dockerfile; it must not know Python installation internals.
2. Dockerfile may depend on stable Deadsnakes and PyPI inputs and create `/opt/browser-tools`; it must not replace `/usr/bin/python3` or install tools globally into the OS interpreter.
3. Public `/usr/local` selectors may point inward to exactly one installed interpreter/tool owner; no selector fallback or version probing is allowed at runtime.
4. `entrypoint.sh` may invoke only `/usr/local/bin/supervisord`; it must not depend on the venv's internal library layout or `/usr/bin/supervisord`.
5. `base.conf` may invoke stable public commands/assets only; it must not bypass image composition into `site-packages`.
6. Server/all-in-one repositories may consume only a later verified published image; this ticket must not modify them.
7. Implementation Engineer owns production source and implementation-scoped checks. API/E2E owns durable coverage investigation/edits/execution; durable coverage changes return through Code Review.

## Interface Boundary Mapping

| Interface / Command | Subject Owned | Responsibility | Accepted Identity Shape(s) | Notes |
| --- | --- | --- | --- | --- |
| `./build-multi-arch.sh [--no-cache] [--load\|--push] [--variant default\|zh]` | Image build/release request | Select platform/variant/tags/output | Existing CLI flags and host aliases | Preserve unchanged. |
| Docker build args `USER_UID`, `USER_GID`, `IMAGE_VARIANT` | Image identity/variant | Compose configured runtime user and optional zh payload | Numeric UID/GID; `default`/`zh` | Preserve default and custom identity. |
| Public `python3` / `python` | Developer interpreter | Execute Python 3.13 | No selector input | Resolve through `/usr/local`; OS path stays separate. |
| `/entrypoint.sh` | Runtime lifecycle | Prepare state and hand off to Supervisor | Existing environment/volume inputs | Preserve as Docker ENTRYPOINT. |
| `/usr/local/bin/supervisord` | Service lifecycle | Run real config using Supervisor 4.3.0 | `-n -c /etc/supervisor/supervisord.conf` | Sole daemon provider. |
| `/usr/local/bin/supervisorctl` | Service observation/control | Query the same Supervisor provider | Existing config/socket | Same venv/version as daemon. |
| Ports 5900/6080/9223 | VNC/websocket/debug surface | Preserve endpoints | Existing port numbers | No change. |

## Interface Boundary Check

| Interface | Singular Responsibility? | Explicit Identity? | Ambiguous Selector Risk | Corrective Action |
| --- | --- | --- | --- | --- |
| Build CLI | Yes | Yes | Low | None. |
| Python public commands | Yes | N/A | Low after design | Use fixed `/usr/local` symlinks; no `update-alternatives`. |
| Supervisor daemon/control commands | Yes | N/A | Low after design | Both symlink to same venv; remove apt provider. |
| Entrypoint | Yes | Environment-defined | Low | Use one absolute Supervisor path. |
| Service endpoints | Yes | Fixed ports | Low | Preserve. |

## Main Domain Subject Naming Check

| Node / Subject | Current / Proposed Name | Natural/Self-Descriptive? | Naming Drift Risk | Corrective Action |
| --- | --- | --- | --- | --- |
| Image composition | `Dockerfile` | Yes | Low | None. |
| Build contract | `build-multi-arch.sh` | Yes | Low | None. |
| Runtime bootstrap | `entrypoint.sh` | Yes | Low | None. |
| Chrome startup policy | `start-chrome.sh` | Yes | Low | Preserve. |
| Operational tools environment | `/opt/browser-tools` | Yes for repository context | Low | Keep it limited to Supervisor/websockify/uv. |

## Existing Capability / Subsystem Reuse Check

| Need / Concern | Existing Capability / Subsystem | Decision | Why | If New, Why Existing Is Not Right |
| --- | --- | --- | --- | --- |
| Python source/install | Dockerfile image composition | Extend | Already owns all runtime sources/packages. | N/A |
| Python operational tool isolation | Existing `/opt/browser-tools` | Extend | Current candidate already established the correct bounded environment. | N/A |
| Supervisor startup | Existing entrypoint + Supervisor config | Extend | Only provider path changes; lifecycle remains healthy. | N/A |
| Stable web assets | Existing `/usr/local/share/websockify` | Reuse | Already removes Python-minor coupling. | N/A |
| Matrix coverage | Existing tests and API/E2E artifacts | Extend | Scenarios exist; expectations must change. | N/A |
| New helper/script | Existing boundaries | Do Not Create | No independent ownership concern warrants another file. | N/A |

## Subsystem / Capability-Area Allocation

| Subsystem / Capability Area | Owns Which Concerns | Related Spines | Governing Owners | Decision | Notes |
| --- | --- | --- | --- | --- | --- |
| Image composition | Base, repositories, packages, identities, venv, public paths | DS-001, DS-004 | Dockerfile | Extend | Main implementation surface. |
| Runtime orchestration | Prep, Supervisor handoff, service graph | DS-002, DS-005 | entrypoint/base.conf | Extend | Provider changes; graph preserved. |
| Build/release | Platforms, variants, tags, load/push | DS-001, DS-003 | build script / Delivery | Reuse | No source behavior change expected. |
| Documentation and adoption-intake contract | Ubuntu/Python/Supervisor/version claims and the exact later-ticket activation identity | DS-003, DS-006 | README / server-adoption brief | Extend | Keep repository claims and SCN-005 intake aligned; no downstream source authorization. |
| Executable validation | Source/image/runtime/release evidence | All | API/E2E | Extend | Durable coverage update after implementation. |

## Draft File Responsibility Mapping

| Candidate File | Owning Subsystem | Owner / Boundary | Concrete Concern | Why One File | Reuses Shared Structure? |
| --- | --- | --- | --- | --- | --- |
| `Dockerfile` | Image composition | Image composition | Python 3.13 source/packages, public selectors, venv tools, Supervisor provider, stable paths | These are one immutable image-layout transaction. | Reuses `/opt/browser-tools`. |
| `entrypoint.sh` | Runtime orchestration | Runtime bootstrap | Absolute compatible Supervisor exec after preserved prep | Existing lifecycle owner. | Reuses public path. |
| `base.conf` | Runtime orchestration | Service graph | Consume stable websockify/public commands | Existing program owner; likely no content change. | Reuses stable paths. |
| `README.md` | Documentation | Repository contract | Final feature identity | Existing canonical usage doc. | N/A |
| `requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | Documentation / follow-up intake | SCN-005 later-ticket boundary | Verified published Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 identity and deferred activation gate | Existing canonical supplement for the later ticket | Reuses AC-011/AC-012 publication identity. |
| `tests/*.sh` | Validation | API/E2E | Revised assertions and runtime scenarios | Existing bounded harnesses. | Reuses stable AC/spine matrix. |

## Reusable Owned Structures Check

| Repeated Structure / Logic | Candidate Shared File | Owning Subsystem | Why Shared | Redundant Attributes Removed? | Overlap Removed? | Must Not Become |
| --- | --- | --- | --- | --- | --- | --- |
| Python operational command/provider paths | No new file; `/opt/browser-tools` plus `/usr/local` links are the owned filesystem structure | Image composition | All Python-installed services/tools need one interpreter/provider. | Yes | Yes | A general-purpose global Python environment. |
| Matrix expectations | Existing three test harnesses, not a new shared config | Validation | Each harness owns source/image/runtime depth; duplication is small and explicit. | N/A | N/A | A vague generic assertion framework. |

## Shared Structure / Data Model Tightness Check

No application data model is introduced. `/opt/browser-tools` has one narrow meaning: Python-installed operational commands required by the image. It must not absorb user developer packages, OS Python modules, Node tools, or unrelated browser configuration.

## Final File Responsibility Mapping

| File | Owning Subsystem | Owner / Boundary | Concrete Concern | Why One File | Reuses Shared Structure? |
| --- | --- | --- | --- | --- | --- |
| `Dockerfile` | Image composition | Image composition | Modify PPA/packages/venv/symlinks; remove duplicate Supervisor/system-Python mutations | Atomic image layout owner | Yes, `/opt/browser-tools`. |
| `entrypoint.sh` | Runtime orchestration | Runtime bootstrap | Modify final Supervisor exec only | Maintains one runtime lifecycle | Yes, stable `/usr/local` path. |
| `README.md` | Documentation | Repository contract | Modify Python/Supervisor feature wording | Canonical repo documentation | N/A |
| `requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | Documentation / follow-up intake | SCN-005 later-ticket boundary | Replace public Python 3.12 intake/validation wording with Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 and exact 1.4.0 identities; retain deferred/separate/non-authorizing status | Prevents the later ticket from validating the superseded runtime | Reuses verified AC-011/AC-012 outputs. |
| `base.conf` | Runtime orchestration | Service graph | Preserve current stable asset/service graph; modify only if executable evidence proves a required bounded correction | Prevent unrelated service redesign | Yes, stable commands/assets. |
| `VERSION` | Build/release | Release identity | Preserve `1.4.0` | Already correct | N/A |
| `build-multi-arch.sh` | Build/release | Build contract | Preserve unchanged unless evidence finds an approved local defect | Already healthy owner | N/A |
| `tests/validate-source-contract.sh` | Validation | API/E2E | Replace stale 3.12/no-Deadsnakes/distribution-Supervisor assumptions | Source boundary harness | Yes, requirements IDs conceptually. |
| `tests/validate-image.sh` | Validation | API/E2E | Assert Noble/public Python 3.13/distro Python separation/venv tools/Supervisor/assets/variant/identity | Image boundary harness | Yes, stable filesystem contract. |
| `tests/validate-running-container.sh` | Validation | API/E2E | Assert compatible Supervisor and preserved live services/browser/profile | Runtime boundary harness | Yes, stable runtime contract. |

## Applied Patterns

- **Isolated operational tool environment**: existing `/opt/browser-tools` is extended to own every pip-installed runtime command.
- **Stable public selector**: `/usr/local/bin` exposes required command contracts without changing OS-owned paths.
- **Stable computed asset link**: Dockerfile discovers the installed websockify package directory once at build time and exposes `/usr/local/share/websockify`.
- **Single provider**: only Supervisor 4.3.0 from the venv is exposed/executed.

## Target Subsystem / Folder / File Mapping

| Path | Kind | Owner / Boundary | Responsibility | Why It Belongs Here | Must Not Contain |
| --- | --- | --- | --- | --- | --- |
| `/Dockerfile` | File | Image composition | Complete Python/tool/provider filesystem layout | Existing root-level OCI build owner | Runtime fallback logic. |
| `/entrypoint.sh` | File | Runtime bootstrap | Existing prep then compatible Supervisor handoff | Existing Docker lifecycle entry | Package installation or multi-provider probing. |
| `/base.conf` | File | Supervisor service graph | Stable program graph and public commands/assets | Existing graph owner | Python site-package paths. |
| `/README.md` | File | Documentation contract | Ubuntu 24.04/Python 3.13/Supervisor 4.3.0 statement | Existing canonical doc | Temporary test results. |
| `/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | File | SCN-005 follow-up intake | Exact verified published identity and later-ticket validation target | Existing current supplement | Server source edits or independent product approval. |
| `/tests/` | Folder | API/E2E validation | Durable source/image/runtime coverage | Existing coverage boundary | Production branching. |
| `/requirements/ubuntu-24-minimal-base/` | Folder | Ticket artifacts | Requirements/design/review/evidence history | Existing task-local package | Long-lived source behavior. |

The compact flat root remains clearer than introducing new folders: each production file already represents one operational boundary, and this change adds no new independently reusable application subsystem.

## Folder Boundary Check

| Path / Folder | Structural Depth | Ownership Clear? | Mixed/Over-split Risk | Justification |
| --- | --- | --- | --- | --- |
| Repository root production scripts/configs | Mixed Justified | Yes | Low | Small Docker-image repository with naturally distinct root entry/config files. |
| `tests/` | Off-Spine Concern | Yes | Low | Durable executable coverage is separated from production. |
| Ticket artifact folder | Off-Spine Concern | Yes | Low | Time-bound requirements/design/evidence package. |

## Concrete Examples / Shape Guidance

| Topic | Good Example | Bad / Avoided Shape | Why It Matters |
| --- | --- | --- | --- |
| Public vs OS Python | `/usr/local/bin/python3 -> /usr/bin/python3.13`; `/usr/bin/python3 -> /usr/bin/python3.12` | `update-alternatives --install /usr/bin/python3 ...3.13` | Satisfies developer behavior without taking ownership of Noble's system interpreter. |
| Supervisor ownership | `/usr/local/bin/supervisord -> /opt/browser-tools/bin/supervisord` and same-provider `supervisorctl` | apt Supervisor plus pip Supervisor with PATH-dependent selection | Removes mixed daemon/CLI versions and prior compatibility failure. |
| Websockify assets | `base.conf -> /usr/local/share/websockify -> discovered venv package dir` | `/usr/local/lib/python3.13/dist-packages/websockify` in config | Prevents Python-minor and installer-layout coupling. |
| Startup | `entrypoint prep -> exec /usr/local/bin/supervisord` | runtime loop that probes venv then falls back to `/usr/bin` | Clean-cut target and deterministic failure. |

## Backward-Compatibility Rejection Log (Mandatory)

| Candidate Compatibility Mechanism | Why Considered | Decision | Clean-Cut Replacement / Removal Plan |
| --- | --- | --- | --- |
| Keep Python 3.12 and add `python3.13` only as a secondary command | Could minimize source delta. | Rejected | Public `python3`/`python` become 3.13; stale 3.12 public assertions removed. |
| Repoint `/usr/bin/python3` with update-alternatives | Main used it on Jammy. | Rejected | Preserve OS path; use `/usr/local` selectors. |
| Keep apt and pip Supervisor together | Apt package provides familiar filesystem defaults. | Rejected | Dockerfile creates required dirs/config; venv Supervisor 4.3.0 is sole provider. |
| Entrypoint fallback from venv Supervisor to `/usr/bin` | Could mask missing install. | Rejected | Build/validation must fail if the sole compatible provider is absent. |
| Hard-code Python 3.13 site-packages in `base.conf` | Mirrors older main path. | Rejected | Keep stable computed `/usr/local/share/websockify`. |
| Preserve tests accepting either 3.12 or 3.13 | Could ease transition. | Rejected | RER-007 is a clean target; exactly 3.13 is required. |

## Derived Layering

- Build/release boundary: build script/BuildX.
- Immutable composition boundary: Dockerfile and copied configuration/scripts.
- Runtime bootstrap boundary: entrypoint.
- Runtime service boundary: Supervisor config and stable commands.
- Validation/documentation concerns remain outside production ownership.

This is explanatory only; dependency and ownership rules above govern implementation.

## Change / Refactor Sequence

1. In `Dockerfile`, re-add `ppa:deadsnakes/ppa` beside existing sources and replace the explicit Python 3.12 developer package set with `python3` plus `python3.13`, `python3.13-dev`, and `python3.13-venv`; remove explicit apt `supervisor` and unneeded public-selection packages such as `python-is-python3`.
2. After packages and user/variant setup, create `/usr/local/bin/python3` and `/usr/local/bin/python` symlinks to `/usr/bin/python3.13` without modifying `/usr/bin/python3`.
3. Create `/opt/browser-tools` with `/usr/bin/python3.13 -m venv`; upgrade its packaging tools; install `supervisor==4.3.0`, websockify, and `uv` in the same command-owned environment.
4. Expose `supervisord`, `supervisorctl`, `websockify`, and `uv` via `/usr/local/bin`. Compute the installed websockify module directory using the venv interpreter and expose it via `/usr/local/share/websockify`.
5. Preserve existing manual Supervisor directories/config copies and `base.conf` stable websockify path. Change only the final `entrypoint.sh` exec to `/usr/local/bin/supervisord`.
6. Update README from Python 3.12 to Python 3.13 and Supervisor 4.3.0; preserve VERSION 1.4.0 and other documentation.
7. Align `server-base-image-adoption-follow-up.md` to the exact verified Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 `1.4.0`/`1.4.0-zh` intake and correct the requirements dependency-table statement for already-resolved DEC-003; preserve the brief as deferred, separate, and non-authorizing.
8. Run implementation-scoped syntax/static/path/config checks, including explicit proof that `/usr/bin/python3` was not rewritten and no `/usr/bin/supervisord`, global pip, Python 3.12 developer target, or version-specific websockify public path remains.
9. After code review, API/E2E revises the durable source/image/runtime harnesses and coverage investigation, executes the complete integrated Docker matrix, and routes durable test edits back through Code Review.
10. Delivery resumes only after source and durable coverage reviews pass and API/E2E proves the final integrated candidate. Publication remains last and must verify manifests/runtime identity before server adoption.

## Key Tradeoffs

- **Deadsnakes vs compiling Python**: Deadsnakes matches the user-cited tested main direction, provides Noble AMD64/ARM64 packages, and keeps build complexity bounded. It remains an untrusted mutable PPA; clean package-origin and architecture validation are mandatory.
- **`/usr/local` selectors vs replacing `/usr/bin`**: selectors rely on standard PATH precedence but preserve OS ownership and reduce Noble breakage risk. Absolute `/usr/bin/python3` continues to report 3.12 internally by design.
- **One venv for three operational tools**: Supervisor, websockify, and `uv` share the same Python 3.13 compatibility boundary and lifecycle. This is coherent for the image's operational tools and avoids multiple pip environments, but it must not become a general user package environment.
- **Remove apt Supervisor**: loses distribution package lifecycle/default files, but the repository already owns config and directories, and a single tested 4.3.0 provider is clearer and safer.

## Risks

- External PPA/PyPI availability or package updates can break clean builds; record resolved versions and distinguish dependency failures.
- AMD64 package availability is proven, but full emulated/native build/runtime behavior is not yet proven for the combined target.
- PATH behavior could differ under Supervisor or `su`; use absolute paths for the daemon and validate public commands as root and `vncuser`.
- `supervisorctl` does not support a `--version` flag; validate package version through `supervisord --version` and/or Python distribution metadata, and validate `supervisorctl --help/status` against the real daemon.
- Removing apt Supervisor could reveal undeclared filesystem/package dependencies; existing Dockerfile directory creation and real-config execution must be verified.
- websockify/`uv` are unpinned; validate current versions and stable assets at final build time.

## Guidance For Implementation

- Do not copy main's Dockerfile conflict side wholesale. Preserve every IR-004 Noble/configured-identity/stable-path/Chrome-wrapper decision except the superseded Python/distribution-Supervisor target.
- Prefer explicit absolute paths during build: `/usr/bin/python3.13 -m venv` and `/opt/browser-tools/bin/python -m pip`.
- The public path contract is exact: `command -v python3` and `command -v python` should be `/usr/local/bin/...` resolving to `/usr/bin/python3.13`; `/usr/bin/python3` must continue resolving to Noble's distribution interpreter.
- Both Supervisor daemon and control CLI must resolve to `/opt/browser-tools`; do not leave an exposed apt provider.
- Keep `base.conf` at `websockify --web=/usr/local/share/websockify ...`; compute the symlink at build time with the venv interpreter.
- Do not change service ordering, configured UID/GID logic, dynamic XDG/DBus interpolation, ports, zh configuration, `start-chrome.sh`, build script, VERSION, or server source unless a new evidence-backed finding is routed under the workflow. Keep the corrected server-adoption brief as intake context only and require the later ticket to bootstrap its own requirements/design approval.
- Required integrated API/E2E matrix:
  1. source contract and obsolete-path scans;
  2. clean default and `zh` image builds for `linux/arm64` and `linux/amd64`;
  3. built-image Ubuntu 24.04, public Python 3.13, preserved `/usr/bin/python3`, Deadsnakes origin, venv ownership, Supervisor 4.3.0, websockify/uv commands/assets, gh/Node/Yarn/utilities, variant/locales, default and non-1000 identity;
  4. normal entrypoint and real Supervisor config/status, with no `pkgutil.ImpImporter` traceback;
  5. DBus/XDG, TigerVNC, XFCE, CopyQ, Chrome, socat, websockify, port 5900 banner, port 6080 assets/WebSocket, port 9223 DevTools and semantic render;
  6. default and `zh` runtime, English default and Pinyin availability;
  7. normal and `AUTOBYTEUS_NODE_PROFILE=mobile-safe` Chrome argument behavior;
  8. persistent profile recreation and stale-lock recovery;
  9. local-load host aliases, default/zh tags, no-push multi-platform readiness;
  10. only after all prior checks pass, publication and remote manifest/pull/run verification for `1.4.0`, `latest`, `1.4.0-zh`, and `zh` across AMD64/ARM64.
