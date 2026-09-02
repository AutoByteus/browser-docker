# API/E2E Coverage Investigation

## Investigation Meta

- Ticket: `BRD-UBUNTU24-001`
- Requirements Doc / Revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-doc.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` (`RER-007`)
- Investigation Notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/investigation-notes.md`
- Design Spec: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/design-spec.md` (`SR-002` basis)
- Supplemental Task Artifacts: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`; retained Noble package/tool feasibility logs under the ticket evidence directory
- Solution Revision Record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/solution-revision-record.md` (`SR-001`, `SR-002`)
- Design Review Report: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/design-review-report.md` (`Pass`)
- Architecture Review Revision Record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/architecture-review-revision-record.md` (`ARCH-REV-002`)
- Implementation Handoff / Revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-revision-record.md` (`IR-006`, `IR-007`)
- Code Review / Revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-revision-record.md` (`CRR-010`, Pass, 97.0/100; `CR-F-001` resolved)
- Prior API/E2E test review: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-test-review-report.md` (`CRR-008`, Pass; pre-IR-006 coverage state)
- Delivery re-entry context: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/delivery-revision-record.md` (`DR-005`, repository finalized; publication blocked before mutation)
- API/E2E Revision Record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Current API/E2E Revision ID / Round: `API-REV-007` / focused round 7 IR-006/IR-007 re-entry; API-REV-005/006 evidence retained where unchanged
- Trigger: Code Reviewer CRR-010 Pass after IR-006 removed the false Docker-info Username gate and IR-007 resolved deterministic fixture leak `CR-F-001`
- Prior Investigation Reviewed: `API-REV-006 — Pass / 97%`; API-REV-005 broader Docker/runtime evidence remains current because IR-006/IR-007 change only wrapper orchestration and its deterministic harness
- Assigned worktree / branch: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base`; `requirements/ubuntu-24-minimal-base`
- Implementation under test: `14fb215b1ad0b48dd486658ca7fd7757ceb06d16` (IR-007; parent IR-006 `24a61a8542a220c32d1d88b600fde5b7a33d8a06`; finalized base `01a07b203472049695e870b2865fcd5df9ec5844`)
- Latest Authoritative Investigation: this file
- Investigation state: `Complete — focused non-publishing wrapper/lifecycle matrix Pass / 97%`

## Current Requirement And Design Basis

RER-007 supersedes the former public Python 3.12 target. The current image must retain Canonical's official minimal `ubuntu:24.04` base, version `1.4.0`, default/`zh` variants, AMD64/ARM64 support, Apple/Linux ARM aliases, tags/load/push behavior, configured identity, XDG/DBus, browser/VNC/websockify/DevTools, English-default optional Pinyin input, mobile-safe Chromium, and profile persistence/recovery. Public `python3` and `python` must now be Python 3.13 through `/usr/local`, while Noble keeps ownership of `/usr/bin/python3` as its distribution interpreter. One Python 3.13 `/opt/browser-tools` environment must solely own Supervisor 4.3.0, websockify, and `uv`; the entrypoint must hand off only to `/usr/local/bin/supervisord`; public commands and web assets must remain stable and Python-minor-independent.

This is a clean provider replacement, not a 3.12/3.13 compatibility promise. Durable coverage must require public Python 3.13, preserve only the separate OS-owned Noble `/usr/bin/python3`, reject the old apt Supervisor/global-pip/fallback paths, and never accept either public version.

The approved persisted-data decision remains `Not Affected`: Chromium profile data must be directly reusable through the unchanged profile volume, and stale Chromium/X recovery must still work without migration or version-specific fallback.

IR-006/IR-007 is a bounded release-wrapper correction after DR-005. The wrapper must not interpret the optional `docker info` `Username` presentation as authentication authority; a requested push must reach `docker buildx build --push`, whose nonzero status must propagate before any success output. The deterministic harness must remove its own fixture directory on normal and reachable error exits. Image construction/runtime sources are byte-for-byte unchanged from the API-REV-005 validated candidate.

Docker Hub publication, remote manifest/pull/run verification, and AutoByteus server adoption are outside this API/E2E execution. Repository finalization is already complete under DR-005. No registry push and no server-repository write are authorized.

## Changed Behavior Summary

| Behavior / Boundary | Change Type | Upstream Evidence | Coverage Consequence |
| --- | --- | --- | --- |
| Push-readiness authority and failure propagation | Changed | DR-005; IR-006; CRR-010 | Prove a no-`Username` Docker presentation cannot block the push branch; exact BuildX commands/tags reach the fake boundary; BuildX failure status propagates with no false success; no real push. |
| Deterministic wrapper fixture lifecycle | Changed in durable harness | CR-F-001; IR-007; CRR-010 | Prove normal, assertion-error and command-error executions leave zero task fixture directories. |
| Public developer Python | Changed | RER-007 REQ-007; AC-006/010; SR-001/SR-002; ARCH-REV-002; IR-005 | Replace exact public 3.12 assertions with exact `/usr/local` Python 3.13 resolution in source and built images on both architectures. |
| Noble OS Python ownership | Preserved but now explicitly separated | AC-010; design DS-004; IR-005 | Prove `/usr/bin/python3` remains Noble's distribution 3.12 interpreter and is not repointed by `update-alternatives`. This is OS ownership evidence, not public-version compatibility. |
| Python package origin | Changed | REQ-007; AC-010; IR-005 | Prove the stable Deadsnakes Noble source and resolved Python 3.13 package origin/version for AMD64 and ARM64. Remove the obsolete no-Deadsnakes assertion. |
| Supervisor provider and entrypoint | Changed | AC-013; design DS-002/DS-005; IR-005 | Require the sole `/opt/browser-tools` Python 3.13 Supervisor 4.3.0 provider, stable public daemon/control paths, real config start/status, and absence of the prior compatibility traceback or apt fallback. |
| websockify/`uv` ownership/assets | Changed provider, stable public surface | AC-010/013; design DS-004 | Prove both commands resolve to the same tools environment and `/usr/local/share/websockify` resolves to usable assets. Record mutable resolved versions. |
| Build platforms/variants/tags/aliases | Preserved | REQ-003/005; AC-003/004; IR-005 says build script unchanged | Re-run clean default/`zh` ARM64/AMD64 builds and local/multi-platform readiness because the image composition changed materially. |
| Identity, XDG/DBus, service graph, browser, zh, mobile-safe, profile/recovery | Preserved | REQ-004/005; AC-005–008/013; design DS-002/DS-005 | Re-run real normal-entrypoint journeys; prior round evidence is regression context only, not current proof. |
| Registry publication and server adoption | Deferred | REQ-008/009; AC-011/012 | Do not publish or modify the server repository. Hand a passing local pre-publication package back through proportional test review. |

## Changed Surface And Boundary Classification

| Surface / Boundary | Affected? | Actual Changed Boundary | Repository Evidence Available | Material Risk Not Exercised By Repository Evidence | Candidate Broader Validation Mode |
| --- | --- | --- | --- | --- | --- |
| Domain/backend logic | No | No application backend in this repository | N/A | N/A | None |
| API/transport/contract | Yes, operational transport | VNC, websockify HTTP/WebSocket and DevTools proxy must survive provider change | Shell harnesses | A source assertion cannot prove listening processes or protocol behavior | Live container/CLI/browser |
| Frontend/browser integration | Preserved but material | Chromium/XFCE/fcitx service graph | Existing runtime harness and prior evidence | Provider/config startup can fail before rendering | DevTools semantic DOM plus X/VNC IME interaction |
| Authentication/session/permissions | Configured identity only | `vncuser`, custom UID/GID, runtime/profile ownership | Image/runtime harnesses | Mounted-volume and live DBus permissions | Live default/custom containers |
| Process/lifecycle | Yes | Entrypoint now execs the isolated Supervisor provider | Source/config checks | Real shebang/interpreter/config/RPC/service startup and traceback absence | Normal-entrypoint lifecycle |
| Persisted-data transition | No transformation | Existing Chromium profile direct reuse and stale-lock recovery | Prior durable/runtime paths | New provider could alter lifecycle timing despite unchanged data code | Recreate container on retained profile volume |
| Worker/queue/distributed | No | None | N/A | N/A | None |
| External integration | Yes | Ubuntu, Deadsnakes, PyPI, XtraDeb, NodeSource/npm inputs; BuildX/QEMU | Clean builds | Target-architecture package availability and mutable versions | Real clean BuildX matrix |

## Project Execution Discovery

- Authoritative project instructions: repository `README.md`; `build-multi-arch.sh`; `run-container.sh`; `Dockerfile`; `entrypoint.sh`; `base.conf`; `supervisord.conf`; `start-chrome.sh`; `start-vnc.sh`; all three `tests/validate-*.sh` scripts. No applicable `AGENTS.md` was found.
- Project type/runtime stack: Docker/BuildX OCI image; Ubuntu 24.04; Python 3.13 public runtime plus Noble OS Python; Python 3.13 venv tools; Supervisor/XFCE/Chromium/TigerVNC/websockify.
- Host setup: macOS Apple Silicon with Docker Desktop and the pre-existing `multi-platform-builder`; Docker 29.0.1, BuildX v0.29.1-desktop.1, BuildKit v0.26.2 and AMD64/ARM64 capability were captured before execution.
- Required secret: none for local validation. Docker Hub credentials must not be used.
- Shared-worktree constraint: preserve all upstream uncommitted artifacts and unrelated evidence. Do not reset, clean, commit, or delete non-owned files.

| Component / Dependency | Start / Setup | Readiness | Cleanup |
| --- | --- | --- | --- |
| BuildX builder | `docker buildx inspect --bootstrap multi-platform-builder` | Reports `linux/arm64` and `linux/amd64` | Retain shared builder and cache; do not globally prune |
| ARM64 default/zh local images | Exact supported wrapper for clean local build where safe; task aliases for stable references | Image inspect and durable image harness | Restore any pre-existing official tags exactly; remove task-created aliases |
| AMD64 default/zh images | Direct `docker buildx build --no-cache --platform linux/amd64 --load` with task-only tags | Image inspect reports AMD64; durable image harness | Remove task tags |
| Custom identity image | ARM64 build with `USER_UID=1234`, `USER_GID=1234` and task-only tag | Image harness plus live runtime | Remove image/container/volume |
| Live runtimes | Task-specific containers, non-conflicting host ports, task profile volumes | `supervisorctl status`, endpoints and semantic render | Remove only task containers/volumes |
| Multi-platform no-push indexes | BuildX `type=oci` output for default and `zh` | OCI index contains AMD64 and ARM64 manifests | Remove task OCI files after recording inspection/digests |

## Persisted Data Transition Coverage Basis

- Approved decision: `Not Affected`.
- Design/implementation reference: design `Persisted Data / State Transition Decision`; implementation handoff `Persisted Data Transition Check`.
- Representative setup: write a marker through the normal runtime into a task Chromium profile volume, remove the first container, seed known stale Chromium/X locks, recreate using the same volume, and verify marker retention plus successful service/browser recovery.
- Expected result: direct reuse with no migration, no profile deletion, no version-specific reader/fallback, and only supported stale locks removed.
- Upstream ambiguity/reroute: none.

## CRR-007 Focused Re-entry Investigation

- Finding: `APIE2E-TEST-F-001`, API/E2E-owned Local Fix in `tests/validate-source-contract.sh`; implementation source review CRR-006 and API-REV-005 broader execution remain Pass.
- Validated defect: three new regexes were not exact declarations. The `/usr/local/bin/python` selector matched the longer `/usr/local/bin/python3`; `python3.13` could match `python3.13-venv`; `python3.13-dev` could match `libpython3.13-dev`.
- Final coverage decision: `tests/validate-source-contract.sh` is `Updated / Pass` after adding `assert_literal_line` and converting all three explicit Python packages plus both public selector declarations to complete literal-line assertions. `tests/validate-image.sh` and `tests/validate-running-container.sh` remain `Updated / Pass` and already passed CRR-007 proportional review.
- Focused execution result: Bash syntax Pass; ShellCheck with only intentional SC2016 excluded Pass with no diagnostics; current source harness Pass; five fixture cases each removed/replaced one exact declaration while retaining its prefix/suffix confounder and were correctly rejected; `git diff --check` Pass.
- Broader rerun decision: `Not Required` for API-REV-006. The exactness-only test change did not reveal a source mismatch, and API-REV-005 directly proved the unchanged image/runtime boundary at 97% confidence.
- Evidence: `evidence/host-round6-source-contract-fix.log`, final authoritative section beginning `FINAL AUTHORITATIVE FOCUSED VALIDATION`.
- Successful route: append API-REV-006 and return the revised durable state plus cumulative evidence to `/code_reviewer`; do not route Delivery or publish before review Pass.

## IR-006 / IR-007 Coverage Re-entry Investigation

### Changed Boundary And Prior-Evidence Validity

- Production delta: only `build-multi-arch.sh` push messaging/preflight changed. The unreliable `docker info | grep Username` gate is removed; BuildX remains the sole registry/authentication/authorization authority.
- Durable delta: new `tests/validate-build-wrapper.sh`; IR-007 adds immediate EXIT cleanup after successful `mktemp`.
- Unchanged product boundary: Dockerfile, entrypoint, Supervisor configuration, browser/VNC/runtime/profile sources, version, variants, platforms, aliases, tags and build arguments. API-REV-005's clean builds, image/runtime/browser/input/profile and local OCI-index evidence therefore remains `Still Valid` for those unchanged boundaries.
- API-REV-006 exact source-contract evidence and CRR-008 remain `Still Valid`; neither file changed.
- DR-005 Docker Hub state is context only: `1.4.0`/`1.4.0-zh` absent and rolling tags unchanged when publication stopped before BuildX. API/E2E will not query or mutate remote state.

### Current Durable Coverage Decisions

| Path / Scenario | Decision | Rationale / Planned Action |
| --- | --- | --- |
| `tests/validate-build-wrapper.sh` / AE2E-SCN-010 | `Still Valid / Pass` | Directly targets the changed push boundary and passed unchanged: no Username dependency, default multi-platform push tags, zh/no-cache failure, exact status propagation, no false success, fixture cleanup. |
| `tests/validate-source-contract.sh` / AE2E-SCN-001 | `Still Valid / Pass` | Preserved platform/alias/tag and current release source contract passed; API-REV-006/CRR-008 exactness remains valid. |
| `tests/validate-image.sh` and `tests/validate-running-container.sh` | `Still Valid / Do Not Rerun` | Image/runtime sources are unchanged; these harnesses passed API-REV-005 and are outside the wrapper-only delta. |
| API-REV-005 clean build/image/runtime/desktop/profile/OCI matrix | `Still Valid current proof` | The changed code executes only after argument/platform/tag selection and before BuildX invocation; no image content or build definition changed. |
| Round-5 temporary wrapper alias matrix | `Replaced by current focused Pass` | API-REV-007 re-executed and expanded the matrix against current source, including the changed push branch. |

### Coverage And Execution Result

No repository-resident durable coverage change was required or made by API/E2E. The implementation-added harness was coherent, already reviewed under CRR-010, and passed unchanged.

Executed results:

1. Bash syntax, ShellCheck, source contract, durable wrapper harness, obsolete-parser negative scan, and `git diff --check`: `Pass`.
2. Current real wrapper behind deterministic non-publishing `docker`/`uname` boundaries: `Pass` for arm64, aarch64 and x86_64; implicit/explicit load; default/zh; no-cache; immutable/rolling tags; default and zh multi-platform push composition; builder use/create; BuildX unavailable; unsupported architecture; push/load mutual exclusion; unknown option; empty variant; local/push BuildX failure propagation; no false success; no `docker info` call.
3. Fixture lifecycle in isolated TMPDIR: normal `0`, controlled assertion `1`, and controlled command error `44` each left `0 -> 0` matching fixture directories.
4. Mutation/cleanup: no real Docker or registry command was reachable, no task fixture remained, no image/container/volume changed, no server repository was accessed.

Evidence: `requirements/ubuntu-24-minimal-base/evidence/host-round7-build-wrapper-matrix.log`. The first temporary controlled-assertion probe in that log referenced an undefined variable before the intended assertion and is explicitly superseded by the corrected authoritative lifecycle section. The corrected normal/assertion/command cases all pass with exact statuses and zero fixtures; this was a temporary probe-construction issue, not a durable harness or product failure.

### Initial Focused Confidence And Broader Gate

| Category | Initial Focused Score | Basis / Gap |
| --- | ---: | --- |
| Requirement and AC proof | 90% | API-REV-005 proves local release candidate; current push-gate delta not yet executed. |
| Changed-boundary directness | 75% | CRR-010/implementation evidence is strong but independent API/E2E execution is pending. |
| Cross-boundary realism/mock gap | 90% | Real wrapper plus fake Docker is the highest safe non-publishing boundary; real registry remains Delivery-owned. |
| Environment/configuration/identity/fixture fidelity | 90% | Actual shell/source and isolated host temp roots; registry intentionally excluded. |
| Failure/edge/lifecycle/recovery evidence | 80% | Planned matrix must independently prove statuses, false-success rejection and cleanup exits. |
| User-surface/browser/desktop confidence | 97% | Unchanged and directly proven by API-REV-005. |
| Durable regression coverage quality | 90% | New harness passed CRR-010; API/E2E validity/execution pending. |

- Initial focused average: `87%` (rounded).
- Broader-validation decision before execution: `Required` — the focused deterministic/executable wrapper and lifecycle matrix is the broader surface for this shell boundary.
- Real Docker Hub execution: `Prohibited in API/E2E`; only Delivery can close credential-helper/registry interoperability and AC-011.
- Full image/runtime rebuild: `Not Required` unless focused execution reveals altered command composition or a source mismatch.

## API-REV-007 Final Focused Confidence

| Category | Final Score | Evidence / Residual |
| --- | ---: | --- |
| Requirement and acceptance-criteria proof | 96% | Current wrapper proves local pre-publication command/alternate outcomes; AC-011 remote state remains Delivery-owned. |
| Changed-boundary execution directness | 100% | The real current wrapper executed every changed push path against a controlled Docker boundary. |
| Cross-boundary integration realism/mock gap | 95% | BuildX command/status boundary is direct; actual credential-helper/registry authorization is intentionally reserved for Delivery. |
| Environment/configuration/identity/fixture fidelity | 98% | Real shell/source, actual host process semantics, isolated TMPDIR and exact argument/status logs. |
| Failure/edge/lifecycle/recovery evidence | 100% | All option/platform/BuildX failures plus normal/assertion/command cleanup outcomes directly pass. |
| User-surface/browser/desktop confidence | 97% | Unchanged API-REV-005 browser/desktop evidence remains current. |
| Durable regression coverage quality | 97% | CRR-010-reviewed wrapper harness passes unchanged; API/E2E added no test code. |

- Final overall confidence: `97%` (97.6% simple average, conservatively reported as 97%).
- Applicable category below 90%: `None`.
- Critical local/pre-publication acceptance criterion missing/failing: `None`.
- Broader-validation result: `Required and completed` through the deterministic/non-publishing executable matrix.
- Full image/runtime rerun: `Not Required`; no wrapper mismatch or product-source change was exposed.
- Real registry interoperability: intentionally deferred to Delivery and does not reduce the local API/E2E Pass below threshold.

## Existing Durable Coverage Inventory And Validity Decisions

| Path / Scenario | Current Assertion / Intent | Related Requirement / AC | Validity Decision | Evidence | Action |
| --- | --- | --- | --- | --- | --- |
| `tests/validate-source-contract.sh` / AE2E-SCN-001 | Source/base/build/identity/tool/docs contract | AC-001–004/006/009/010/013 | `Updated / Pass — API-REV-006 focused correction` | `APIE2E-TEST-F-001`; `host-round6-source-contract-fix.log` | Literal-line helper now discriminates all explicit Python packages and both public selectors; current positive source and five negative prefix/suffix fixtures pass. |
| `tests/validate-image.sh` / AE2E-SCN-002 | Built-image OS, public/OS Python ownership, isolated tools, utilities, locale/variant/identity | AC-001/006/007/010/013 | `Updated / Pass` | Five final round-5 image-harness cases pass | Requires exact public/local selectors, Noble OS path, Deadsnakes source/package evidence, Supervisor 4.3.0, stable tools/assets, `gh`, and no apt provider. |
| `tests/validate-running-container.sh` / AE2E-SCN-003 | Normal service/process/protocol/browser/profile and isolated-provider checks | AC-005/006/007/008/013 | `Updated / Pass` | Native ARM64, Rosetta-emulated AMD64, `zh`, mobile-safe, and custom-identity live reruns pass | Requires daemon/control/provider/version/interpreter/cmdline/log evidence while preserving readiness, protocols, DOM and profile behavior. |
| Prior alias assertion and controlled alias probe / AE2E-SCN-006 | Apple/Linux ARM aliases, tags/load/push composition and unsupported host | AC-003/004/011 | `Still Valid as baseline; Needs Current Focused Rerun` | IR-006 changed the push branch only | Retain durable alias assertion and rerun the real current wrapper through deterministic non-publishing boundaries. |
| Prior round-3/4 platform/runtime/IME/profile/index evidence | Pre-IR-005 behavior | AC-001–010 | `Out Of Scope as current proof; useful regression baseline` | IR-005 materially changes Dockerfile/entrypoint/tool owner | Do not claim it as current executable proof; use commands/journey shape to create round-5 evidence. |

## Stale Or Obsolete Coverage Decisions

| Path / Scenario | Obsolete Assertion | Why Obsolete | Upstream Evidence | Replacement Coverage |
| --- | --- | --- | --- | --- |
| `tests/validate-source-contract.sh` | Active source must not mention `deadsnakes`; apt `python3-dev`, `python3-pip`, `python3-venv`, `python-is-python3`; venv built by generic `python3`; README Python 3.12 | RER-007 cleanly replaces the public/tool owner and explicitly requires Deadsnakes Python 3.13 | REQ-007; AC-010/013; design legacy-removal policy; IR-005 | Exact required Deadsnakes/3.13/venv/Supervisor source paths plus negative scans for old public/provider paths |
| `tests/validate-image.sh` | Public `python3`/`python` and `/usr/bin/python` resolve to 3.12; Deadsnakes absent; distribution Supervisor only implied | Contradicts the approved public 3.13 and sole isolated Supervisor behavior | RER-007; AC-006/010/013 | Exact public 3.13, preserved OS Python, package/source ownership, Supervisor 4.3.0 and stable tool path assertions |

No durable file or scenario was removed. Assertions were replaced in place to keep the existing three-layer harness structure.

## Durable Coverage Updated

| Scenario ID | Existing Path | Completed Update | Requirement / Design Evidence |
| --- | --- | --- | --- |
| AE2E-SCN-001 | `tests/validate-source-contract.sh` | Replace stale Python 3.12/no-Deadsnakes/distribution-provider assertions with exact Python 3.13/sole-tools-provider/entrypoint/stable-assets and rejected-path contracts | REQ-007; AC-009/010/013; DS-004/DS-005 |
| AE2E-SCN-002 | `tests/validate-image.sh` | Prove public versus OS interpreter separation, Deadsnakes package/source, isolated Supervisor/websockify/uv ownership, Supervisor 4.3.0, stable assets, and no apt daemon provider | AC-006/010/013 |
| AE2E-SCN-003 | `tests/validate-running-container.sh` | Prove exact Supervisor public/provider paths and version, PID/runtime Python 3.13 ownership, real config/control, websockify provider, and no prior traceback | AC-005/013 |

No new test file is needed: the current source/image/runtime boundary split is appropriate. No stale test file is removed.

## Repository And Broader Coverage Execution Results

| Order | Command / Mode | Boundary / Scenario | Result | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Updated all three durable harnesses; Bash syntax; ShellCheck; source contract; `git diff --check` | Current source and rejected legacy paths | Pass | `evidence/host-round5-source-and-preflight.log`; `evidence/host-round5-final-repository-checks.log` |
| 2 | Controlled real-script host alias/tag/load/push/no-cache/variant/unsupported matrix without a registry operation | Preserved wrapper / AE2E-SCN-006 | Pass | `evidence/host-round5-build-wrapper-regression.log` |
| 3 | Exact ARM64 default wrapper retry plus clean no-cache ARM64 `zh` and direct AMD64 default/`zh` builds | AC-003/004 target dependency resolution | Pass; initial unrelated Ubuntu mirror 404 resolved on exact retry | `host-round5-build-arm64-default.log`; `host-round5-build-arm64-default-retry1.log`; remaining four build logs |
| 4 | Final durable image harness on ARM64/AMD64 default/`zh` plus custom 1234:1234 | AC-001/006/007/010/013 | Pass, 5/5 | `evidence/host-round5-image-matrix.log` |
| 5 | Target-architecture APT/source/package/tool probes | AC-010 | Pass on AMD64 and ARM64 | `evidence/host-round5-python-origin-and-tools.log` |
| 6 | Normal-entrypoint runtime harness and host VNC/websockify/DevTools/semantic DOM on ARM64 and AMD64 default/`zh` | AC-005/006/007/013 | Pass, 4/4; final native rerun pass | Per-runtime logs; `host-round5-runtime-final-native-rerun.log` |
| 7 | Custom identity/XDG/DBus and normal/mobile-safe Chrome arguments | AC-005/006 | Pass | `host-round5-runtime-custom-1234.log`; `host-round5-mobile-safe.log` |
| 8 | Real Chromium/X/VNC Pinyin interaction | AC-007 | Pass; committed `你好` into semantic DOM | `host-round5-zh-vnc-ime-interaction.log`; `host-round5-zh-ime-authoritative.png` |
| 9 | Retained-profile recreation and stale Chromium/X lock recovery | AC-008 | Pass | `host-round5-profile-stale-lock-recovery.log` |
| 10 | Default and `zh` local no-push multi-platform OCI outputs with recursive platform/config inspection | AC-004 local pre-publication readiness | Pass; AMD64+ARM64 in both indexes | `host-round5-multiplatform-default.log`; `host-round5-multiplatform-zh.log` |
| 11 | Final repository regression and task-resource/tag cleanup | Quality/environment safety | Pass | `host-round5-final-repository-checks.log`; `host-round5-cleanup.log` |

### Execution Observation Requiring A Controlled Retry

The first exact ARM64 default no-cache attempt reached real BuildX and the reviewed Dockerfile, configured the expected Noble/Deadsnakes/NodeSource/XtraDeb inputs, and resolved Python 3.13 from Deadsnakes. It then failed in the broad Ubuntu dependency download because the `ports.ubuntu.com` Noble security index referenced five `ncurses` `1ubuntu2.2` archives that the mirror returned as HTTP 404. This is initially classified as an external repository mirror/index synchronization event, not an implementation finding: the missing archives are unrelated Ubuntu packages and the failure occurred before the changed provider layer. Evidence is `evidence/host-round5-build-arm64-default.log`.

The exact supported command was retried after a fresh no-cache repository read and passed; both the initial external failure and the authoritative retry are retained. The successful unchanged command isolates the event to the transient repository state rather than waiving it.

### Durable Image-Harness Observation And Correction Decision

The first round-5 executions of `tests/validate-image.sh` against the successful ARM64 default/`zh` images and AMD64 default image stopped at the harness-only assertion that a `python3.13-minimal` binary package must be installed. Direct target-image package ownership inspection shows that the Deadsnakes Noble package layout installs `/usr/bin/python3.13` from `python3.13`, the standard library from `libpython3.13-stdlib`, and the headers from `libpython3.13-dev`; there is no `python3.13-minimal` package in these successfully resolved target images. The approved behavior requires public Python 3.13, developer/venv support, Noble origin, and correct OS/public ownership, not a nonexistent package split.

This was classified as an API/E2E-owned durable-coverage defect, not an implementation failure. AE2E-SCN-002 was corrected narrowly to query the actual required packages (`python3.13`, `python3.13-dev`, `python3.13-venv`, plus the distribution Python packages) and retain direct `dpkg-query -S` ownership. All five final image cases passed. Evidence: `evidence/host-round5-image-matrix-part1.log` and the authoritative final sections of `evidence/host-round5-image-matrix.log`. The correction remains subject to proportional Code Review with the other round-5 durable edits.

The first normal-entrypoint ARM64 runtime execution then reached every required Supervisor service and passed host VNC, websockify HTTP, and DevTools probes, but AE2E-SCN-003 could not dereference `/proc/<websockify-pid>/exe` from the root `docker exec` shell: the container's procfs ptrace boundary returned `Permission denied` for the non-root `vncuser` process even though its observable command line was `/opt/browser-tools/bin/python /usr/local/bin/websockify ...`. PID 1, which runs as root, remained directly readable as `/usr/bin/python3.13`. A focused probe confirmed that the websockify owner (`vncuser`) can dereference its own executable and that `/opt/browser-tools/bin/python` resolves to `/usr/bin/python3.13`.

This was also classified as an API/E2E-owned assertion-context defect, not a product failure. A focused native probe first confirmed the process owner could resolve the isolated interpreter. The final cross-platform assertion, refined after the Rosetta observation below, retains direct process/cmdline/provider checks and searches the full NUL-delimited command vector for `/opt/browser-tools/bin/python`, then requires that path to resolve to `/usr/bin/python3.13`. It does not weaken the container security boundary or request extra capabilities. Evidence: `evidence/host-round5-runtime-arm64-default.log` and final runtime reruns.

The first AMD64 normal-entrypoint execution under Docker Desktop on the Apple Silicon host exposed a second procfs portability issue in that same new assertion. Docker Desktop's Rosetta execution path intentionally exposes `/run/rosetta/rosetta` as `/proc/<amd64-process>/exe`, including PID 1, while `/proc/<pid>/cmdline`, `ps`, the Supervisor provider shebang, and the running Python metadata still identify `/opt/browser-tools/bin/python` resolving to `/usr/bin/python3.13`. This is the emulator boundary, not a different image provider; the container itself reports `x86_64` and all reviewed services reached `RUNNING` before the assertion stopped.

AE2E-SCN-003 is therefore further corrected to prove each Python-owned process from its logical interpreter token in `/proc/<pid>/cmdline`, requiring `/opt/browser-tools/bin/python` to be present and to resolve to `/usr/bin/python3.13`, rather than require the host emulator's kernel executable link to equal an image path. The first attempted correction assumed that token would always remain argv[0]; the focused AMD64 rerun showed that Rosetta can prepend `/run/rosetta/rosetta` and duplicate the guest interpreter in the exposed command vector. The final assertion searches the complete NUL-delimited vector for the exact isolated interpreter and validates its resolved image path. PID 1's full command line must still contain only `/usr/local/bin/supervisord`, and websockify must still contain the stable public command. This remains strict on native ARM64 and is truthful under AMD64 emulation. Evidence: `evidence/host-round5-runtime-amd64-default.log` and its focused Rosetta/procfs probes.

A final acceptance-criteria trace review found that AE2E-SCN-002 exercised Node.js 22, Yarn, `uv`, and the broad preserved utility set but did not name the explicitly preserved GitHub CLI (`gh`) contract from AC-006/README; AE2E-SCN-001 also did not protect the package/docs declaration. The built images already contained `gh`, so this was a missing durable assertion rather than observed product failure. AE2E-SCN-001 now requires the Dockerfile `gh` package and README GitHub CLI statement, while AE2E-SCN-002 requires `gh` on PATH and a successful version command. The final source and five-image reruns passed, closing the documented-tool gap without adding a new file or compatibility path.

## Completed Execution Outcome

- API-REV-006 focused result: `Pass / 97%`; `APIE2E-TEST-F-001` corrected in durable state, proportional re-review pending. No Docker/image/runtime rerun was required because the correction was assertion-discrimination-only and current source matched every tightened literal line.
- Existing coverage final decisions: all three repository-resident harnesses are `Updated / Pass`; alias coverage remains `Still Valid / Pass`; pre-IR-005 evidence remains context only.
- Durable coverage files added/removed: none. Updated: `tests/validate-source-contract.sh`, `tests/validate-image.sh`, `tests/validate-running-container.sh`.
- Acceptance-criteria result: AC-001 through AC-010 and AC-013 `Pass`; AC-011 is locally ready for Delivery but not executed remotely; AC-012 remains correctly deferred until verified publication.
- Prior failures: APIE2E-F-001 and APIE2E-F-002 remain resolved. No new implementation failure ID was opened.
- Initial external failure: one Ubuntu ARM64 mirror/index mismatch returned unrelated `ncurses` 404s; the exact supported no-cache command passed on controlled retry.
- API/E2E-owned corrections: replaced a nonexistent `python3.13-minimal` assumption; made process-provider inspection valid for native procfs and Docker Desktop Rosetta; corrected a temporary origin-probe quoting defect; added the omitted documented `gh` contract. Every corrected path was rerun to Pass.
- Broader-validation decision/result: `Required and completed`.
- Final result/confidence: `Pass / 97%`.

## Initial Confidence Scorecard

The implementation has passed source review but no IR-005 image has yet been built or run in this API/E2E round. Scores are therefore intentionally below the clean threshold until execution.

| Category | Initial Score | Supporting Evidence | Remaining Uncertainty / Improvement |
| --- | ---: | --- | --- |
| Requirement and acceptance-criteria proof | 65% | Approved RER-007/design and CRR-006 source traceability | Build/runtime/publication-local behavior not yet directly proven; execute full matrix |
| Changed-boundary execution directness | 50% | Source probes and prior feasibility evidence | No current built-image path/provider/config execution; build and run real images |
| Cross-boundary integration realism/mock gap | 50% | Prior release and pre-IR-005 journeys establish feasible mechanisms | Current Noble/3.13/Supervisor composition not executed; real containers/protocols/browser needed |
| Environment/configuration/identity/fixture fidelity | 55% | Host Docker/BuildX previously available | Current platform/variant/custom identity state not measured; preflight and matrix needed |
| Failure/edge/lifecycle/recovery evidence | 55% | Prior stale-lock and alias journeys inform plan | Current entrypoint/provider and recovery not run; execute lifecycle/alias/error paths |
| User surface/browser/desktop confidence | 50% | Prior DevTools/VNC/Pinyin journey shape | Current image/browser/service graph not run; semantic browser and IME journey needed |
| Durable regression coverage quality | 50% | Three coherent durable harnesses exist | All three encode or omit superseded provider assertions; update and review required |

- Initial overall confidence: `54%` (rounded simple average).
- Every critical acceptance criterion directly proven for IR-005: `No`.
- Applicable category below 90%: `Yes — all`.
- Broader-validation decision: `Required`.
- Selected modes: real Docker/BuildX CLI, cross-architecture container lifecycle, protocol/browser semantic probes, and X/VNC input interaction.
- Expected confidence after a fully passing matrix: `95–97%`, with publication/remote verification explicitly remaining Delivery-owned.

## Post-Repository And Final Confidence Scorecards

| Category | Post-Repository | Final | Final Evidence / Residual |
| --- | ---: | ---: | --- |
| Requirement and acceptance-criteria proof | 90% | 96% | AC-001–010/013 directly pass; AC-011 remote and AC-012 sequencing remain outside this gate. |
| Changed-boundary execution directness | 95% | 100% | Real clean images, exact wrapper, public/OS Python ownership, isolated Supervisor and normal entrypoint executed. |
| Cross-boundary integration realism and mock gap | 88% | 97% | Real repositories, BuildX, containers, services, protocols and browser; only non-host wrapper aliases used controlled doubles. |
| Environment/configuration/identity/fixture fidelity | 92% | 98% | Both targets/variants, default/custom identity, XDG/DBus, profiles and host ports exercised. |
| Failure/edge/lifecycle/recovery evidence | 88% | 97% | Mirror retry, wrapper errors, native/Rosetta process boundaries, mobile-safe, stale locks and recreate recovery pass. |
| User-surface/browser/desktop confidence | 70% | 97% | Semantic DevTools render and real X/VNC Pinyin commit close the initial live gap. |
| Durable regression coverage quality/relevance | 94% | 95% | Three focused harnesses pass final reruns; proportional Code Review remains mandatory. |

- Overall post-repository confidence: `88%` (simple average, rounded).
- Overall final confidence: `97%` (simple average, 97.1%, rounded).
- Applicable final category below 90%: `None`.
- Critical API/E2E/pre-publication-local criterion missing or failing: `None`.
- Default clean target met: `Yes`.

## Live Environment, Fixtures, And Cleanup Result

- Docker Desktop `29.0.1`, BuildX `v0.29.1-desktop.1`, BuildKit `v0.26.2`, and the existing `multi-platform-builder` reported native/emulated `linux/arm64` and `linux/amd64`.
- Task-only containers, volumes, ports, image aliases and OCI archives isolated the run. No account, authentication or secret was required.
- All task containers, volumes, transient OCI archives, and aliases were removed. Pre-existing `latest` and `zh` tags were restored to their recorded full image IDs; task-created `1.4.0` and `1.4.0-zh` tags were removed because they were absent initially.
- The shared builder/cache was retained and no global prune was used.
- Docker Hub and the AutoByteus server repository were not mutated.

## Temporary Executable Validation Plan

| Scenario | Method | Behavior Proven | Why Not Durable |
| --- | --- | --- | --- |
| AE2E-SCN-006 | PATH-injected controlled `uname`/`docker` boundaries around the real build script | Apple/Linux ARM aliases, AMD64, default/zh tags, load/push command composition, unsupported host | Durable source alias assertion protects the regression; a second mock framework is disproportionate and cannot replace real BuildX |
| AE2E-SCN-007 | Target-architecture ephemeral APT policy/source probes | Deadsnakes Noble origin and resolved package versions | Network-backed policy is mutable and expensive; durable image harness asserts installed source/package ownership |
| AE2E-SCN-008 | Task-isolated real VNC/X input automation and screenshot | Pinyin availability and committed Chinese text | Desktop timing/first-run prompts make this unsuitable as a small repository shell harness; retain direct evidence |
| AE2E-SCN-009 | Multi-platform `type=oci` BuildX outputs | Both target manifests are locally buildable without publication | Outputs are multi-gigabyte transient artifacts; durable build script/platform assertions remain |

## Not Tested / Deferred

| Boundary | Reason | Risk / Follow-up |
| --- | --- | --- |
| Docker Hub `1.4.0`, `latest`, `1.4.0-zh`, `zh` publication and remote runtime identity | Explicitly prohibited in this API/E2E handoff | Delivery must publish and verify both manifests only after local pass and proportional test review |
| AutoByteus server adoption | REQ-009 separate ticket after verified publication | Server work remains blocked; use immutable verified identity later |

## Investigation Decision

- Coverage investigation refreshed before IR-006/IR-007 execution and kept current: `Yes`.
- Existing coverage outcome: wrapper harness and source contract `Still Valid / Pass`; image/runtime harnesses and API-REV-005 product evidence `Still Valid / Not Rerun`.
- Repository-resident durable coverage change by API/E2E: `None`; Code Review should record the proportional test-code review as `Not Applicable` before routing to Delivery.
- Broader validation: `Required and completed` — current non-publishing deterministic wrapper and fixture-lifecycle matrix.
- Final result/confidence: `Pass / 97%`; no category below 90%; no local blocker.
- Residual: only real credential-helper/registry authorization and AC-011 remote publication/runtime verification, explicitly owned by Delivery.
- Publication/server boundary observed: no Docker Hub request/mutation and no AutoByteus server access.
- Successful-result route: `/code_reviewer` with the cumulative package and API-REV-007 evidence for a `Not Applicable` proportional test-code review; Delivery follows that recorded result.
