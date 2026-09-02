# Requirements Document

## Document Status

- Status: `Approved — revised after downstream Requirement Gap / Design Impact`
- Current requirements revision ID: `RER-007`
- Request / ticket: `BRD-UBUNTU24-001`
- Requirements owner: Solution Designer (`/solution_designer`) for downstream re-entry; original baseline owned by Requirements Engineer (`/requirements_engineer`)
- Date: 2026-09-01
- Approval state and reference: The first browser-image ticket was explicitly approved on 2026-09-01. During downstream re-entry after `IR-004`, the user explicitly superseded the Python 3.12 choice with: “i would still use 3.13, because main branch has already tested so i believe they have a reason why they use 3.13”. `RER-007` therefore approves Python 3.13 while preserving release `1.4.0`/`1.4.0-zh`, Ubuntu 24.04, all other ticket-one contracts, and deferred server adoption.

## Problem And Desired Outcome

- Problem: The ticket began because the browser Docker image used Ubuntu 22.04. The integrated candidate at `cc30abf` now uses Ubuntu 24.04 but intentionally retained Python 3.12 from the superseded requirements basis, while current `origin/main` had already validated and published Python 3.13 plus the Supervisor 4.3.0 compatibility fix. The user has now required Python 3.13 for the Ubuntu 24.04 release.
- Affected actors or systems: Maintainers who build and publish `autobyteus/chrome-vnc`; downstream users and images that run the default or `zh` variants on AMD64 or ARM64.
- Desired outcome: In the first, independently deliverable browser-image ticket, build the browser image from the official minimal Ubuntu 24.04 LTS OCI base, expose Python 3.13 as the supported `python3`/`python` developer runtime using the tested Deadsnakes release source for Noble, retain a Python 3.13-compatible Supervisor and isolated Python-installed operational tools, preserve all other contracts, and publish version `1.4.0`/`1.4.0-zh` to Docker Hub. Only after that release is verified will a separate server-adoption ticket update and validate AutoByteus server images against the published base.
- Observable definition of success: New default and `zh` browser image versions are available on Docker Hub for AMD64 and ARM64, report Ubuntu 24.04 and Python 3.13 through the supported developer commands, run Supervisor 4.3.0 plus websockify/`uv` without Python compatibility failures, and retain the documented browser-image behavior. The release identity and evidence are sufficient to start the separate server-adoption ticket.

## Relevant Current And Desired Behavior

| Behavior ID | Kind (`User`/`System`/`Operational`/`Contract`) | Related Scenario IDs | Evidence-Backed Current Behavior | Desired Behavior | Intentionally Preserved Behavior | Investigation Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | SCN-001, SCN-002 | Integrated candidate `cc30abf` starts from `ubuntu:24.04`, installs common dependencies plus variant-specific packages, and preserves local or published AMD64/ARM64 tags, but still selects the superseded Python 3.12 runtime. | The supported build retains the official minimal `ubuntu:24.04` LTS OCI base, selects Python 3.13 from the Deadsnakes Noble repository, and completes for both variants and supported architectures. | Build flags, release `1.4.0`, tag semantics, default/`zh` variants, AMD64/ARM64 support, and use of the official Ubuntu base remain unchanged. | Current `Dockerfile`; `build-multi-arch.sh`; `IR-004`; `cc30abf`; Canonical OCI and Launchpad evidence. |
| BEH-002 | System | SCN-003 | Integrated candidate `cc30abf` runs as `vncuser`, exposes the preserved XFCE/TigerVNC/Chromium, debugging, websockify, profile, locale/input, and tooling surfaces, but currently exposes Noble-native Python 3.12 and distribution Supervisor. Current `origin/main` separately proved Python 3.13 from Deadsnakes and pip-installed Supervisor 4.3.0 on Ubuntu 22.04. | The Ubuntu 24.04 image exposes Python 3.13 as `python3`/`python`; runs Supervisor 4.3.0, websockify, and `uv` from one isolated Python 3.13 tools environment through stable `/usr/local` commands/assets; and preserves every other runtime outcome. | Existing configured UID/GID, dynamic XDG/DBus paths, ports 5900/6080/9223, Chromium/VNC services, `gh`, Node.js 22, Yarn, default English locale, `zh` input, `AUTOBYTEUS_NODE_PROFILE=mobile-safe`, and persistent-profile/recovery behavior remain supported. | Current integrated sources; main commits `6aa8421` and `410b1f4`; Python tooling ticket artifacts; Noble Docker probes retained under `evidence/`. |
| BEH-003 | Contract | SCN-004 | Repository documentation identifies Ubuntu 22.04 as an image feature. | Repository documentation identifies Ubuntu 24.04 LTS and the official Ubuntu OCI base as minimal. | Other documented commands and behavior remain accurate. | `README.md:1-120`; Docker Official Image and Canonical OCI documentation. |

## Stakeholders, Actors, And Outcomes

| Actor / Stakeholder | Goal Or Responsibility | Required Outcome | Important Constraint |
| --- | --- | --- | --- |
| Image maintainer | Build and publish a supported browser container from a current LTS base. | Default and `zh` builds use Ubuntu 24.04 and pass build/runtime checks. | Preserve existing build flags and tag scheme. |
| Downstream image/container user | Continue using the browser/VNC environment after the base upgrade. | Existing launch surfaces and documented tools remain available. | No intentional product-feature removal or contract break is authorized. |
| Multi-architecture consumer | Pull or build the appropriate image on AMD64 or ARM64. | Ubuntu 24.04-based images remain available for both supported architectures. | The chosen official base and required dependencies must support both architectures. |

## Scope Guardrail (Mandatory)

### In-Scope Use Cases

- `UC-001`: Build the default image on Ubuntu 24.04 LTS for the local architecture.
- `UC-002`: Build/publish default and `zh` variants for AMD64 and ARM64.
- `UC-003`: Start an upgraded image and use its existing browser, desktop, VNC, remote-debugging, websockify, locale, and persistent-profile capabilities.
- `UC-004`: Read accurate repository documentation about the Ubuntu base release.
- `UC-005`: Use Python 3.13 as the image's `python3`/`python` developer runtime while retaining Python-installed Supervisor 4.3.0, websockify, and `uv` through stable operational paths.
- `UC-006`: Publish a new immutable browser-image version and the existing applicable rolling tags to Docker Hub for the default and `zh` variants after validation.

### Out Of Scope

- Moving to Ubuntu 24.10, 25.04/25.10, 26.04, `latest`, or another distribution.
- Broad package/runtime upgrades unrelated to the approved Ubuntu 24.04/Python 3.13 alignment, including Python 3.14 or later.
- Removing existing installed utilities or desktop/browser features to shrink the final application image.
- Changing registry/repository names, image-tag policy, supported architectures, exposed ports, runtime user, security options, or container orchestration behavior.
- Changes to AutoByteus server/all-in-one Dockerfiles, build scripts, Compose configuration, release workflow, or published server images; these belong to a separate follow-up ticket after the browser base release is verified.
- Migration or forced recreation of already-deployed downstream containers.

### Non-Goals

- Producing the smallest possible final Chromium/XFCE image.
- Replacing third-party package sources solely because they are third-party.
- Redesigning the image or service graph beyond the bounded Python 3.13/Supervisor compatibility correction; changing service ordering or supported startup behavior.
- Combining the browser-base release and downstream server adoption into one implementation/delivery ticket.

### Preserved Behavior Boundary

- BEH-001 through BEH-003, AC-003 through AC-009, and AC-011 through AC-012 remain preservation boundaries. AC-010 and AC-013 define the superseding Python 3.13/tooling behavior. “Minimal” governs the Ubuntu base root filesystem; it does not authorize pruning the image's current installed feature set.

### Review Authority

- Every blocking `Design Impact` or implementation-correction finding must cite an approved requirement, acceptance criterion, or preserved-behavior ID that it protects.
- A finding that would introduce new product behavior, policy, threat model, migration obligation, compatibility promise, or operational contract is a `Requirement Gap`; it requires explicit user approval before becoming authoritative.
- An adjacent concern outside the approved boundary may be recorded as a non-blocking risk, recommendation, or separate-ticket candidate. It is not a required design correction.
- A downstream reviewer comment does not amend this requirements basis. The Requirements Engineer must update the canonical requirements and obtain renewed user approval before a scope-changing proposal can govern design or implementation.

## Requirements

| Requirement ID | Requirement | Related Behavior IDs | Priority / Criticality | Rationale | Source / Decision Reference |
| --- | --- | --- | --- | --- | --- |
| REQ-001 | The browser Docker image shall use Ubuntu 24.04 LTS, rather than Ubuntu 22.04, as its base operating-system release. | BEH-001 | Must | Direct user request. | User request, 2026-09-01. |
| REQ-002 | The Ubuntu base shall be Canonical's official Ubuntu 24.04 OCI image, which is built from a minimal container-tailored root filesystem. | BEH-001 | Must | Interprets “the minimal one” without introducing a third-party or custom base. | User request; Canonical OCI docs; Docker Official Image listing. |
| REQ-003 | The upgrade shall preserve successful default and `zh` image builds for both AMD64 and ARM64. | BEH-001 | Must | Existing supported build and variant contract. | `build-multi-arch.sh`; `README.md`. |
| REQ-004 | Except for the Python version change in REQ-007, the upgraded image shall preserve the currently documented browser, desktop, VNC, websockify, remote-debugging, runtime/tooling, locale, input-method, user, port, and persistent-profile outcomes. | BEH-002 | Must | The request concerns base/runtime modernization, not removal of existing capabilities. | Current repository sources and docs; user Python follow-up. |
| REQ-005 | Any compatibility adjustments required by Ubuntu 24.04 shall remain limited to realizing REQ-001 through REQ-004 and shall not intentionally change unrelated public or operational behavior. | BEH-001, BEH-002 | Must | Prevents scope drift during distribution compatibility work. | Scope decision in RER-001. |
| REQ-006 | Repository documentation shall state Ubuntu 24.04 LTS and shall not continue to claim Ubuntu 22.04 for the built image. | BEH-003 | Must | Published usage documentation must match the image. | `README.md:6`. |
| REQ-007 | The upgraded image shall use Python 3.13 as its supported `python3` and `python` developer runtime on Ubuntu 24.04 for both AMD64 and ARM64. Python-installed operational tools shall use a Python 3.13-compatible isolated environment, and the image shall run Supervisor 4.3.0 rather than the incompatible Ubuntu 22.04-era Supervisor path. | BEH-002 | Must | The user explicitly superseded Python 3.12 in favor of the already-tested main-branch Python 3.13 direction. Isolation prevents replacement of Noble's distribution-owned Python runtime and gives Supervisor/websockify/`uv` one coherent Python owner. | User superseding decision on 2026-09-01; main commits `6aa8421`/`410b1f4`; Noble Deadsnakes and Docker-probe evidence. |
| REQ-008 | After all browser-image validation passes, the first ticket shall publish new default and `zh` image versions to Docker Hub for both AMD64 and ARM64, retaining the repository's immutable-version and rolling-tag conventions. | BEH-001 | Must | The separate server ticket requires a verified, remotely available base artifact before it can safely adopt the upgrade. | User sequencing decision on 2026-09-01; current build script and README release contract. |
| REQ-009 | AutoByteus server and all-in-one consumer changes shall be handled in a separate follow-up ticket that begins only after the new browser-image version and manifests are verified on Docker Hub. | BEH-001, BEH-002 | Must | Preserves dependency order, independent validation, and rollback clarity across repositories. | User sequencing decision on 2026-09-01; consumer-source investigation. |

## Acceptance Criteria

| Acceptance-Criteria ID | Related Requirement IDs | Related Behavior / Scenario IDs | Preconditions / Trigger | Observable Expected Outcome | Important Alternate Or Failure Outcome | Verification Intent |
| --- | --- | --- | --- | --- | --- | --- |
| AC-001 | REQ-001, REQ-002 | BEH-001 / SCN-001 | Inspect the effective base declaration and/or a built image. | It resolves to the official `ubuntu:24.04` image, and `/etc/os-release` in the built image reports Ubuntu 24.04 LTS (`VERSION_ID="24.04"`). | A floating `ubuntu:latest`, a non-LTS 24.x release, a third-party base, or Ubuntu 22.04 fails. | Source inspection plus container command. |
| AC-002 | REQ-002 | BEH-001 / SCN-001 | Verify the selected upstream image. | The base is Canonical's Docker Official Ubuntu OCI image, documented as constructed from a minimal container-oriented root filesystem. | A separate heavyweight server/desktop base or unofficial “minimal Ubuntu” image fails. | Upstream-authority check and image metadata inspection. |
| AC-003 | REQ-003, REQ-005 | BEH-001 / SCN-001 | Run a clean local default build on a supported local architecture. | The build completes without relying on cached Ubuntu 22.04 layers. | Missing Noble packages/repositories or hard-coded Jammy assumptions fail the build and must be corrected within scope. | `./build-multi-arch.sh --no-cache` in an environment with Docker BuildX. |
| AC-004 | REQ-003, REQ-005 | BEH-001 / SCN-002 | Run clean multi-architecture publication-equivalent builds for default and `zh`. | Both variants complete for `linux/amd64,linux/arm64`; manifests contain both platforms. | An architecture- or variant-specific dependency failure is a release blocker. | BuildX builds without publishing where possible, then `docker buildx imagetools inspect` for published/repository-local validation. |
| AC-005 | REQ-004, REQ-005 | BEH-002 / SCN-003 | Start the default image through the supported run/Compose surface. | The container remains running; TigerVNC/XFCE, Chromium, socat remote debugging, and websockify become available on their existing ports; Chromium can render a page. | Service crash-loop, missing executable/library, or unreachable existing endpoint fails. | Container health/process/log inspection, VNC/browser probe, port checks. |
| AC-006 | REQ-004, REQ-005, REQ-007 | BEH-002 / SCN-003 | Inspect runtime and tool contracts in a started default image and a configured custom-identity image. | `vncuser` and default/custom UID/GID operation work; `python3` and `python` resolve through the supported public command paths and report Python 3.13; `gh`, Node.js 22, Yarn, `uv`, and all currently documented utilities are usable; `en_US.UTF-8` is generated. | Python 3.12 remaining as the selected developer runtime, Python 3.14+, configured-identity regression, or loss of named tooling fails. | Shell resolution/version/identity/locale checks and representative command probes on both architectures. |
| AC-007 | REQ-003, REQ-004 | BEH-002 / SCN-003 | Start the `zh` image and exercise its documented locale/input behavior. | Chinese fonts/locales and fcitx5 are present; English remains default; documented Chinese Pinyin selection remains available. | Default input behavior regression or missing `zh` capability fails. | Package/locale/config checks plus VNC interaction smoke test. |
| AC-008 | REQ-004, REQ-005 | BEH-002 / SCN-003 | Recreate a container using the same Chromium profile volume. | Existing profile state persists and stale-profile-lock recovery remains effective. | Profile data loss or regression of the supported recovery behavior fails. | Existing documented restart/recreate scenario with a test profile. |
| AC-009 | REQ-006 | BEH-003 / SCN-004 | Review repository-facing documentation after the change. | Ubuntu references consistently identify 24.04 LTS; build/run instructions remain accurate. | Any active claim that the resulting image is Ubuntu 22.04 fails. | Repository text search and documentation review. |
| AC-010 | REQ-007 | BEH-002 / SCN-003 | Inspect Python source, command resolution, and isolated tools in each built target. | Python 3.13 packages resolve from the stable Deadsnakes PPA for Ubuntu Noble on AMD64 and ARM64; public `python3`/`python` select `/usr/bin/python3.13` through `/usr/local` without replacing Noble's distribution-owned `/usr/bin/python3`; `/opt/browser-tools` is created with Python 3.13 and owns the pip-installed operational tools. | Missing target-architecture packages, changing `/usr/bin/python3` away from Noble's distribution interpreter, global pip mutation, or a Python-version-specific public asset path fails. | APT policy/source and `dpkg` checks; path/symlink/interpreter/venv inspection on both target platforms. |
| AC-011 | REQ-008 | BEH-001 / SCN-002 | Browser-image default and `zh` builds and runtime checks have passed. | Docker Hub exposes `1.4.0`, `latest`, `1.4.0-zh`, and `zh`; each published manifest contains `linux/amd64` and `linux/arm64`; runtime identity from every published platform/variant reports Ubuntu 24.04, Python 3.13, and Supervisor 4.3.0. | Missing platform/variant, mismatched tag contents, stale Python/Supervisor identity, or publication before validation fails. | Docker Hub/BuildX manifest inspection and pull/run verification by immutable tag or digest. |
| AC-012 | REQ-009 | BEH-001, BEH-002 / SCN-005 | The published browser-image artifacts satisfy AC-011. | The browser ticket records exact immutable tags/digests and release evidence, and the separate server-adoption ticket can use that identity as its dependency input without changing server source in this ticket. | Starting server adoption against an unverified local-only or floating-only base fails the sequencing requirement. | Delivery artifact review and follow-up ticket intake check. |
| AC-013 | REQ-004, REQ-005, REQ-007 | BEH-002 / SCN-003 | Start the image through its normal entrypoint and inspect Python-installed operational paths. | `/usr/local/bin/supervisord` and `/usr/local/bin/supervisorctl` resolve to the Python 3.13 `/opt/browser-tools` environment; Supervisor reports 4.3.0, parses and runs the real configuration without the `pkgutil.ImpImporter` crash; `/usr/local/bin/websockify` and `/usr/local/bin/uv` resolve to the same environment; `/usr/local/share/websockify` resolves to valid web assets; VNC/websockify/DevTools remain reachable. | Mixed Supervisor providers, `/usr/bin/supervisord`, the Python 3.13 compatibility traceback, broken/version-specific web asset paths, or failed runtime services fail. | Source/path/version inspection plus normal-entrypoint Supervisor, service, HTTP/WebSocket, and DevTools probes in the integrated matrix. |

## Relevant Scenarios And Journeys

| Scenario ID | Kind (`User`/`System`/`Operational`/`Contract`) | Actor / Initiator / Governing Contract | Coherent Goal Or Governing Event | Supported Trigger / Entry Surface | Starting Condition | Product-Level Steps Or Event Sequence | Expected Outcome | Supported Alternate / Error Behavior | Scenario Validity | Independent Evidence / Decision Reference | Related Requirement / AC IDs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SCN-001 | Operational | Image maintainer | Produce a local browser image from the approved LTS base. | `./build-multi-arch.sh` with its default/load or no-cache flow. | Docker BuildX is available; repository is checked out. | Maintainer starts a default build; the base and dependencies resolve; the image is loaded; maintainer verifies OS/runtime identity. | A runnable default Ubuntu 24.04-based image is available locally under existing tags. | Build failure is explicit and no incomplete image is treated as successful. | Supported Normal Scenario | `build-multi-arch.sh`; `README.md`; user request. | REQ-001–REQ-005; AC-001–AC-003, AC-005–AC-006. |
| SCN-002 | Operational | Image maintainer | Produce release-equivalent images for every supported platform and variant. | `./build-multi-arch.sh --push` and `--variant zh --push`, or a non-publishing equivalent validation. | Registry/build environment supports AMD64 and ARM64. | Maintainer builds default and `zh`; BuildX assembles both platforms; image manifests are inspected. | Both variants support AMD64 and ARM64 using existing tag semantics. | Any platform/variant failure blocks publication. | Supported Normal Scenario | `build-multi-arch.sh`; multi-architecture README contract. | REQ-003–REQ-005; AC-004, AC-007. |
| SCN-003 | System | Container runtime initiated by a downstream user/Compose | Run the existing browser/VNC and developer-runtime environment on the upgraded image. | `run-container.sh`, repository Compose configuration, or a shell in the started container. | An upgraded image is available; existing ports/profile volume are configured. | Runtime starts the container through `/usr/local/bin/supervisord`; the compatible Supervisor graph starts services; user connects through existing VNC/debugging surfaces; public Python commands resolve to 3.13; isolated websockify/`uv`, optional `zh` behavior, configured identity, mobile-safe Chrome mode, and profile lifecycle operate as documented. | Current product-visible and operational capabilities remain available on Ubuntu 24.04 with Python 3.13 and no Supervisor compatibility crash. | Existing startup/recovery logic handles supported stale VNC and Chromium lock conditions; other failures are observable in logs/exit state. | Supported Normal Scenario | Integrated sources; main Python 3.13/Supervisor evidence; Noble probes; user superseding decision. | REQ-004–REQ-005, REQ-007; AC-005–AC-008, AC-010, AC-013. |
| SCN-004 | Contract | Repository documentation contract | Identify the OS baseline accurately to maintainers and users. | Reading `README.md` and inspecting the image. | Upgrade is implemented. | Reader sees Ubuntu 24.04 LTS; runtime inspection agrees. | Documentation and runtime identify the same base release. | A stale 22.04 claim is rejected. | Supported Normal Scenario | Current README feature statement and user request. | REQ-006; AC-009. |
| SCN-005 | Operational | Browser-image maintainer, then server-image maintainer | Release the dependency before adopting it downstream. | Browser-image validation completes and the maintainer invokes the supported Docker Hub publication flow. | Browser image changes are ready; server consumer source remains unchanged in this ticket. | Maintainer publishes and verifies new default/`zh` multi-arch browser tags; records immutable identities; closes the browser ticket; a separate server ticket then uses those identities to update/rebuild its consumers. | Server adoption starts from a verified, recoverable upstream artifact. | If browser publication or verification fails, the server ticket does not begin adoption. | Supported Normal Scenario | User sequencing decision; `browser-docker/build-multi-arch.sh`; AutoByteus consumer Dockerfiles/build workflow. | REQ-008–REQ-009; AC-011–AC-012. |

## UI, Interaction, And Experience Requirements

- Applicable: `No`
- Linked UI/UX or interaction supplement: `N/A — not applicable`
- Linked runnable prototype, separate prototype repository/root, UI/UX specification, and applicable support artifacts: `N/A — not applicable`
- Product prototype ticket record and folder (externally owned): `N/A — not applicable`
- Prototype revision or commit: `N/A — not applicable`
- UI/UX user-confirmation reference: `N/A — not applicable`
- Approved visual-reference baseline: `N/A — not applicable`
- Normative visual and interaction details, including the approved final references: `N/A — not applicable`
- Explicitly illustrative fixture content or permitted implementation variation: `N/A — not applicable`
- Required screens, states, transitions, feedback, responsive behavior, or accessibility outcomes: `N/A — not applicable`
- Explicitly unresolved product decisions: `N/A — not applicable`

## Quality And Non-Functional Requirements

| Quality ID | Area (`Performance`/`Reliability`/`Security`/`Privacy`/`Accessibility`/`Compliance`/`Operability`/`Compatibility`/`Other`) | Measurable Requirement Or Constraint | Conditions / Scope | Verification Intent |
| --- | --- | --- | --- | --- |
| QR-001 | Compatibility | Default and `zh` variants shall build and run on AMD64 and ARM64. | Clean Ubuntu 24.04-based builds. | AC-004 plus architecture-specific runtime smoke checks. |
| QR-002 | Reliability | The upgraded default image shall reach stable service operation rather than a supervisor crash loop. | Supported run/Compose configuration. | Observe service state/logs and exercise VNC, Chromium debugging, and websockify. |
| QR-003 | Operability | Existing build flags, tag derivation, ports, volumes, environment inputs, and launch commands shall remain usable. | Repository-supported build/run surfaces. | Source checks plus build/run probes. |
| QR-004 | Security | The selected Ubuntu release tag shall be explicit (`24.04`) rather than floating. | Base-image declaration. | Source inspection. |
| QR-005 | Compatibility | Python 3.13, Supervisor 4.3.0, websockify, and `uv` shall operate coherently on Ubuntu 24.04 for AMD64 and ARM64 without replacing Noble's distribution-owned `/usr/bin/python3`. | Default and `zh` variants. | Package-origin, interpreter ownership, isolated-tool, startup, and architecture-specific runtime checks. |

## Data Continuity And Acceptable Loss

- Persisted or external data affected: `No` by the image build itself; runtime Chromium profile state is an existing external volume contract that must be preserved.
- Data or state that must be preserved: Chromium profile volumes supplied through current run/Compose flows.
- Loss, reset, rebuild, or regeneration that is acceptable: Image build layers and disposable test containers may be rebuilt; persistent Chromium profile contents may not be silently discarded by this change.
- Retention, privacy, compliance, volume, downtime, or operational constraints: No new constraints stated.
- Unknowns requiring downstream investigation: None material to requirements; runtime validation must confirm profile ownership/lock recovery on Noble.

## External Contracts And Dependencies

| Contract / Dependency | Required Behavior Or Constraint | Evidence / Authority | Uncertainty Or Risk |
| --- | --- | --- | --- |
| Official Ubuntu OCI image | Use the explicit 24.04 LTS tag; retain minimal container rootfs and AMD64/ARM64 resolution. | Canonical OCI documentation; Docker Official Image listing. | Mutable release tag receives upstream security/rootfs refreshes; exact digest pinning was not requested. |
| Ubuntu Noble distribution Python | Noble's `/usr/bin/python3` remains distribution-owned for OS packages and scripts; it is not repointed to the selected developer interpreter. | Current `ubuntu:24.04` probe reports `/usr/bin/python3 -> python3.12`; Canonical package ownership. | Public developer commands must be selected through `/usr/local`, not `update-alternatives` over `/usr/bin/python3`. |
| Deadsnakes stable PPA | Supply `python3.13`, `python3.13-dev`, and `python3.13-venv` for Ubuntu Noble on AMD64 and ARM64. | Launchpad PPA declares Noble Python 3.13 support and successful AMD64/ARM64 builds; retained Docker probes resolved `3.13.15-1+noble1` on both target architectures. | This is an external, mutable, explicitly untrusted PPA; clean builds and package origin must be revalidated before publication. |
| PyPI Python operational toolchain | Install `supervisor==4.3.0`, websockify, and `uv` into a Python 3.13 virtual environment and expose stable commands/assets. | Main-branch Supervisor fix; prior published 1.3.8 evidence; current Noble design probe. | Unpinned websockify/`uv` remain mutable dependencies; executable validation must prove their current compatibility and asset path. |
| XtraDeb applications PPA | A real Debian-packaged `chromium` must remain available for Noble on supported architectures. | XtraDeb Launchpad package/build records show Noble Chromium publication. | Third-party PPA availability and package regressions remain existing dependency risks. |
| NodeSource 22.x repository | Node.js 22 packages must remain available for Ubuntu Noble and AMD64/ARM64. | NodeSource distribution support matrix. | Setup script and repository are remote mutable inputs. |
| Docker BuildX / OCI registry | Build/load or publish the existing supported image platforms and tags. | Repository build script and README. | Host Docker/BuildX is now available; final executable validation remains downstream and publication is Delivery-owned. |
| Docker Hub `autobyteus/chrome-vnc` repository | Publish and make verifiable `1.4.0`/`1.4.0-zh` plus current `latest`/`zh` rolling tags before downstream adoption. | Current image name/tag behavior in `build-multi-arch.sh`; user sequencing decision; resolved DEC-003. | DEC-003 is approved and resolved. Registry credentials and publication remain Delivery-owned, and publication is blocked until the revised implementation passes review and API/E2E. |
| AutoByteus server consumer repository | Treat the published browser release as an external input to a separate follow-up ticket. | `/home/autobyteus/workspace/autobyteus-workspace/autobyteus-server-ts/docker/Dockerfile.monorepo`; `/home/autobyteus/workspace/autobyteus-workspace/docker/Dockerfile.allinone`; build scripts, Compose, and release workflow. | Current consumers use moving `latest`/`zh` defaults; the follow-up ticket must decide deterministic adoption/pinning without being pre-implemented here. |

## Supplemental Artifacts

| Artifact Path | Purpose | Related Requirement / AC IDs | Status | Approval Applicability / State |
| --- | --- | --- | --- | --- |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/investigation-notes.md` | Canonical source, code, compatibility, and environment evidence. | All | Current | Informational evidence supporting the revised approval basis. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` | Requirements-round history. | All | Current | RER-007 records the user-approved Python 3.13 supersession. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | Durable brief for the separate server-adoption ticket that starts after verified browser-image publication; intake now requires Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 identities. | REQ-007–REQ-009; AC-011–AC-013 | Current — aligned in SR-002 | User-requested sequencing context; not authorization to modify server source in this ticket. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-probe.log` | Retained ARM64 Noble feasibility evidence for Python 3.13 plus isolated Supervisor/websockify/`uv`. | REQ-007; AC-006, AC-010, AC-013 | Current | Evidence only; approval N/A. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-amd64-availability.log` | Retained AMD64 Noble Python 3.13 package-availability evidence. | REQ-003, REQ-007; AC-004, AC-010 | Current | Evidence only; approval N/A. |

## Assumptions

| Assumption ID | Assumption | Why It Is Necessary | Validation Plan / Owner | Status |
| --- | --- | --- | --- | --- |
| ASM-001 | “24 stable version” means Ubuntu 24.04 LTS, not a floating `24`, `latest`, or a newer LTS. | Ubuntu version tags and release cadence make an explicit version necessary. | Approved as part of the complete first-ticket package on 2026-09-01. | Validated. |
| ASM-002 | “the minimal one” refers to Canonical's official minimal OCI base rootfs, not removal of the current browser/desktop/tool feature set. | The final product necessarily installs Chromium, XFCE, runtimes, and utilities, so final-image minimization would be a separate scope decision. | Confirmed directly by the user on 2026-09-01. | Validated. |
| ASM-003 | Other named runtimes remain preserved, but Python is intentionally selected as 3.13 through the existing Deadsnakes direction already proven on `origin/main`; Noble's distribution Python remains internally owned by the OS. | The user explicitly superseded the prior 3.12 choice because main had already tested 3.13. | User decision plus Noble AMD64/ARM64 package and ARM64 toolchain probes; downstream full build/runtime validation remains required. | Validated. |

## Open Decisions And Questions

| Decision / Question ID | Question | Why It Matters | Options / Evidence | Decision Owner | Status |
| --- | --- | --- | --- | --- | --- |
| DEC-001 | Does the approval basis correctly interpret “minimal” as the official minimal Ubuntu OCI base without pruning installed features? | A different interpretation would materially expand scope and change preserved behavior. | User confirmed that minimal refers to the base image itself. | User | Resolved 2026-09-01. |
| DEC-002 | Should the image select Python 3.12 or Python 3.13? | This determines repository origin, interpreter ownership, Supervisor compatibility, and tool isolation. | Superseded decision: Python 3.13. Use the stable Deadsnakes PPA for Noble, retain `/usr/bin/python3` as the distribution interpreter, and expose the developer runtime via `/usr/local`. The user explicitly chose 3.13 after main-branch validation. | User for version; Solution Designer for bounded installation approach | Resolved/superseded 2026-09-01. |
| DEC-003 | What immutable semantic version should identify the new browser-image release? | The first ticket must publish an exact dependency identity for the later server ticket. | Selected: `1.4.0` and `1.4.0-zh`, advancing current `1.3.6` for the Ubuntu/Python baseline change while retaining `latest`/`zh` rolling tags. Approved as part of the first-ticket package on 2026-09-01. | User | Resolved 2026-09-01. |

## Traceability

| Requirement ID | Behavior IDs | Acceptance-Criteria IDs | Scenario IDs | Supplemental / Prototype Evidence |
| --- | --- | --- | --- | --- |
| REQ-001 | BEH-001 | AC-001, AC-003 | SCN-001 | Investigation notes. |
| REQ-002 | BEH-001 | AC-001, AC-002 | SCN-001 | Canonical/Docker upstream evidence in investigation notes. |
| REQ-003 | BEH-001 | AC-003, AC-004, AC-007 | SCN-001, SCN-002 | Build script and README evidence. |
| REQ-004 | BEH-002 | AC-005–AC-008, AC-013 | SCN-003 | Runtime configuration/source and Supervisor compatibility evidence. |
| REQ-005 | BEH-001, BEH-002 | AC-003–AC-008, AC-013 | SCN-001–SCN-003 | Scope/preservation and compatible runtime-provider evidence. |
| REQ-006 | BEH-003 | AC-009 | SCN-004 | README evidence. |
| REQ-007 | BEH-002 | AC-006, AC-010, AC-013 | SCN-003 | User superseding decision; main Python 3.13/Supervisor evidence; Noble AMD64/ARM64 probes. |
| REQ-008 | BEH-001 | AC-004, AC-011 | SCN-002, SCN-005 | Build/release sources and user sequencing decision. |
| REQ-009 | BEH-001, BEH-002 | AC-012 | SCN-005 | Server consumer inventory and follow-up brief. |

## Downstream Architecture Input

- Approved scenario IDs and product-level behavior paths architecture must map: SCN-001 through SCN-005.
- Product and system constraints architecture must preserve: Explicit Ubuntu 24.04 LTS official minimal OCI base; public Python 3.13; Python 3.13-compatible Supervisor 4.3.0; stable isolated websockify/`uv`; default and `zh`; AMD64/ARM64; configured UID/GID and dynamic runtime paths; current browser/VNC/mobile-safe/other-runtime/port/profile behavior; version `1.4.0` and existing load/push/tag/publication contracts.
- Decisions intentionally deferred to architecture design: Exact separation of Noble's distribution interpreter from the public Python 3.13 developer runtime; the isolated Supervisor/websockify/`uv` owner and stable command/asset boundaries; clean removal of the stale Python 3.12/distribution-Supervisor target.
- Technical facts architecture should verify: Stable Deadsnakes Python 3.13 package availability on Noble AMD64/ARM64; public-path precedence without repointing `/usr/bin/python3`; Supervisor 4.3.0 compatibility and launch ownership; websockify/`uv` virtual-environment and stable asset paths; full integrated validation matrix.
- Known feasibility or integration risks: Deadsnakes and PyPI are mutable third-party dependencies; the ARM64 design probe passed and AMD64 package candidates exist, but full default/`zh`, AMD64/ARM64, configured-identity, runtime/profile/locale/input, tag/load/push, and publication validation must be rerun on the final implementation; Docker Hub publication must precede server adoption.

## Readiness Check

- Relevant current behavior is evidence-backed: `Yes`
- Desired and preserved behavior are explicit: `Yes`
- Scope and non-goals are clear: `Yes`
- Requirements and acceptance criteria are testable and traceable: `Yes`
- Applicable scenarios are covered with validity and evidence: `Yes`
- Prototype and supplemental evidence is integrated consistently: `Yes` — no prototype applies; investigation, revision, and follow-up brief are linked.
- Applicable UI/UX approval and final visual-reference basis are recorded: `N/A`
- Material assumptions and open decisions are visible: `Yes`
- User approval received: `Yes` — explicit first-ticket approval on 2026-09-01.
- Requirements package ready for downstream route: `Yes`
- Remaining blocker: Architecture review must pass the revised Python 3.13 design before implementation resumes. Delivery, publication, finalization, and server adoption remain blocked.

## Architecture Design Routing Assessment

- Assessment status: `Complete`
- Assessment owner and date: Solution Designer; 2026-09-01 downstream re-entry.
- Preliminary task size: `Medium`
- Preliminary architectural risk: `Medium`
- Structural surfaces reviewed: Docker base/dependency installation, multi-architecture build path, supervisor/runtime launch configuration, Compose/run contracts, profile volume contract.
- Payload/content surfaces reviewed: README OS-version statement.
- Structural-impact triggers: `Present`. The superseding interpreter decision changes Python source and command ownership, invalidates the current distribution-Supervisor selection, and requires one coherent isolated Python 3.13 operational-tool boundary while preserving Noble's OS interpreter. The external product and publication contracts remain unchanged.
- Evidence paths: current-worktree `investigation-notes.md`; `Dockerfile`; `base.conf`; `entrypoint.sh`; `build-multi-arch.sh`; `README.md`; `IR-004`; main commits `6aa8421`/`410b1f4`; Python tooling ticket artifacts; retained Noble probes under `requirements/ubuntu-24-minimal-base/evidence/`.
- Decision rationale: The repository remains structurally compact, but the old direct route is no longer sufficient because a user-approved runtime change intersects operating-system interpreter ownership, third-party interpreter sourcing, the Supervisor provider and entrypoint, Python-installed tools, and stable filesystem boundaries. An explicit design is required to prevent the unsafe hybrid of Noble Python 3.12, global Python 3.13 replacement, mixed Supervisor versions, or version-coupled web assets.
- Selected route: `Architecture Reviewer`, then Implementation Engineer after design approval.
- Outcome classification: `Requirement Gap resolved; Design Impact requires architecture review`
- Direct-route conditions all satisfied: `No — superseded by RER-007/SR-001`
- Architecture design and solution revision artifacts: `design-spec.md`; `solution-revision-record.md` (`SR-002`). `ARCH-REV-001` failed only on package-coherence finding `ARCH-F-001`; the supplement and stale DEC-003 statement are corrected and the package is pending architecture re-review.
- Downstream re-entry trigger: The stale Python 3.12 integrated candidate must not advance. Architecture review must decide readiness of the revised design; implementation then performs the clean-cut Python 3.13/tooling change and returns through code review and a complete integrated API/E2E matrix. After ticket-one AC-011 verification, ticket two re-enters separately using the follow-up brief.
