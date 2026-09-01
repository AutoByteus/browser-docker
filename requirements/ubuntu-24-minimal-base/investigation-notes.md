# Requirements Investigation Notes

## Investigation Meta

- Request / ticket: `BRD-UBUNTU24-001`
- Workspace root: `/home/autobyteus/workspace/browser-docker`
- Repository mode: `Git`
- Task worktree / branch: Dedicated branch `requirements/ubuntu-24-minimal-base` in the supplied repository workspace
- Base or reference revision: `2bc0b4a` (`main` / `origin/main` at intake)
- Bootstrap result: Clean repository confirmed; dedicated task branch created before deeper investigation.
- Bootstrap blocker: None.
- Current requirements revision ID: `RER-001`
- Investigation status: Complete for product review; executable Docker build/runtime validation unavailable in this environment and assigned downstream after approval.

## Initial Request And Clarifications

- Original request: “the base server docker image version uses ubunt 22 something, but its too old. we need to use 24 stable version, of cousrse the mininal one. the browser docker project is here /home/autobyteus/workspace/browser-docker basically current base docker uses too low ubuntu version”
- Clarifications received: Repository location and desired Ubuntu major/minor family were supplied directly.
- User-supplied facts and constraints: Current base is an Ubuntu 22 release; use a stable Ubuntu 24 minimal base; change applies to the browser Docker project.
- Initial ambiguity: Whether “minimal” means the official minimal Ubuntu OCI rootfs or a broader pruning of installed application packages. The proposed requirement baseline selects the former and exposes that decision for approval.

## Product And Domain Understanding

- Product area: Multi-architecture browser/desktop Docker image with Chromium, XFCE, TigerVNC, websockify, remote debugging, developer runtimes/tools, and an optional Chinese locale/input variant.
- Affected actors or systems: Image maintainers, Docker BuildX/registry publishing, container runtimes, downstream images/users, AMD64/ARM64 platforms.
- Existing user or operational purpose: Build, publish, and run a reusable browser test environment with VNC and Chromium remote-debugging access.
- Relevant terminology: Ubuntu 24.04 LTS is Noble Numbat. Canonical documents Ubuntu OCI images as built from a minimal, container-tailored rootfs; this differs from minimizing the entire final application image after Chromium/XFCE/tools are installed.

## Source Log

| Date | Source Type (`Code`/`Doc`/`Runtime`/`Data`/`Contract`/`Web`/`User`/`Command`/`Other`) | Exact Source / Command / Query | Why Consulted | Relevant Finding | Follow-Up |
| --- | --- | --- | --- | --- | --- |
| 2026-09-01 | User | Intake request in current conversation | Establish desired outcome and repository. | Explicit request to replace the too-old Ubuntu 22 base with a stable minimal Ubuntu 24 base. | Present interpretation for approval. |
| 2026-09-01 | Command | `git -C /home/autobyteus/workspace/browser-docker status --short --branch`; `git switch -c requirements/ubuntu-24-minimal-base` | Verify safe task isolation. | Supplied repository was clean on `main`; branch created from `2bc0b4a`. | Preserve branch until downstream route. |
| 2026-09-01 | Code | `/home/autobyteus/workspace/browser-docker/Dockerfile` | Identify current base and compatibility surface. | Line 2 is `FROM ubuntu:22.04`; image installs PPAs, packages, Python 3.11, Node.js 22, browser/desktop/VNC and variant dependencies. | Require a Noble build and runtime smoke test. |
| 2026-09-01 | Code | `/home/autobyteus/workspace/browser-docker/build-multi-arch.sh` | Determine supported build scenarios/contracts. | Default local build/load; `--push`; `--no-cache`; `--variant`; AMD64/ARM64; version and rolling variant tags. | Preserve command and tag behavior. |
| 2026-09-01 | Code | `base.conf`, `entrypoint.sh`, `start-vnc.sh`, `supervisord.conf`, `docker-compose*.yml`, `run-container.sh`, `disable-screensaver.sh` | Determine runtime behavior to preserve. | Existing service, user, port, persistent profile, recovery, environment, and launch contracts extend beyond the base declaration. | Acceptance criteria cover representative runtime outcomes. |
| 2026-09-01 | Doc | `/home/autobyteus/workspace/browser-docker/README.md` | Identify documented public/operational behavior. | README calls out Ubuntu 22.04 and documents default/`zh`, multi-arch, VNC/debugging, profile persistence, and recovery. | Require accurate 24.04 documentation while preserving other instructions. |
| 2026-09-01 | Command | `grep -RInE 'ubuntu:|Ubuntu 22|22\\.04|python3\\.11|dist-packages/websockify' --exclude-dir=.git .` | Find release- and runtime-specific assumptions. | Explicit 22.04 references exist only in Dockerfile and README; Python 3.11 is deliberately installed and its websockify path is explicitly configured. | Preserve Python 3.11; validate path on Noble. |
| 2026-09-01 | Command | `docker version`; `docker buildx version` | Determine available executable validation. | Docker/BuildX are not installed in the Requirements Engineer environment. | Downstream implementation/API-E2E environment must perform AC-003 through AC-008. |
| 2026-09-01 | Web | https://documentation.ubuntu.com/oci-registries/oci-reference/oci-image-configuration/ | Verify official image minimal/multi-arch semantics. | Canonical says Ubuntu OCI images use a minimal container-tailored rootfs and a multi-architecture image index; `ubuntu:24.04` resolves by architecture. | Supports REQ-002 and AC-002. |
| 2026-09-01 | Web | https://hub.docker.com/_/ubuntu and https://hub.docker.com/_/ubuntu/tags?name=24.04 | Verify Docker Official Image tag and platforms. | `ubuntu:24.04` is a maintained Docker Official Image tag with AMD64 and ARM64 entries and a small base layer. | Use explicit 24.04, not a floating `latest`. |
| 2026-09-01 | Web | https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa | Check Python 3.11 feasibility on Noble. | PPA lists Python 3.11 for Ubuntu 24.04/Noble, with successful AMD64/ARM64 builds. | Validate actual image build. |
| 2026-09-01 | Web | https://launchpad.net/~xtradeb/+archive/ubuntu/apps | Check current non-Snap Chromium source on Noble. | XtraDeb publishes Chromium packages for Noble as well as Jammy; historical and current Noble builds are shown. | Validate both repository architectures/variants during build. |
| 2026-09-01 | Web | https://github.com/nodesource/distributions/blob/master/DEV_README.md | Check Node.js 22 support. | NodeSource's matrix lists Ubuntu Noble with Node 22 support and AMD64/ARM64 DEB architectures. | Validate actual setup/install in clean build. |

## Relevant Existing Behavior And Supported Product Paths

| Behavior ID | Kind | Supported Trigger Or Governing Contract | Current Supported Product Behavior Path / Lifecycle | Current Outcome / Invariants | Evidence | Confidence / Unknown |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | Maintainer invokes `build-multi-arch.sh` using documented flags. | Script reads `VERSION`, chooses local or multi-platform mode, passes the variant build arg, builds `Dockerfile`, and applies stable tags. | Image is based on Ubuntu 22.04; default and `zh`, AMD64 and ARM64, and tag semantics are supported. | Build script, Dockerfile, README. | High confidence from source; current build not executed in this environment. |
| BEH-002 | System | Container is started via supported run script/Compose contract. | Entrypoint prepares runtime/profile state; Supervisor starts DBus, TigerVNC, XFCE, optional fcitx5, Chromium, socat, and websockify. | Browser desktop and remote endpoints operate as non-root `vncuser`; profile state is persisted by documented volume usage. | Dockerfile, entrypoint, supervisor configs, scripts, Compose, README. | High source confidence; runtime not executed here. |
| BEH-003 | Contract | Maintainer/user reads repository docs or inspects image identity. | README presents the image feature set and Ubuntu version. | Current published statement is Ubuntu 22.04. | README line 6; Dockerfile line 2. | High. |

## Relevant Codebase And Technical Facts

| Path / Component / Contract | Current Responsibility Or Behavior | Requirement Implication | Architecture Question Deferred Downstream |
| --- | --- | --- | --- |
| `Dockerfile` | Selects Ubuntu 22.04; adds Universe, Deadsnakes, XtraDeb, and NodeSource; installs product dependencies and configures user/runtime. | Base must become official Ubuntu 24.04; Noble compatibility must preserve named outcomes. | If compatibility requires structural runtime/service changes rather than bounded install/path adjustments, downstream must escalate. |
| `build-multi-arch.sh` | Owns AMD64/ARM64 build and tagging for default/variant images. | Both platforms/variants are acceptance requirements. | None expected; preserve existing contract. |
| `base.conf` | Hard-codes a Python 3.11 websockify data path and supervises runtime services. | Python 3.11/websockify behavior and actual Noble path need validation. | Whether a path adjustment is required is implementation evidence, not a new behavior decision. |
| `README.md` | States Ubuntu 22.04 and documents supported product/operational behavior. | Version statement must be synchronized; surrounding behavior is preservation evidence. | None. |
| Run/Compose/entrypoint scripts | Define user-visible ports, volume, environment, recovery, and startup behavior. | Representative behavior must be smoke tested after distribution change. | Escalate only if Noble makes current structural surfaces insufficient. |

## Structural And Payload Surface Inventory

### Payload Or Content Surfaces

- Files, records, documents, catalogs, fixtures, or generated payloads: README Ubuntu version statement.
- Existing readers, writers, or contracts that consume them: Repository maintainers and image consumers.
- Evidence paths: `/home/autobyteus/workspace/browser-docker/README.md`.

### Structural Surfaces

- Runtime modules, shared interfaces, routes, APIs, persistence boundaries, security/concurrency controls, deployment configuration, or ownership boundaries: Dockerfile base/dependency configuration; BuildX multi-platform script; supervisor service graph; entrypoint; run/Compose configuration; Chromium profile volume contract.
- Existing structural surfaces that can support the approved behavior: The single existing Dockerfile already centralizes the base image and dependency install for both variants and platforms. Build and runtime contracts do not require a new subsystem or interface merely to select Noble.
- Evidence paths: `Dockerfile`, `build-multi-arch.sh`, `base.conf`, `entrypoint.sh`, `start-vnc.sh`, `docker-compose.yml`, `docker-compose.chrome-vnc.yml`, `run-container.sh`.

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
| Deadsnakes | Noble Python 3.11 / Launchpad PPA | Preserve Python 3.11 for AMD64/ARM64. | Launchpad PPA/package build pages. | Untrusted third-party PPA disclaimer and remote availability. |
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
| `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` | Requirements Engineer | Durable requirements-round history. | RER-001 baseline. | All | Current | Awaiting user approval. |

## Assumptions, Unknowns, And Risks

| ID | Type (`Assumption`/`Unknown`/`Risk`) | Description | Why It Matters | Resolution / Owner | Status |
| --- | --- | --- | --- | --- | --- |
| ASM-001 | Assumption | “24 stable” means explicit Ubuntu 24.04 LTS. | Prevents selecting a floating or non-LTS base. | User approval. | Open. |
| ASM-002 | Assumption | “minimal” applies to the official base rootfs, not feature/package pruning. | Package pruning could break current product behavior and is a larger scope. | User approval. | Open. |
| RISK-001 | Risk | Noble can change dependency versions, library behavior, or filesystem locations even when packages exist. | A one-line base change may build but still regress runtime services. | Full AC-003–AC-008 validation / downstream engineering. | Open until validated. |
| RISK-002 | Risk | Deadsnakes, XtraDeb, NodeSource, and PyPI/npm are remote mutable dependencies. | Clean/multi-platform builds can fail independently of repository code. | Downstream validation must distinguish repository defects from external availability. | Existing risk. |
| UNK-001 | Unknown | Actual clean default/`zh` AMD64/ARM64 build and runtime results on Noble. | Required to claim delivery. | Implementation and API/E2E teams with Docker/BuildX. | Open. |

## Requirement Implications

The direct request establishes Ubuntu 24.04 LTS as the intended base release. Canonical's official `ubuntu:24.04` OCI image already supplies the requested minimal container rootfs and multi-architecture resolution, so no unofficial “minimal” base is needed. The repository's behavior is much broader than the base line: package sources, Python 3.11/websockify path coupling, two variants, two architectures, and multiple supervised services mean success must include clean builds and runtime smoke tests. Because no feature removal was requested, the package treats current documented capabilities as preservation requirements and excludes final-image package pruning.

## Notes For Downstream Architecture Design Or Direct Implementation

- Realize SCN-001 through SCN-004 without changing the approved build, tag, launch, port, user, variant, platform, or profile contracts.
- Begin from the explicit official `ubuntu:24.04` base semantics; do not substitute a floating or third-party image.
- Validate every remote package source against Noble and both target architectures. Static availability evidence does not replace clean BuildX validation.
- Preserve Python 3.11 and verify the websockify asset path rather than assuming Jammy and Noble layouts match.
- Treat any need to change service lifecycle, external contracts, persistence invariants, security boundaries, deployment topology, or ownership as downstream `Design Impact` or `Requirement Gap`, not as implicit authorization.
- Docker was unavailable during requirements investigation, so no build/runtime success is claimed here.
