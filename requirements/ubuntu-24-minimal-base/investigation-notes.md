# Requirements Investigation Notes

## Investigation Meta

- Request / ticket: `BRD-UBUNTU24-001`
- Workspace root: `/home/autobyteus/workspace/browser-docker`
- Repository mode: `Git`
- Task worktree / branch: Dedicated branch `requirements/ubuntu-24-minimal-base` in the supplied repository workspace
- Base or reference revision: `2bc0b4a` (`main` / `origin/main` at intake)
- Bootstrap result: Clean repository confirmed; dedicated task branch created before deeper investigation.
- Bootstrap blocker: None.
- Current requirements revision ID: `RER-006`
- Investigation status: Complete; approved direct-implementation package. Executable Docker build/runtime/publication validation is assigned downstream because Docker is unavailable in this environment.

## Initial Request And Clarifications

- Original request: “the base server docker image version uses ubunt 22 something, but its too old. we need to use 24 stable version, of cousrse the mininal one. the browser docker project is here /home/autobyteus/workspace/browser-docker basically current base docker uses too low ubuntu version”
- Clarifications received: Repository location and desired Ubuntu major/minor family were supplied directly. On 2026-09-01 the user confirmed that “minimal” refers specifically to the base image itself, explicitly agreed with Python 3.12, and selected a two-ticket sequence: update/build/publish the browser base first, then update the AutoByteus server consumers in a separate ticket.
- User-supplied facts and constraints: Current base is an Ubuntu 22 release; use a stable Ubuntu 24 minimal base; change applies to the browser Docker project.
- Initial ambiguity: Whether “minimal” means the official minimal Ubuntu OCI rootfs or a broader pruning of installed application packages. Resolved by the user on 2026-09-01 in favor of the official minimal base image interpretation.

## Product And Domain Understanding

- Product area: Multi-architecture browser/desktop Docker image with Chromium, XFCE, TigerVNC, websockify, remote debugging, developer runtimes/tools, and an optional Chinese locale/input variant.
- Affected actors or systems: Image maintainers, Docker BuildX/registry publishing, container runtimes, downstream images/users, AMD64/ARM64 platforms.
- Existing user or operational purpose: Build, publish, and run a reusable browser test environment with VNC and Chromium remote-debugging access.
- Relevant terminology: Ubuntu 24.04 LTS is Noble Numbat. Canonical documents Ubuntu OCI images as built from a minimal, container-tailored rootfs; this differs from minimizing the entire final application image after Chromium/XFCE/tools are installed.

## Source Log

| Date | Source Type (`Code`/`Doc`/`Runtime`/`Data`/`Contract`/`Web`/`User`/`Command`/`Other`) | Exact Source / Command / Query | Why Consulted | Relevant Finding | Follow-Up |
| --- | --- | --- | --- | --- | --- |
| 2026-09-01 | User | Intake request in current conversation | Establish desired outcome and repository. | Explicit request to replace the too-old Ubuntu 22 base with a stable minimal Ubuntu 24 base. | Present interpretation for approval. |
| 2026-09-01 | User | Follow-up clarification in current conversation | Resolve the meaning of “minimal.” | User confirmed that “minimal” is a property of the base image itself. | Treat package/feature pruning as out of scope. |
| 2026-09-01 | User | Python-version follow-up in current conversation | Determine whether Python 3.11 should remain preserved. | User prefers a newer Python and asked for a 3.12-versus-3.13 recommendation. | Recommend Noble-native 3.12 for approval. |
| 2026-09-01 | User | Python-version decision in current conversation | Resolve DEC-002. | User explicitly agreed with Python 3.12. | Make REQ-007 a Must requirement; complete-package approval was still pending at that round and was later received in RER-006. |
| 2026-09-01 | User | Delivery-sequencing proposal in current conversation | Decide whether upstream browser and downstream server work should be coupled. | User proposed a separate browser-image ticket that publishes a verified Docker Hub version before server updates begin. | Make publication part of this ticket and preserve server changes for a follow-up ticket. |
| 2026-09-01 | User | Explicit first-ticket approval in current conversation | Close the requirements approval gate. | User directed the department to work on ticket one first and not begin ticket two until ticket one finishes, approving the presented first-ticket package and sequence. | Complete routing assessment and hand off only the browser-image package. |
| 2026-09-01 | Command | `git -C /home/autobyteus/workspace/browser-docker status --short --branch`; `git switch -c requirements/ubuntu-24-minimal-base` | Verify safe task isolation. | Supplied repository was clean on `main`; branch created from `2bc0b4a`. | Preserve branch until downstream route. |
| 2026-09-01 | Code | `/home/autobyteus/workspace/browser-docker/Dockerfile` | Identify current base and compatibility surface. | Line 2 is `FROM ubuntu:22.04`; image installs PPAs, packages, Python 3.11, Node.js 22, browser/desktop/VNC and variant dependencies. | Require a Noble build and runtime smoke test. |
| 2026-09-01 | Code | `/home/autobyteus/workspace/browser-docker/build-multi-arch.sh` | Determine supported build scenarios/contracts. | Default local build/load; `--push`; `--no-cache`; `--variant`; AMD64/ARM64; version and rolling variant tags. | Preserve command and tag behavior. |
| 2026-09-01 | Code | `base.conf`, `entrypoint.sh`, `start-vnc.sh`, `supervisord.conf`, `docker-compose*.yml`, `run-container.sh`, `disable-screensaver.sh` | Determine runtime behavior to preserve. | Existing service, user, port, persistent profile, recovery, environment, and launch contracts extend beyond the base declaration. | Acceptance criteria cover representative runtime outcomes. |
| 2026-09-01 | Doc | `/home/autobyteus/workspace/browser-docker/README.md` | Identify documented public/operational behavior. | README calls out Ubuntu 22.04 and documents default/`zh`, multi-arch, VNC/debugging, profile persistence, and recovery. | Require accurate 24.04 documentation while preserving other instructions. |
| 2026-09-01 | Command | `grep -RInE 'ubuntu:|Ubuntu 22|22\\.04|python3\\.11|dist-packages/websockify' --exclude-dir=.git .` | Find release- and runtime-specific assumptions. | Explicit 22.04 references exist only in Dockerfile and README; Python 3.11 is deliberately installed and its websockify path is explicitly configured. | Initially identified as preserved; superseded by proposed REQ-007 after the user reopened the Python version. |
| 2026-09-01 | Command | `docker version`; `docker buildx version` | Determine available executable validation. | Docker/BuildX are not installed in the Requirements Engineer environment. | Downstream implementation/API-E2E environment must perform AC-003 through AC-008. |
| 2026-09-01 | Web | https://documentation.ubuntu.com/oci-registries/oci-reference/oci-image-configuration/ | Verify official image minimal/multi-arch semantics. | Canonical says Ubuntu OCI images use a minimal container-tailored rootfs and a multi-architecture image index; `ubuntu:24.04` resolves by architecture. | Supports REQ-002 and AC-002. |
| 2026-09-01 | Web | https://hub.docker.com/_/ubuntu and https://hub.docker.com/_/ubuntu/tags?name=24.04 | Verify Docker Official Image tag and platforms. | `ubuntu:24.04` is a maintained Docker Official Image tag with AMD64 and ARM64 entries and a small base layer. | Use explicit 24.04, not a floating `latest`. |
| 2026-09-01 | Web | https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa | Check Python 3.11 feasibility on Noble. | PPA lists Python 3.11 for Ubuntu 24.04/Noble, with successful AMD64/ARM64 builds. | Validate actual image build. |
| 2026-09-01 | Web | https://launchpad.net/~xtradeb/+archive/ubuntu/apps | Check current non-Snap Chromium source on Noble. | XtraDeb publishes Chromium packages for Noble as well as Jammy; historical and current Noble builds are shown. | Validate both repository architectures/variants during build. |
| 2026-09-01 | Web | https://github.com/nodesource/distributions/blob/master/DEV_README.md | Check Node.js 22 support. | NodeSource's matrix lists Ubuntu Noble with Node 22 support and AMD64/ARM64 DEB architectures. | Validate actual setup/install in clean build. |
| 2026-09-01 | Web | https://documentation.ubuntu.com/ubuntu-for-developers/reference/availability/python/ and https://packages.ubuntu.com/en/noble/python3 | Identify Ubuntu 24.04's supported/default Python. | Canonical lists Python 3.12 as Noble's available and default Python; Ubuntu packages it for AMD64 and ARM64. | Prefer 3.12 to align with the selected OS base. |
| 2026-09-01 | Web | https://devguide.python.org/versions/ and https://www.python.org/downloads/release/python-3130/ | Distinguish upstream stability from Noble integration. | Python 3.13 is upstream-stable and in bugfix support, while 3.12 is in security support; current newest stable upstream is 3.14, showing that “latest stable” is not the same decision as “Ubuntu 24.04 native.” | Recommend OS-native 3.12 for this base-image task. |
| 2026-09-01 | Web | https://documentation.ubuntu.com/ubuntu-for-developers/howto/python-setup/ | Check Ubuntu system-Python constraints. | Canonical advises keeping the default system Python and using isolated environments for pip-installed dependencies; `/usr/bin/python3` points to 3.12 on Noble. | Downstream must adapt the current direct `ensurepip`/system-pip setup safely. |
| 2026-09-01 | Code | `/home/autobyteus/workspace/autobyteus-workspace/autobyteus-server-ts/docker/Dockerfile.monorepo`; `/home/autobyteus/workspace/autobyteus-workspace/docker/Dockerfile.allinone` | Identify downstream server consumers for ticket sequencing. | Server runtime uses `autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` defaulting to `latest`; all-in-one uses `${CHROME_VNC_TAG}` defaulting to `zh`. Neither directly declares Ubuntu/Python. | Do not edit in this ticket; later adoption must consume a verified published browser release. |
| 2026-09-01 | Code | AutoByteus server build scripts, Compose, `.github/workflows/release-server-docker.yml`, and browser bridge source test | Determine downstream configuration/update surface. | Local/multi-arch and CI flows propagate default/`zh` base tags; a source test currently asserts the `latest` default. | Follow-up ticket must decide whether to pin the new immutable version or retain moving defaults, then update tests and validate both consumers. |
| 2026-09-01 | Command | `git status --short --branch` in `/home/autobyteus/workspace/autobyteus-workspace` | Confirm reference-repository state before read-only investigation. | Reference repository is clean on `personal` at `80e2bd195c42ea3ced778dbc051d4d00edaef16f`; no changes were made. | A dedicated task workspace/branch will be required when the separate server ticket begins. |

## Relevant Existing Behavior And Supported Product Paths

| Behavior ID | Kind | Supported Trigger Or Governing Contract | Current Supported Product Behavior Path / Lifecycle | Current Outcome / Invariants | Evidence | Confidence / Unknown |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | Maintainer invokes `build-multi-arch.sh` using documented flags. | Script reads `VERSION`, chooses local or multi-platform mode, passes the variant build arg, builds `Dockerfile`, and applies stable tags. | Image is based on Ubuntu 22.04; default and `zh`, AMD64 and ARM64, and tag semantics are supported. | Build script, Dockerfile, README. | High confidence from source; current build not executed in this environment. |
| BEH-002 | System | Container is started via supported run script/Compose contract. | Entrypoint prepares runtime/profile state; Supervisor starts DBus, TigerVNC, XFCE, optional fcitx5, Chromium, socat, and websockify. | Browser desktop and remote endpoints operate as non-root `vncuser`; profile state is persisted by documented volume usage. | Dockerfile, entrypoint, supervisor configs, scripts, Compose, README. | High source confidence; runtime not executed here. |
| BEH-003 | Contract | Maintainer/user reads repository docs or inspects image identity. | README presents the image feature set and Ubuntu version. | Current published statement is Ubuntu 22.04. | README line 6; Dockerfile line 2. | High. |

## Relevant Codebase And Technical Facts

| Path / Component / Contract | Current Responsibility Or Behavior | Requirement Implication | Architecture Question Deferred Downstream |
| --- | --- | --- | --- |
| `Dockerfile` | Selects Ubuntu 22.04; adds Universe, Deadsnakes, XtraDeb, and NodeSource; installs Python 3.11 and product dependencies, then overrides `python3` to 3.11 and invokes `ensurepip`. | Base must become official Ubuntu 24.04; proposed runtime must become Noble-native Python 3.12; Noble-compatible package installation must preserve Python-installed outcomes. | If compatibility requires structural runtime/service changes rather than bounded install/path adjustments, downstream must escalate. |
| `build-multi-arch.sh` | Owns AMD64/ARM64 build and tagging for default/variant images. | Both platforms/variants are acceptance requirements. | None expected; preserve existing contract. |
| `base.conf` | Hard-codes a Python 3.11 websockify data path and supervises runtime services. | Websockify behavior must be preserved while removing the Python 3.11 path assumption. | The production-safe path/install adjustment is downstream implementation evidence, not a new behavior decision. |
| `README.md` | States Ubuntu 22.04 and documents supported product/operational behavior. | Version statement must be synchronized; surrounding behavior is preservation evidence. | None. |
| Run/Compose/entrypoint scripts | Define user-visible ports, volume, environment, recovery, and startup behavior. | Representative behavior must be smoke tested after distribution change. | Escalate only if Noble makes current structural surfaces insufficient. |
| AutoByteus `Dockerfile.monorepo` and `Dockerfile.allinone` (read-only reference repo) | Consume `autobyteus/chrome-vnc` through `latest`/`zh`-oriented build args. | Demonstrates why the browser artifact must be published before server adoption and why server work is a separate dependent ticket. | The later ticket owns the exact pin/moving-tag decision and consumer implementation. |

## Structural And Payload Surface Inventory

### Payload Or Content Surfaces

- Files, records, documents, catalogs, fixtures, or generated payloads: README Ubuntu version statement.
- Existing readers, writers, or contracts that consume them: Repository maintainers and image consumers.
- Evidence paths: `/home/autobyteus/workspace/browser-docker/README.md`.

### Structural Surfaces

- Runtime modules, shared interfaces, routes, APIs, persistence boundaries, security/concurrency controls, deployment configuration, or ownership boundaries: Dockerfile base/dependency configuration; BuildX multi-platform script; supervisor service graph; entrypoint; run/Compose configuration; Chromium profile volume contract.
- Existing structural surfaces that can support the approved behavior: The single existing Dockerfile already centralizes the base image and dependency install for both variants and platforms. Build and runtime contracts do not require a new subsystem or interface merely to select Noble.
- Evidence paths: `Dockerfile`, `build-multi-arch.sh`, `base.conf`, `entrypoint.sh`, `start-vnc.sh`, `docker-compose.yml`, `docker-compose.chrome-vnc.yml`, `run-container.sh`; read-only consumer evidence at `/home/autobyteus/workspace/autobyteus-workspace/autobyteus-server-ts/docker/Dockerfile.monorepo` and `/home/autobyteus/workspace/autobyteus-workspace/docker/Dockerfile.allinone`.

### Potential Architecture-Design Triggers

- API or external-contract change: No desired change; existing launch/port/tag contracts must be preserved.
- Persistence schema or invariant change: No desired change; profile volume semantics must be preserved.
- Security or privacy boundary change: None requested.
- Concurrency or lifecycle change: None requested.
- Deployment, migration, ownership-boundary, architectural-pattern, or structural-refactoring change: Base runtime dependency change is requested, but no deployment-topology, migration, ownership, or new-pattern change is desired. Actual Noble incompatibility could reveal design impact and must be reported rather than silently broadening scope.
- Confirmed absent, present, or unknown: No approved structural-impact trigger is presently identified; final routing assessment remains gated on approval.

## Runtime, Probe, Or Reproduction Findings

| Method / Command | Scenario | Observation | Requirement Implication | Artifact / Evidence Path |
| --- | --- | --- | --- | --- |
| `git status --short --branch` | Safe task bootstrap | Repository was clean on `main` and a dedicated requirements branch was created. | Requirements artifacts can be persisted without overwriting unrelated work. | Git metadata; branch `requirements/ubuntu-24-minimal-base`. |
| `grep` release/path references | Static compatibility inventory | Only Dockerfile/README mention Ubuntu 22.04; Python 3.11 path coupling exists in `base.conf`. | Change is bounded but needs full build/runtime validation rather than a text-only check. | Command captured in Source Log. |
| `docker version`; `docker buildx version` | Executable build probe | Both commands fail because `docker` is not installed. | Do not claim build success; keep AC-003–AC-008 for downstream executable validation. | Current environment command output. |

## Stakeholder And User Evidence

| Source / Actor | Need, Problem, Or Constraint | Evidence Strength | Requirement Implication | Open Question |
| --- | --- | --- | --- | --- |
| Requester | Ubuntu 22-based server image is too old; use stable minimal Ubuntu 24. | Direct, authoritative. | REQ-001 and REQ-002 are Must requirements. | Confirm minimal-base interpretation rather than package pruning. |
| Current repository contract | Both image variants, platforms, tools, and runtime behavior are documented/sourced. | Strong implementation and docs evidence. | Treat current capabilities as preserved because no removal was requested. | None material beyond build validation. |

## External Contracts, Standards, And Dependencies

| Contract / Dependency | Version / Authority | Relevant Behavior Or Constraint | Evidence | Unknown / Risk |
| --- | --- | --- | --- | --- |
| Ubuntu OCI base | 24.04 LTS / Canonical and Docker Official Images | Official minimal rootfs, explicit Noble tag, multi-arch. | Canonical OCI docs; Docker Hub official listing. | Tag is mutable within the 24.04 release stream. |
| Ubuntu Noble Python | Python 3.12 / Canonical | Use Noble's official/default Python on AMD64 and ARM64. | Canonical Python availability/setup docs and Ubuntu package index. | System-Python packaging requires a supported approach for third-party tools. |
| Deadsnakes | Current Python 3.11 source / Launchpad PPA | No longer needed solely for Python if 3.12 recommendation is approved. | Current Dockerfile and PPA evidence. | Verify no unrelated package depends on retaining the PPA. |
| XtraDeb | Noble Chromium / Launchpad PPA | Preserve non-Snap `chromium` package currently used by image. | Launchpad Noble build/package evidence. | Must verify both target architectures at build time. |
| NodeSource | Node.js 22 / NodeSource | Preserve Node.js 22 on Noble and both target architectures. | Official distributions repository matrix. | Remote setup script is mutable. |

## Persisted Data And State Facts

- Affected stored or external subject: Existing Chromium user profile state mounted from a Docker volume.
- Location and representative shape: `/home/vncuser/.config/chromium`; arbitrary Chromium profile files and locks.
- Approximate volume: Unknown and user-dependent.
- Current readers and writers: Chromium; entrypoint lock-recovery checks; Docker volume runtime.
- Current unknown/extra-field behavior: Chromium manages profile shape; repository does not define a schema.
- Required semantics or data that must be preserved: Container recreation with the same volume preserves profile state; current stale-lock recovery remains functional.
- Acceptable loss, reset, rebuild, or regeneration: Disposable image layers/containers only; no silent profile reset.
- Privacy, retention, compliance, downtime, or operational constraints: None newly stated.
- Remaining evidence gap: Runtime behavior on an actual Noble-based image.

## Product Design Request Context

- Product Design request in the current input: `Not stated`
- User's requested outcome, in the user's own terms: `N/A — not applicable`
- Requirement / behavior IDs involved: `N/A — not applicable`
- Product decision, uncertainty, or experience to understand or evolve: `N/A — not applicable`
- Critical journey and states: `N/A — not applicable`
- Known constraints and non-goals: `N/A — not applicable`
- Relevant existing-product or frontend context supplied or established: `N/A — not applicable`
- Product Design request artifact / message reference: `N/A — not applicable`
- Established separate prototype repository/root and ticket reference, when applicable: `N/A — not applicable`

## Product Design Findings

- Product Design package path (external Product Design & Prototyping repository): `N/A — not applicable`
- Visualizer or prototype source path: `N/A — not applicable`
- Approved UI/UX specification path, when applicable: `N/A — not applicable`
- Review URL: `N/A — not applicable`
- Explicit user-confirmation reference: `N/A — not applicable`
- Journeys and scenarios validated: `N/A — not applicable`
- Final visual-reference paths: `N/A — not applicable`
- Product decisions supported by evidence: `N/A — not applicable`
- Alternatives rejected or still open: `N/A — not applicable`
- Mocked boundaries and production gaps: `N/A — not applicable`
- Requirements sections affected: `N/A — not applicable`

## Supplemental Artifact Inventory

| Artifact Path | Owner | Purpose | Scope | Related Requirement / AC IDs | Status | Approval Applicability / State |
| --- | --- | --- | --- | --- | --- | --- |
| `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` | Requirements Engineer | Durable requirements-round history. | RER-001 through RER-006. | All | Current | Approved first-ticket package. |
| `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | Requirements Engineer | Preserve the separate server-ticket trigger, observed consumer surfaces, and intake questions. | Follow-up only; no server source changes in this package. | REQ-008–REQ-009; AC-011–AC-012 | Current | User requested the sequence; later ticket requires its own approval package. |

## Assumptions, Unknowns, And Risks

| ID | Type (`Assumption`/`Unknown`/`Risk`) | Description | Why It Matters | Resolution / Owner | Status |
| --- | --- | --- | --- | --- | --- |
| ASM-001 | Assumption | “24 stable” means explicit Ubuntu 24.04 LTS. | Prevents selecting a floating or non-LTS base. | User approval. | Open. |
| ASM-002 | Assumption | “minimal” applies to the official base rootfs, not feature/package pruning. | Package pruning could break current product behavior and is a larger scope. | Confirmed directly by the user on 2026-09-01. | Validated. |
| ASM-003 | Assumption | Python should move to Noble-native 3.12 rather than PPA-sourced 3.13/3.14. | It aligns OS and developer runtime support and reduces external-source complexity while satisfying the request for a newer Python. | User explicitly agreed on 2026-09-01. | Validated. |
| RISK-001 | Risk | Noble can change dependency versions, library behavior, or filesystem locations even when packages exist. | A one-line base change may build but still regress runtime services. | Full AC-003–AC-008 and AC-010 validation / downstream engineering. | Open until validated. |
| RISK-002 | Risk | XtraDeb, NodeSource, PyPI/npm, and any still-required PPA are remote mutable dependencies. | Clean/multi-platform builds can fail independently of repository code. | Downstream validation must distinguish repository defects from external availability. | Existing risk. |
| UNK-001 | Unknown | Actual clean default/`zh` AMD64/ARM64 build and runtime results on Noble. | Required to claim delivery. | Implementation and API/E2E teams with Docker/BuildX. | Open. |
| RISK-003 | Risk | Ubuntu's system Python packaging differs from the current Deadsnakes `ensurepip` flow, and `base.conf` embeds a Python 3.11 package path. | A version-only edit can break the build or websockify at runtime. | Downstream implementation and executable validation under REQ-007/AC-010. | Open until validated. |
| RISK-004 | Risk | AutoByteus server consumers currently default to moving `latest`/`zh` browser tags. | Rebuilding at different times can consume different base contents, complicating reproducibility and rollback. | Separate server-adoption ticket decides exact pinning/adoption policy using the published immutable release identity. | Deferred to follow-up ticket. |

## Requirement Implications

The direct request establishes Ubuntu 24.04 LTS as the intended base release. Canonical's official `ubuntu:24.04` OCI image already supplies the requested minimal container rootfs and multi-architecture resolution, so no unofficial “minimal” base is needed. Python 3.12 is selected because it is Noble's official/default Python on both target architectures. The repository's Python 3.11/websockify path coupling and direct `ensurepip` flow require compatibility work and executable validation. The user then selected a dependency-ordered delivery strategy: the browser repository is the first independent ticket and must publish a verified new multi-arch version; AutoByteus server/all-in-one adoption is a separate later ticket using the published identity. Current consumer source already inherits the browser image through moving `latest`/`zh` defaults, but it does not itself declare Ubuntu/Python, so its later work is dependency adoption, rebuild, testing, and any approved tag-policy update—not duplication of the base implementation.

## Notes For Downstream Architecture Design Or Direct Implementation

- Realize SCN-001 through SCN-004 without changing the approved build, tag, launch, port, user, variant, platform, or profile contracts.
- Begin from the explicit official `ubuntu:24.04` base semantics; do not substitute a floating or third-party image.
- Validate every remote package source against Noble and both target architectures. Static availability evidence does not replace clean BuildX validation.
- If REQ-007 is approved, use Noble-native Python 3.12; remove Python 3.11 path assumptions; preserve websockify and `uv` behavior; and respect Ubuntu's supported system-Python/pip isolation model.
- Treat any need to change service lifecycle, external contracts, persistence invariants, security boundaries, deployment topology, or ownership as downstream `Design Impact` or `Requirement Gap`, not as implicit authorization.
- Docker was unavailable during requirements investigation, so no build/runtime success is claimed here.
- Publish and record the exact immutable default/`zh` tags and per-platform manifest identities before the server-adoption ticket begins.
- Do not change `/home/autobyteus/workspace/autobyteus-workspace` source in this browser ticket. The follow-up brief records the dependency trigger and observed consumer surfaces.
- Route: `Direct Requirements-to-Implementation`; preliminary size `Medium`, risk `Low`, with no structural-impact trigger found. Architecture design artifacts are not applicable unless implementation returns evidence of design impact.
