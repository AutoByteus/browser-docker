# Requirements Document

## Document Status

- Status: `Ready for Approval`
- Current requirements revision ID: `RER-003`
- Request / ticket: `BRD-UBUNTU24-001`
- Requirements owner: Requirements Engineer (`/requirements_engineer`)
- Date: 2026-09-01
- Approval state and reference: The user confirmed on 2026-09-01 that “minimal” refers to the base image itself; explicit approval of the complete requirements baseline is still pending.

## Problem And Desired Outcome

- Problem: The browser Docker image is built on Ubuntu 22.04, which the requester considers too old.
- Affected actors or systems: Maintainers who build and publish `autobyteus/chrome-vnc`; downstream users and images that run the default or `zh` variants on AMD64 or ARM64.
- Desired outcome: Build the browser image from the official minimal Ubuntu 24.04 LTS OCI base, align its developer Python with Ubuntu 24.04's supported Python 3.12, and preserve the image's other browser/VNC, runtime, locale-variant, and launch contracts.
- Observable definition of success: Built default and `zh` images report Ubuntu 24.04 and Python 3.12, build successfully for the supported architectures, and retain the documented services, other tools, ports, user, and runtime behavior.

## Relevant Current And Desired Behavior

| Behavior ID | Kind (`User`/`System`/`Operational`/`Contract`) | Related Scenario IDs | Evidence-Backed Current Behavior | Desired Behavior | Intentionally Preserved Behavior | Investigation Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | SCN-001, SCN-002 | A supported build starts from `ubuntu:22.04`, installs common dependencies plus variant-specific packages, and produces local or published AMD64/ARM64 image tags. | The same supported build starts from the official minimal `ubuntu:24.04` LTS OCI base and completes for both variants and supported architectures. | Build flags, tag semantics, default/`zh` variants, AMD64/ARM64 support, and use of the official Ubuntu image remain unchanged. | `Dockerfile:1-88`; `build-multi-arch.sh`; Canonical OCI image documentation; Docker Official Image listing. |
| BEH-002 | System | SCN-003 | A started image runs as `vncuser` and exposes the XFCE/TigerVNC/Chromium environment, remote debugging, websockify, persistent profile support, optional Chinese input behavior, and Python 3.11 installed from Deadsnakes. | Images built on Ubuntu 24.04 retain these product-visible and operational capabilities while the image's developer Python moves to Ubuntu 24.04's native Python 3.12. | Existing user/UID/GID behavior, ports 5900/6080/9223, Chromium/VNC services, Node.js 22, Yarn, `uv`, default English locale, `zh` option, and persistent profile behavior remain supported. | `Dockerfile`; `base.conf`; `entrypoint.sh`; `start-vnc.sh`; `docker-compose*.yml`; `run-container.sh`; `README.md`; Ubuntu Noble Python availability documentation. |
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
- `UC-005`: Use Python 3.12 as the image's `python3`/`python` developer runtime while retaining Python-installed runtime services.

### Out Of Scope

- Moving to Ubuntu 24.10, 25.04/25.10, 26.04, `latest`, or another distribution.
- Broad package/runtime upgrades unrelated to Ubuntu 24.04 alignment, including Python 3.13 or 3.14.
- Removing existing installed utilities or desktop/browser features to shrink the final application image.
- Changing registry/repository names, image-tag policy, supported architectures, exposed ports, runtime user, security options, or container orchestration behavior.
- Publishing, deployment, release-version selection, or downstream-image migration unless separately authorized.

### Non-Goals

- Producing the smallest possible final Chromium/XFCE image.
- Replacing third-party package sources solely because they are third-party.
- Redesigning the image, service supervision, or startup lifecycle.

### Preserved Behavior Boundary

- BEH-001 through BEH-003 and AC-003 through AC-009 are preservation boundaries. “Minimal” governs the Ubuntu base root filesystem; it does not authorize pruning the image's current installed feature set.

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
| REQ-007 | The upgraded image shall use Python 3.12 as its supported `python3` and `python` developer runtime, sourced from Ubuntu 24.04's official repositories, instead of the current Deadsnakes Python 3.11 runtime. | BEH-002 | Proposed Must | Python 3.12 is Ubuntu 24.04's native/default supported Python and avoids selecting a newer PPA-only interpreter that is outside Noble's official Python set. | User follow-up on 2026-09-01; Ubuntu Noble Python availability documentation. |

## Acceptance Criteria

| Acceptance-Criteria ID | Related Requirement IDs | Related Behavior / Scenario IDs | Preconditions / Trigger | Observable Expected Outcome | Important Alternate Or Failure Outcome | Verification Intent |
| --- | --- | --- | --- | --- | --- | --- |
| AC-001 | REQ-001, REQ-002 | BEH-001 / SCN-001 | Inspect the effective base declaration and/or a built image. | It resolves to the official `ubuntu:24.04` image, and `/etc/os-release` in the built image reports Ubuntu 24.04 LTS (`VERSION_ID="24.04"`). | A floating `ubuntu:latest`, a non-LTS 24.x release, a third-party base, or Ubuntu 22.04 fails. | Source inspection plus container command. |
| AC-002 | REQ-002 | BEH-001 / SCN-001 | Verify the selected upstream image. | The base is Canonical's Docker Official Ubuntu OCI image, documented as constructed from a minimal container-oriented root filesystem. | A separate heavyweight server/desktop base or unofficial “minimal Ubuntu” image fails. | Upstream-authority check and image metadata inspection. |
| AC-003 | REQ-003, REQ-005 | BEH-001 / SCN-001 | Run a clean local default build on a supported local architecture. | The build completes without relying on cached Ubuntu 22.04 layers. | Missing Noble packages/repositories or hard-coded Jammy assumptions fail the build and must be corrected within scope. | `./build-multi-arch.sh --no-cache` in an environment with Docker BuildX. |
| AC-004 | REQ-003, REQ-005 | BEH-001 / SCN-002 | Run clean multi-architecture publication-equivalent builds for default and `zh`. | Both variants complete for `linux/amd64,linux/arm64`; manifests contain both platforms. | An architecture- or variant-specific dependency failure is a release blocker. | BuildX builds without publishing where possible, then `docker buildx imagetools inspect` for published/repository-local validation. |
| AC-005 | REQ-004, REQ-005 | BEH-002 / SCN-003 | Start the default image through the supported run/Compose surface. | The container remains running; TigerVNC/XFCE, Chromium, socat remote debugging, and websockify become available on their existing ports; Chromium can render a page. | Service crash-loop, missing executable/library, or unreachable existing endpoint fails. | Container health/process/log inspection, VNC/browser probe, port checks. |
| AC-006 | REQ-004, REQ-005, REQ-007 | BEH-002 / SCN-003 | Inspect runtime and tool contracts in the started default image. | `vncuser` and UID/GID customization work; `python3` and `python` report Python 3.12; Node.js 22, Yarn, `uv`, and currently installed documented utilities are usable; `en_US.UTF-8` is generated. | Python 3.11 remaining as the selected developer runtime, use of an unapproved Python 3.13/3.14, or loss of named tooling fails. | Shell version/identity/locale checks and representative command probes. |
| AC-007 | REQ-003, REQ-004 | BEH-002 / SCN-003 | Start the `zh` image and exercise its documented locale/input behavior. | Chinese fonts/locales and fcitx5 are present; English remains default; documented Chinese Pinyin selection remains available. | Default input behavior regression or missing `zh` capability fails. | Package/locale/config checks plus VNC interaction smoke test. |
| AC-008 | REQ-004, REQ-005 | BEH-002 / SCN-003 | Recreate a container using the same Chromium profile volume. | Existing profile state persists and stale-profile-lock recovery remains effective. | Profile data loss or regression of the supported recovery behavior fails. | Existing documented restart/recreate scenario with a test profile. |
| AC-009 | REQ-006 | BEH-003 / SCN-004 | Review repository-facing documentation after the change. | Ubuntu references consistently identify 24.04 LTS; build/run instructions remain accurate. | Any active claim that the resulting image is Ubuntu 22.04 fails. | Repository text search and documentation review. |
| AC-010 | REQ-007 | BEH-002 / SCN-003 | Inspect Python origin and exercise Python-installed services/tools in the built image. | Python 3.12 resolves from Ubuntu Noble's official packages; websockify starts and serves its web assets; `pip`/`uv`-managed tooling is installed in a Noble-compatible manner. | Retaining Deadsnakes solely to supply Python, a broken hard-coded Python 3.11 path, or failed externally-managed-environment handling fails. | APT policy/source inspection, interpreter checks, and websockify/`uv` smoke tests. |

## Relevant Scenarios And Journeys

| Scenario ID | Kind (`User`/`System`/`Operational`/`Contract`) | Actor / Initiator / Governing Contract | Coherent Goal Or Governing Event | Supported Trigger / Entry Surface | Starting Condition | Product-Level Steps Or Event Sequence | Expected Outcome | Supported Alternate / Error Behavior | Scenario Validity | Independent Evidence / Decision Reference | Related Requirement / AC IDs |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SCN-001 | Operational | Image maintainer | Produce a local browser image from the approved LTS base. | `./build-multi-arch.sh` with its default/load or no-cache flow. | Docker BuildX is available; repository is checked out. | Maintainer starts a default build; the base and dependencies resolve; the image is loaded; maintainer verifies OS/runtime identity. | A runnable default Ubuntu 24.04-based image is available locally under existing tags. | Build failure is explicit and no incomplete image is treated as successful. | Supported Normal Scenario | `build-multi-arch.sh`; `README.md`; user request. | REQ-001–REQ-005; AC-001–AC-003, AC-005–AC-006. |
| SCN-002 | Operational | Image maintainer | Produce release-equivalent images for every supported platform and variant. | `./build-multi-arch.sh --push` and `--variant zh --push`, or a non-publishing equivalent validation. | Registry/build environment supports AMD64 and ARM64. | Maintainer builds default and `zh`; BuildX assembles both platforms; image manifests are inspected. | Both variants support AMD64 and ARM64 using existing tag semantics. | Any platform/variant failure blocks publication. | Supported Normal Scenario | `build-multi-arch.sh`; multi-architecture README contract. | REQ-003–REQ-005; AC-004, AC-007. |
| SCN-003 | System | Container runtime initiated by a downstream user/Compose | Run the existing browser/VNC and developer-runtime environment on the upgraded image. | `run-container.sh`, repository Compose configuration, or a shell in the started container. | An upgraded image is available; existing ports/profile volume are configured. | Runtime starts the container; supervisor starts services; user connects through existing VNC/debugging surfaces; Python commands resolve to 3.12; Python-installed services/tools, optional `zh` behavior, and profile lifecycle operate as documented. | Current product-visible and operational capabilities remain available on Ubuntu 24.04 with Python 3.12. | Existing startup/recovery logic handles supported stale VNC and Chromium lock conditions; other failures are observable in logs/exit state. | Supported Normal Scenario | `entrypoint.sh`; `start-vnc.sh`; `base.conf`; Compose/run scripts; README; user Python follow-up; Ubuntu Noble Python contract. | REQ-004–REQ-005, REQ-007; AC-005–AC-008, AC-010. |
| SCN-004 | Contract | Repository documentation contract | Identify the OS baseline accurately to maintainers and users. | Reading `README.md` and inspecting the image. | Upgrade is implemented. | Reader sees Ubuntu 24.04 LTS; runtime inspection agrees. | Documentation and runtime identify the same base release. | A stale 22.04 claim is rejected. | Supported Normal Scenario | Current README feature statement and user request. | REQ-006; AC-009. |

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
| QR-005 | Compatibility | The selected developer Python shall be Ubuntu 24.04's officially supported default Python 3.12 on both AMD64 and ARM64. | Default and `zh` variants. | Package-origin and interpreter checks in both platform builds. |

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
| Ubuntu Noble Python packages | Python 3.12 shall be the image's developer interpreter on AMD64 and ARM64. | Canonical's Noble availability table and Ubuntu package index identify Python 3.12 as the only/default official Noble Python. | Ubuntu's system-Python packaging rules require Noble-compatible `pip`/virtual-environment handling rather than assuming the current Deadsnakes `ensurepip` behavior. |
| Deadsnakes PPA | It currently supplies Python 3.11 but shall no longer be required solely for the selected Python runtime after REQ-007. | Current `Dockerfile`; Deadsnakes Launchpad PPA. | Removing the PPA must not accidentally affect an independently required package; current source inspection shows Python is its purpose. |
| XtraDeb applications PPA | A real Debian-packaged `chromium` must remain available for Noble on supported architectures. | XtraDeb Launchpad package/build records show Noble Chromium publication. | Third-party PPA availability and package regressions remain existing dependency risks. |
| NodeSource 22.x repository | Node.js 22 packages must remain available for Ubuntu Noble and AMD64/ARM64. | NodeSource distribution support matrix. | Setup script and repository are remote mutable inputs. |
| Docker BuildX / OCI registry | Build/load or publish the existing supported image platforms and tags. | Repository build script and README. | Docker is unavailable in the Requirements Engineer environment, so executable validation is downstream. |

## Supplemental Artifacts

| Artifact Path | Purpose | Related Requirement / AC IDs | Status | Approval Applicability / State |
| --- | --- | --- | --- | --- |
| `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/investigation-notes.md` | Canonical source, code, compatibility, and environment evidence. | All | Current | Informational evidence supporting this approval basis. |
| `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` | Requirements-round history. | All | Current | RER-001 awaiting approval. |

## Assumptions

| Assumption ID | Assumption | Why It Is Necessary | Validation Plan / Owner | Status |
| --- | --- | --- | --- | --- |
| ASM-001 | “24 stable version” means Ubuntu 24.04 LTS, not a floating `24`, `latest`, or a newer LTS. | Ubuntu version tags and release cadence make an explicit version necessary. | User approval of this package. | Awaiting approval. |
| ASM-002 | “the minimal one” refers to Canonical's official minimal OCI base rootfs, not removal of the current browser/desktop/tool feature set. | The final product necessarily installs Chromium, XFCE, runtimes, and utilities, so final-image minimization would be a separate scope decision. | Confirmed directly by the user on 2026-09-01. | Validated. |
| ASM-003 | Other named runtimes remain preserved, but Python is intentionally upgraded from 3.11 to Ubuntu 24.04's native 3.12. | User asked to modernize Python alongside the base; 3.12 maximizes Noble integration while avoiding a PPA-only newer interpreter. | User approval plus downstream build/runtime validation. | Proposed; awaiting approval. |

## Open Decisions And Questions

| Decision / Question ID | Question | Why It Matters | Options / Evidence | Decision Owner | Status |
| --- | --- | --- | --- | --- | --- |
| DEC-001 | Does the approval basis correctly interpret “minimal” as the official minimal Ubuntu OCI base without pruning installed features? | A different interpretation would materially expand scope and change preserved behavior. | User confirmed that minimal refers to the base image itself. | User | Resolved 2026-09-01. |
| DEC-002 | Should the image select Python 3.12 or a newer Python 3.13/3.14? | This determines repository origin, compatibility risk, and whether the runtime aligns with Ubuntu 24.04's supported package set. | Recommended: 3.12, the only/default Python in official Noble repositories. Python 3.13 is stable upstream but requires an external source on Noble; Python 3.14 is the current newest stable upstream and carries greater ecosystem/OS divergence. | User | Awaiting approval of the 3.12 recommendation. |

## Traceability

| Requirement ID | Behavior IDs | Acceptance-Criteria IDs | Scenario IDs | Supplemental / Prototype Evidence |
| --- | --- | --- | --- | --- |
| REQ-001 | BEH-001 | AC-001, AC-003 | SCN-001 | Investigation notes. |
| REQ-002 | BEH-001 | AC-001, AC-002 | SCN-001 | Canonical/Docker upstream evidence in investigation notes. |
| REQ-003 | BEH-001 | AC-003, AC-004, AC-007 | SCN-001, SCN-002 | Build script and README evidence. |
| REQ-004 | BEH-002 | AC-005–AC-008 | SCN-003 | Runtime configuration/source evidence. |
| REQ-005 | BEH-001, BEH-002 | AC-003–AC-008 | SCN-001–SCN-003 | Scope/preservation evidence. |
| REQ-006 | BEH-003 | AC-009 | SCN-004 | README evidence. |
| REQ-007 | BEH-002 | AC-006, AC-010 | SCN-003 | User follow-up and Canonical Noble Python availability evidence in investigation notes. |

## Downstream Architecture Input

- Approved scenario IDs and product-level behavior paths architecture must map: Pending approval; SCN-001 through SCN-004 form the proposed scenario basis.
- Product and system constraints architecture must preserve: Explicit Ubuntu 24.04 LTS official minimal OCI base; Ubuntu-native Python 3.12; default and `zh`; AMD64/ARM64; current browser/VNC/other-runtime/user/port/profile behavior.
- Decisions intentionally deferred to architecture design: None currently apparent; only implementation-level Noble compatibility corrections are anticipated.
- Technical facts architecture should verify: Noble package availability and filesystem/runtime path differences for all dependencies; Ubuntu system-Python/pip packaging behavior; whether any required compatibility correction crosses an approved structural boundary.
- Known feasibility or integration risks: No Docker executable is installed in the requirements environment; package sources are mutable third-party dependencies; build/runtime validation must cover both variants and architectures.

## Readiness Check

- Relevant current behavior is evidence-backed: `Yes`
- Desired and preserved behavior are explicit: `Yes`
- Scope and non-goals are clear: `Yes`
- Requirements and acceptance criteria are testable and traceable: `Yes`
- Applicable scenarios are covered with validity and evidence: `Yes`
- Prototype and supplemental evidence is integrated consistently: `N/A`
- Applicable UI/UX approval and final visual-reference basis are recorded: `N/A`
- Material assumptions and open decisions are visible: `Yes`
- User approval received: `No`
- Requirements package ready for downstream route: `No`
- Remaining blocker: Explicit user approval of the complete proposed requirements baseline, including the Python 3.12 recommendation. The minimal-base interpretation is confirmed.

## Architecture Design Routing Assessment

- Assessment status: `Blocked` pending requirements approval; assessment must run only after approval.
- Assessment owner and date: Requirements Engineer; pending.
- Preliminary task size: Pending post-approval assessment.
- Preliminary architectural risk: Pending post-approval assessment.
- Structural surfaces reviewed: Docker base/dependency installation, multi-architecture build path, supervisor/runtime launch configuration, Compose/run contracts, profile volume contract.
- Payload/content surfaces reviewed: README OS-version statement.
- Structural-impact triggers: Pending post-approval assessment; no target architecture is proposed in this baseline.
- Evidence paths: Investigation notes and current repository paths listed above.
- Decision rationale: Not yet selectable before explicit approval under the requirements workflow.
- Selected route: `Department Coordinator` pending approval.
- Outcome classification: `Blocked` pending approval only.
- Direct-route conditions all satisfied: `N/A — not applicable` before approval.
- Architecture design, review, and design-revision artifacts: `N/A — not yet assessed`
- Downstream re-entry trigger: User explicitly approves or revises this requirements baseline.
