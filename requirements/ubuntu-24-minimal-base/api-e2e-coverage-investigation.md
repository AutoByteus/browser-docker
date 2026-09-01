# API/E2E Coverage Investigation

## Investigation Meta

- Requirements Doc: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-doc.md`
- Investigation Notes: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/investigation-notes.md`
- Requirements Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/requirements-revision-record.md`
- Design Spec: `N/A — not applicable` (approved direct route)
- Supplemental Task Artifacts: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Architecture Design Revision Record: `N/A — not applicable`
- Design Review Report: `N/A — not applicable`
- Architecture Review Revision Record: `N/A — not applicable`
- Implementation Handoff: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-handoff.md`
- Implementation Revision Record: `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/implementation-revision-record.md`
- Code Review Report: `N/A — not applicable`
- Code Review Revision Record: `N/A — not applicable`
- Delivery Revision Record (delivery re-entry only): `N/A — initial validation`
- Relevant Delivery Revision IDs: `N/A`
- API/E2E Revision Record (created after the first completed result): `/home/autobyteus/workspace/browser-docker/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md` (to be created as `API-REV-001` after this round)
- Current API/E2E Revision ID: `API-REV-001`
- Current Investigation Round: `1`
- Trigger: Implementation Engineer direct handoff at commit `bf290fd`.
- Prior Investigation Reviewed: `N/A — no prior API/E2E artifact exists`
- Latest Authoritative Investigation: This file.

## Routing Classification

- Task size: `Medium`
- Architectural risk: `Low`
- Input route: `Direct Low-Risk`
- Successful-output route: `Delivery`
- Proportional test-code review decision: `Not Required — direct low-risk route`

## Current Requirement And Design Basis

The approved package requires the default and `zh` browser images to move from the Docker Official `ubuntu:22.04` image to explicit Docker Official `ubuntu:24.04`, keep the final desktop/browser feature set, and use Ubuntu Noble's native Python 3.12. The current build, tag, variant, AMD64/ARM64, non-root user, port (5900/6080/9223), Supervisor process, Chromium profile, stale-lock recovery, English-default locale, optional Chinese Pinyin, Node.js 22, Yarn, `uv`, and websockify contracts must continue to work. Release version is `1.4.0`; Docker Hub publication and verification are Delivery-owned and may occur only after the pre-publication validation passes. Server/all-in-one source is explicitly deferred and must not be edited. Architecture and source-review artifacts are `N/A — not applicable` for this direct Medium/Low route.

## Changed Behavior Summary

| Behavior ID / Boundary | Change Type | Upstream Evidence | Coverage Consequence |
| --- | --- | --- | --- |
| BEH-001 / OS and multi-platform build | Changed | REQ-001–REQ-003; AC-001–AC-004; `Dockerfile`; `build-multi-arch.sh` | Perform cache-free default/`zh` builds and publication-equivalent AMD64/ARM64 builds without publishing. Inspect image/platform identity. |
| BEH-002 / Python and Python-installed tools | Changed | REQ-004–REQ-005, REQ-007; AC-005–AC-008, AC-010; `Dockerfile`, `base.conf`, `entrypoint.sh` | Directly check Noble package origin, Python 3.12 commands, isolated `/opt/browser-tools`, `uv`, websockify and the running service graph. |
| BEH-002 / desktop, browser, VNC and debugging | Preserved | AC-005–AC-008; SCN-003; implementation handoff | Start real containers, inspect Supervisor/processes/ports/logs, render a deterministic browser page, exercise Chromium DevTools and the websockify/VNC boundary. |
| BEH-002 / custom UID/GID | Preserved and corrected | AC-006; implementation handoff | Build with non-default IDs and verify identity, ownership, XDG/DBus paths, services and profile writes. |
| BEH-002 / locale and Chinese input | Preserved | AC-007 | Run the `zh` image, verify packages/locales/fcitx profile, service state, English default and Pinyin availability; use GUI evidence where practical. |
| BEH-002 / persisted profile and recovery | Preserved | AC-008; approved `Not Affected` transition | Seed a profile marker, recreate with the same volume, and inject stale Chromium/X locks to verify cleanup without data loss. |
| BEH-003 / repository identity | Changed | REQ-006; AC-009 | Scan active product files and review documented commands/ports/tags. |
| SCN-005 / publication sequencing | Preserved | REQ-008–REQ-009; AC-011–AC-012 | Validate release version, tags, build script and a no-push release-equivalent build. Leave Docker Hub publication/manifests/digests to Delivery. |

## Changed Surface And Boundary Classification

| Surface / Boundary | Affected? | Actual Changed Boundary | Repository Evidence Available | Material Risk Not Exercised By That Evidence | Candidate Broader Validation Mode |
| --- | --- | --- | --- | --- | --- |
| Domain / backend logic | No | N/A | N/A | N/A | None |
| API / transport / contract | Yes | VNC TCP, websockify HTTP/WebSocket, Chromium DevTools TCP/HTTP | Supervisor configuration and scripts | Built-package compatibility and real port routing | Live API / CLI |
| Frontend component / state | No | No application frontend source changed | N/A | N/A | None |
| Browser integration / user journey | Yes | Chromium running inside XFCE and remote debugging | Config only | Chromium can fail to launch/render on Noble | Browser plus DevTools protocol |
| Authentication / session / permissions | Yes | Non-root runtime UID/GID, profile permissions and DBus runtime identity | Shell/config source checks | Actual custom-ID execution and volume permissions | Container lifecycle / CLI |
| Desktop renderer / web-equivalent UI | Yes | Chromium/XFCE/VNC surface | Config only | Desktop/rendering/input behavior on Noble | Browser/GUI and VNC protocol smoke |
| Desktop shell / Electron-specific integration | No | N/A | N/A | N/A | None |
| Process / lifecycle | Yes | Supervisor startup, restart and stale-lock recovery | Supervisor and shell syntax/static interpolation | Runtime crash loops, sequencing and recovery | Container lifecycle |
| Persisted-data transition | Yes (preservation only) | Existing Chromium profile volume must remain directly usable; no schema migration | Paths and scripts | Real reuse/recreate behavior | Container lifecycle |
| Worker / queue / distributed coordination | No | N/A | N/A | N/A | None |
| External integration | Yes | Ubuntu, XtraDeb, NodeSource, PyPI and npm during two architectures/variants | Source declarations and upstream research | Mutable package availability and architecture parity | Clean BuildX builds |

## Project Execution Discovery

- Assigned task workspace: `/home/autobyteus/workspace/browser-docker`, branch `requirements/ubuntu-24-minimal-base`, commit `bf290fd` at intake.
- Project type and runtime stack: Single Dockerfile Ubuntu desktop/browser image; Bash BuildX/run tooling; Supervisor-managed DBus, TigerVNC, XFCE, fcitx, CopyQ, Chromium, socat and websockify.
- Conflicting, missing, or unclear project instructions: No `AGENTS.md`, contribution guide, test directory or CI test workflow exists. README and the build/run scripts are the authoritative executable instructions. README publication mode pushes directly, so pre-publication multi-platform validation must use an equivalent explicit `docker buildx build` output rather than `--push`.
- Required environment variables or secrets available: Docker Hub credentials are `N/A` for API/E2E because publication is Delivery-owned. No application secret is required.

| Instruction / Configuration Path | Authority / Purpose | Commands, Setup, Or Constraints Learned |
| --- | --- | --- |
| `README.md` | User-facing build/run contract | Build with `./build-multi-arch.sh [--no-cache] [--variant zh]`; run through `run-container.sh`; ports/profile/input/recovery semantics. |
| `build-multi-arch.sh` | Supported BuildX/tag contract | Default local `--load`; `--push` selects `linux/amd64,linux/arm64`; tag pairs `1.4.0`/`latest` and `1.4.0-zh`/`zh`. Do not publish during API/E2E. |
| `Dockerfile` | Image contents/runtime contract | `IMAGE_VARIANT`, `USER_UID`, `USER_GID`; exposed 5900/6080/9223; entrypoint and Supervisor topology. |
| `run-container.sh`, `docker-compose*.yml` | Supported container launch/profile contract | Requires `SYS_ADMIN` and unconfined seccomp; maps VNC/debug ports and persistent Chromium volume. Compose also maps websockify 6080. |
| `entrypoint.sh`, `start-vnc.sh`, `base.conf`, `supervisord.conf` | Lifecycle/recovery contract | Runtime/profile ownership, stale Chromium and X-lock recovery, Supervisor readiness and log paths. |

| Component / Dependency | Working Directory | Start / Setup Command | Runtime / Resource Notes | Readiness Check | Stop / Cleanup Method |
| --- | --- | --- | --- | --- | --- |
| Docker/BuildX test runtime | Repository root | Install/enable a local Docker daemon and BuildX if absent; create a task-specific builder | Use task-specific data/build output and names; no registry push | `docker version`; `docker buildx inspect --bootstrap` | Remove task containers/volumes/build outputs/builder; stop only the daemon started by this run |
| Default image | Repository root | `./build-multi-arch.sh --no-cache`, then task-scoped `docker run` | ARM64 host; map unused host ports and a task volume | All expected Supervisor programs stable; port and HTTP probes | `docker rm -f` task container; remove task volume/image when evidence retention is no longer needed |
| `zh` image | Repository root | `./build-multi-arch.sh --no-cache --variant zh` | Same isolation; English must remain default | Supervisor/fcitx, package, locale and profile checks | Same task-only cleanup |
| Multi-platform validation | Repository root | Explicit `docker buildx build --no-cache --platform linux/amd64,linux/arm64 --output type=oci,...` for both variants | Publication-equivalent build without Docker Hub mutation; QEMU may be required | Successful build plus OCI index/platform inspection | Remove generated OCI archives and task builder/cache after report evidence is retained |

| Data / Fixture / Identity Need | Existing Project Mechanism Or Creation Method | Environment / Data-Safety Notes | Cleanup / Retention |
| --- | --- | --- | --- |
| Chromium profile | Task-specific Docker named volume mounted at documented path | Seed a harmless marker/preferences file; do not use or remove existing user volume | Remove only the task volume after capturing evidence |
| Browser page | Deterministic task-local static HTTP page | No external account/session required | Stop local server and delete temporary page |
| Custom identity | Build args `USER_UID=1234`, `USER_GID=1234` | No host identity mutation | Remove task image/container/volume |
| Stale locks | Create documented stale X and Chromium lock artifacts in task-owned container/volume | Never touch the current environment's mounted live Chromium profile | Recreate container; verify cleanup and remove task resources |

## Persisted Data Transition Coverage Basis

- Approved decision: `Not Affected`.
- References: requirements `Data Continuity And Acceptable Loss`; implementation handoff `Persisted Data Transition Check`.
- Representative setup: a task-owned volume at `/home/vncuser/.config/chromium` containing a marker/profile file and documented stale lock artifacts.
- Planned evidence: recreate against the same volume, prove the marker survives, profile remains writable by `vncuser`, and stale locks are removed while normal profile content remains.
- Migration-specific scenarios: `N/A — no migration approved`.
- Upstream ambiguity or reroute required: None.

## Existing Durable Coverage Inventory

| Path / Scenario | Current Assertion Or Intent | Related Requirement / AC | Validity Decision | Evidence | Action |
| --- | --- | --- | --- | --- | --- |
| `build-multi-arch.sh` | Executable build/tag/platform workflow, but not an assertion suite | AC-003–AC-004, AC-011 | Still Valid | Source and README agree | Exercise unchanged; no source edit planned. |
| `run-container.sh` | Executable container launch/profile workflow, but not an assertion suite | AC-005, AC-008 | Still Valid | Source and README agree | Exercise representative equivalent with task-scoped names/ports. |
| `start-vnc.sh` and `entrypoint.sh` | Executable stale-lock recovery logic | AC-005, AC-008 | Still Valid | Approved preserved behavior | Exercise through real container lifecycle. |
| Repository test suite | No durable automated assertions exist | AC-001–AC-010 | Out Of Scope as inventory entry | Repository file inventory | Add a narrow maintainable image contract/smoke harness rather than claim missing tests as evidence. |

## Stale Or Obsolete Coverage Decisions

None. No existing durable test asserts obsolete Ubuntu 22.04/Python 3.11 behavior.

## Durable Coverage To Add

| Scenario ID | Behavior / Boundary | Requirement / AC Evidence | Planned Artifact / Path | Why Durable Coverage Is Needed |
| --- | --- | --- | --- | --- |
| AE2E-SCN-001 | Source/build/release contract | AC-001–AC-004, AC-009–AC-012 | `tests/validate-source-contract.sh` | Added and passed. Fast repeatable guard against stale base/Python/tag/platform/path declarations before expensive builds. |
| AE2E-SCN-002 | Built image identity/tool/package/variant contract | AC-001–AC-007, AC-010 | `tests/validate-image.sh` | Added but not executable this round because the default image did not build. Reusable release gate against a supplied image tag, including default/`zh` and custom identity assertions. |
| AE2E-SCN-003 | Running services, browser/debug/VNC/websockify and profile recovery | AC-005–AC-008, AC-010 | `tests/validate-running-container.sh` | Added but not executable this round because no image was produced. Reusable task-scoped runtime smoke gate for the real process/network/profile boundaries. |

## Durable Coverage To Update

None planned.

## Durable Coverage To Remove

None planned.

## Repository Coverage Execution Plan And Results

| Order | Command | Working Directory / Configuration | Boundary Or Scenario Proven | Result | Evidence / Output Path |
| --- | --- | --- | --- | --- | --- |
| 1 | `bash -n` over repository and new validation scripts; `git diff --check`; Supervisor parse/custom-XDG assertion; obsolete scan | Repository root | Shell/source integrity and configured-UID interpolation | Pass | `requirements/ubuntu-24-minimal-base/evidence/repository-checks.log` |
| 2 | `tests/validate-source-contract.sh` | Repository root | AE2E-SCN-001; source portions of AC-001–AC-004, AC-009, pre-publication AC-011/AC-012 | Pass | Same log |
| 3 | `podman ... build --no-cache --layers=false --isolation=chroot --network=host --build-arg IMAGE_VARIANT=default -t autobyteus/chrome-vnc:1.4.0 -t autobyteus/chrome-vnc:latest .` | Repository root; clean exact Dockerfile build on ARM64; task VFS store | AC-003 and build gate for all image/runtime scenarios | **Fail** | `evidence/build-default-arm64.log`; `evidence/base-identity-and-uid-collision.log` |
| 4 | `tests/validate-image.sh` for default/`zh` and custom-ID images | Repository root | AE2E-SCN-002; AC-001, AC-006–AC-007, AC-010 | Blocked by failed default build; not executed | No image exists. |
| 5 | `tests/validate-running-container.sh` plus deterministic page/DevTools probes | Repository root; task-scoped containers/volumes/ports | AE2E-SCN-003; AC-005–AC-008, AC-010 | Blocked by failed default build; not executed | No runnable image exists. |
| 6 | No-push multi-platform default and `zh` BuildX builds and OCI index inspection | Repository root; no cache; AMD64/ARM64 | AC-004 and pre-publication AC-011/AC-012 | Blocked by failed default build; not executed | Both current official Ubuntu platform roots were separately inspected and contain the same UID/GID collision, but full images were not built. See `evidence/base-identity-and-uid-collision.log`. |

## Post-Repository Confidence Scorecard (Mandatory)

| Confidence Category | Score | What Supports The Score | Remaining Uncertainty | Additional Validation That Could Improve It |
| --- | --- | --- | --- | --- |
| Requirement and acceptance-criteria proof | 35% | AC-002 and AC-009 have direct/static evidence; AC-003 has a direct failing clean build; source portions of AC-001/AC-011/AC-012 pass. | AC-001 runtime and AC-004–AC-008/AC-010 cannot proceed. | Correct the default UID/GID collision, then rerun the complete matrix. |
| Changed-boundary execution directness | 75% | Exact Dockerfile, official ARM64 base and real Noble packages executed until the deterministic Dockerfile failure. | No completed image or runtime boundary. | Successful no-cache builds and container execution. |
| Cross-boundary integration realism and mock gap | 40% | Real Ubuntu/XtraDeb/NodeSource package resolution occurred; no mocks. | No Supervisor/service/browser/profile integration. | Execute the real running-image scenarios after repair. |
| Environment, configuration, identity, and fixture fidelity | 75% | ARM64 host, exact official platform image, no cache, real external repositories; both official platform roots inspected by digest. | Nested environment could not provide a persistent Docker daemon/BuildX runner, so Buildah/Podman chroot execution was used; the failure is builder-independent. | Rerun with Docker BuildX after implementation correction. |
| Failure, edge-case, lifecycle, and recovery evidence | 45% | The build failure and cross-platform UID/GID precondition are directly reproduced. | Custom-ID runtime and persistence/stale-lock lifecycle were never reached. | Run AE2E-SCN-003 after image creation succeeds. |
| User-surface, browser, and desktop-shell confidence | 0% | No upgraded image exists to start. | All browser/XFCE/VNC/input behavior remains untested. | Browser/DevTools, VNC/websockify and `zh` GUI smoke after repair. |
| Durable regression coverage quality and relevance | 75% | Three narrow requirement-linked scripts were added; source gate passed; syntax and diff checks passed. | Image/runtime harnesses cannot yet be executed against a built artifact. | Execute all scripts on the repaired images. |

- Overall post-repository confidence: `49%` (simple average, rounded from 49.3%).
- Every critical acceptance criterion directly proven: `No`; AC-003 is directly failing.
- Any applicable category below `90%`: `Yes — all seven categories`.
- Default clean-confidence target of `95%` met: `No`.
- Material residual risks: The Dockerfile cannot create its default user on current official Ubuntu 24.04; every built-image/runtime/variant/platform/recovery criterion remains downstream of that failure.

## Broader Validation Decision (Mandatory)

- Decision: `Required`.
- Selected execution mode: `CLI`, `Live API`, `Lifecycle`, and `Browser`/GUI where it improves desktop evidence.
- Specific confidence gap: Source inspection cannot prove that remote packages install on Noble for both architectures or that the desktop/browser/service/profile boundaries run correctly.
- Why the selected mode can materially improve confidence: It executes the actual built image, real supervised processes and network surfaces rather than mocked or static paths.
- Expected confidence after selected validation: At least 95% with no category below 90%, if implementation rework enables both variants/platforms to build and the full runtime/recovery matrix passes.
- Browser-specific decision: Required for Chromium page-rendering and DevTools evidence. VNC protocol/process and GUI screenshot evidence will support, but not replace, semantic/browser/network assertions.
- Execution outcome: Broader runtime validation did not start because the required clean build failed on an implementation-owned UID/GID collision. This is a `Fail`, not an environment `Blocked` result.

## Desktop Application Validation Decision

- Desktop framework / shell: XFCE desktop plus Chromium rendered over TigerVNC/websockify; not Electron.
- Relevant instructions: `README.md`, `run-container.sh`, `docker-compose*.yml`.
- Web-equivalent behavior: Chromium must launch and render a page; DevTools endpoint must be reachable.
- Shell-specific/lifecycle behavior: Xvnc/XFCE/DBus/fcitx/CopyQ/Supervisor startup and recovery.
- Chosen validation: direct process/network/container lifecycle assertions plus browser/DevTools rendering and supporting screenshot/VNC handshake evidence.
- Effect on already-running desktop application: None; all validation containers, ports, volumes and display state will be task-scoped. The current workspace host's own display/profile will not be modified.

## Live Environment And Fixture Plan

- Startup order: enable local Docker/BuildX; build image; create task volume and deterministic test page; start task container; wait for Supervisor/ports; execute image and service checks; render/inspect page; recreate with same volume and injected stale locks.
- Environment choices: ARM64 host, task-specific names/ports, no Docker Hub push, no account/secret, default locale unless checking `zh` contents.
- Health/readiness: container running, expected Supervisor state, VNC TCP greeting, websockify HTTP response, DevTools `/json/version`, rendered-page DOM/title.
- Fixture: harmless profile marker and task-local page.
- Identities: default UID/GID 1000 and a separately built 1234/1234 image.
- Evidence: exact logs, image inspection, OCI index inspection, API responses, process/supervisor output, profile ownership/state, and a screenshot only as supporting desktop evidence.
- Cleanup: task daemon/builders/containers/volumes/static server and large OCI archives after retaining text/metadata evidence.

## Temporary Executable Validation Plan

| Scenario ID | Probe / Harness / Runtime Setup | Behavior Proven | Why This Should Not Remain As Durable Coverage |
| --- | --- | --- | --- |
| AE2E-SCN-004 | Explicit no-push BuildX OCI output and index inspection | Both target platforms and both variants fully build without publication | OCI archives are large, environment-specific release evidence; durable source/image scripts cover repeatable assertions. |
| AE2E-SCN-005 | Deterministic local HTTP page and browser screenshot/DevTools probe | Real Chromium rendering through the running Noble image | The page/server are ephemeral fixtures; durable runtime harness owns stable readiness contracts. |

## Not Tested / Infeasible / Deferred

| Behavior / Boundary | Reason | Risk | Required Follow-Up Or Escalation |
| --- | --- | --- | --- |
| Docker Hub tags/manifests/published immutable digests | Publication is explicitly Delivery-owned and prohibited before validation | Published identity remains absent until Delivery | Delivery performs AC-011 and final AC-012 after a Pass. |
| AutoByteus server consumer adoption | Explicitly separate deferred ticket | None for this browser-image validation; downstream adoption still pending | Requirements Engineer starts the follow-up only after verified publication. |
| AC-004–AC-008 and AC-010 full build/runtime matrix | The prerequisite default build failed at `groupadd -g 1000 vncuser` | All preserved runtime behavior remains unproven | Implementation correction, then API/E2E rerun using the same scenario IDs. |

## Ambiguities Or Reroute Triggers

| Issue | Classification | Evidence | Recommended Recipient |
| --- | --- | --- | --- |
| APIE2E-F-001: The current official `ubuntu:24.04` platform roots already define `ubuntu` as UID/GID 1000, while the Dockerfile defaults `USER_UID=1000`, `USER_GID=1000` and unconditionally executes `groupadd -g 1000 vncuser`. The clean ARM64 build exits status 4. | `Local Fix — implementation` (preliminary; Code Reviewer owns final failure origin) | `evidence/build-default-arm64.log`; `evidence/base-identity-and-uid-collision.log`; Dockerfile lines 4–5 and 94–103 | `/software_engineering_team/code_reviewer` through dynamic handoff rules |

## Investigation Decision

- Proceed To API/E2E Execution: `No — stop after the critical clean-build failure and reroute the completed failure package`.
- Repository-Resident Durable Coverage Will Be Added / Updated / Removed: `Yes — add three narrow validation scripts; update/remove none`.
- Post-repository confidence: `49%`.
- Broader validation decision: `Required but not reached because the build gate failed`.
- Reroute Required Before Validation Execution: `Yes`.
- Recommended Recipient If Reroute Required: Dynamic handoff recipient for API/E2E `Fail` (normally Code Reviewer).
- Notes: Docker/BuildX was absent at intake. Docker, BuildX, QEMU, Podman and Buildah were installed; nested Docker daemon attempts were limited by the read-only outer cgroup hierarchy. A task-isolated, no-cache Podman/Buildah chroot build executed the exact Dockerfile and real external package sources. Its `groupadd` failure is independently confirmed from both official ARM64 and AMD64 base root files and is not caused by the alternate builder.
