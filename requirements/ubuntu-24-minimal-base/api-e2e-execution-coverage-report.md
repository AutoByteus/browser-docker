# API/E2E Execution Coverage Report

## Execution Round Meta

- Ticket: `BRD-UBUNTU24-001`
- Current API/E2E revision / round: `API-REV-006` / focused round 6 CRR-007 Local Fix re-entry
- Requirements / revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-doc.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` (`RER-007`)
- Investigation / design: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/investigation-notes.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/design-spec.md` (`SR-002`)
- Design review / revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/design-review-report.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/architecture-review-revision-record.md` (`ARCH-REV-002`, Pass)
- Supplemental artifact: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md`
- Implementation / revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-handoff.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/implementation-revision-record.md` (`IR-005`)
- Source review / revision: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-report.md`; `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/code-review-revision-record.md` (`CRR-006`, Pass / 95.8%)
- Triggering test review: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-test-review-report.md` (`CRR-007`, Fail — `APIE2E-TEST-F-001` bounded API/E2E Local Fix; image/runtime test changes Pass)
- Coverage investigation: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-coverage-investigation.md`
- API/E2E revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/api-e2e-revision-record.md`
- Implementation under test / worktree HEAD: `f902e80771b304916858314fa9484cab8f6f1843` (reviewed parent `cc30abff0769553c84fb1ebb453c28e6123f4218`)
- Prior completed API/E2E result: `API-REV-005 — Pass / 97%`; broader Docker/runtime evidence retained
- Execution environment: macOS Apple Silicon; Docker Engine `29.0.1`; Docker Desktop `4.52.0`; BuildX `v0.29.1-desktop.1`; BuildKit `v0.26.2`; builder `multi-platform-builder`
- Latest authoritative execution report: this file

## Latest Authoritative Result

- Result: `Pass`.
- Final validation confidence: `97%` (97.1% simple average, rounded).
- Default 95% target met: `Yes`.
- Final applicable category below 90%: `None`.
- Broader validation decision: `Not Required` for the focused assertion-discrimination fix; API-REV-005 broader validation was Required/completed and remains authoritative.
- Critical API/E2E/pre-publication-local acceptance criterion lacking direct proof: `None`.
- New or remaining implementation failure IDs: `None`; `APIE2E-TEST-F-001` is corrected in durable state and awaits proportional re-review.
- Required next recipient: `/code_reviewer` for focused proportional re-review of `tests/validate-source-contract.sh`; the other two durable files already passed CRR-007.
- Publication/server boundary: no Docker Hub push or remote verification; no AutoByteus server-repository access or modification.

This result proves local pre-publication readiness. It does not claim AC-011 remote Docker Hub publication/manifest/runtime verification or AC-012 server adoption; those remain deliberately sequenced after proportional test review.

## API-REV-006 Focused Local-Fix Delta

- Trigger: CRR-007 demonstrated that three round-5 source regexes could pass against prefix/suffix-confounding declarations, finding `APIE2E-TEST-F-001`. This was a durable-test correctness defect, not an implementation or API-REV-005 execution failure.
- Correction: added `assert_literal_line`, then changed the explicit `python3.13`, `python3.13-dev`, `python3.13-venv`, public `python3`, and public `python` declarations to complete literal-line assertions.
- Positive execution: the corrected source harness passes against the current reviewed Dockerfile.
- Negative discrimination: five isolated fixtures each remove or replace one exact declaration while retaining the relevant longer/adjacent confounder. Every fixture is rejected with the expected missing-literal diagnostic.
- Focused checks: `bash -n` Pass; `shellcheck -e SC2016` Pass with no diagnostics; current source contract Pass; five negative fixtures Pass; `git diff --check` Pass.
- Evidence: `requirements/ubuntu-24-minimal-base/evidence/host-round6-source-contract-fix.log`, final authoritative section.
- Source mismatch exposed: `No`; the tightened assertions all match the current Dockerfile exactly.
- Broader rerun rationale: `Not Required`. No product source changed, CRR-006 remains Pass, CRR-007 explicitly accepted the image/runtime harnesses, and API-REV-005's successful real Docker matrix remains current.
- Result/confidence: `Pass / 97%`; confidence is unchanged because this round repairs regression-test discrimination rather than adding product-boundary evidence.

## Investigation And Coverage Decisions

- Mandatory coverage investigation completed before durable edits and execution: `Yes`.
- Upstream package reviewed: RER-007, SR-001/SR-002, ARCH-REV-002, IR-005, CRR-006, persistence/legacy decisions, and prior API/E2E context.
- Existing coverage validity:
  - `tests/validate-source-contract.sh`: CRR-007 `Needs Update` -> API-REV-006 `Updated / Pass`; exact literal lines and five discrimination fixtures now protect the intended declarations.
  - `tests/validate-image.sh`: `Needs Update` -> `Updated / Pass`.
  - `tests/validate-running-container.sh`: `Needs Update` -> `Updated / Pass`.
  - build alias scenario: `Still Valid / Pass`, rerun through controlled and exact real-host execution.
  - pre-IR-005 runtime evidence: context only, not counted as current proof.
- Durable coverage files added: none.
- Durable coverage files removed: none.
- Requirement/design ambiguity: none; no requirement or design reroute was needed.
- Invalid compatibility/legacy retention observed or protected: none. Public Python is strictly 3.13; Noble's separate `/usr/bin/python3` remains distribution-owned 3.12 and is not a compatibility selector.
- Approved persisted-data decision: `Not Affected`; direct profile reuse and supported stale-lock recovery were rerun.

## Durable Coverage Changed

| Path | Current-Round Update | Requirement / Boundary | Final Result |
| --- | --- | --- | --- |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-source-contract.sh` | Round 5 replaced stale provider assertions; round 6 adds a literal-line helper and exact package/public-selector declarations resolving `APIE2E-TEST-F-001` | AC-001–004, AC-006, AC-009/010/013 | Pass; focused proportional re-review required |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-image.sh` | Requires public `/usr/local` Python 3.13 versus Noble `/usr/bin/python3` 3.12 ownership, actual Deadsnakes Noble package/source layout, isolated Supervisor/websockify/`uv`, stable assets, `gh`, utilities, locale/variant and identity | AC-001, AC-006/007/010/013 | Pass on five images |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/tests/validate-running-container.sh` | Requires real Supervisor 4.3.0 control/PID1, isolated Python 3.13 provider in full process command vectors, no prior traceback, stable websockify/`uv`, services/protocol/DOM/profile behavior; valid on native and Docker Desktop Rosetta | AC-005–008, AC-013 | Pass across ARM64/AMD64 default/`zh`, mobile-safe and custom identity |

Focused proportional re-review of `tests/validate-source-contract.sh` is mandatory. CRR-007 already passed the image/runtime test changes, so those paths require no repeat review unless changed again.

## Changed Boundary And Evidence Matrix

| Scenario | Requirement / AC | Execution Surface | Result | Authoritative Evidence |
| --- | --- | --- | --- | --- |
| AE2E-SCN-001 | AC-001–003/009/010/013 | Bash/ShellCheck/source contract; exact Apple ARM64 clean wrapper | Pass | `host-round5-final-repository-checks.log`; `host-round5-build-arm64-default-retry1.log` |
| AE2E-SCN-002 | AC-001/002/006/007/010/013 | Five clean built images and final durable image harness | Pass, 5/5 | `host-round5-image-matrix.log`; clean build logs |
| AE2E-SCN-003 | AC-005–008/013 | Normal entrypoint, Supervisor services, VNC/websockify/DevTools, semantic Chromium, profile write | Pass | four runtime logs; `host-round5-runtime-final-native-rerun.log` |
| AE2E-SCN-006 | AC-003/004 | Exact real Apple ARM64 wrapper plus controlled aliases/tags/load/push/errors | Pass | `host-round5-build-wrapper-regression.log`; exact build retry log |
| AE2E-SCN-007 | AC-010 | Target-architecture APT policy/source/package and isolated-tool metadata | Pass, AMD64+ARM64 | `host-round5-python-origin-and-tools.log` corrected authoritative sections |
| AE2E-SCN-008 | AC-007 | Real X/Chromium/VNC/fcitx5 Pinyin interaction | Pass; DOM value `你好` | `host-round5-zh-vnc-ime-interaction.log`; `host-round5-zh-ime-authoritative.png` |
| AE2E-SCN-009 | AC-004 | Local no-push OCI indexes for both variants | Pass; AMD64+ARM64 manifests in both | `host-round5-multiplatform-default.log`; `host-round5-multiplatform-zh.log` |
| Lifecycle/recovery | AC-008 | Recreate on retained profile plus known stale Chromium/X locks | Pass | `host-round5-profile-stale-lock-recovery.log` |
| Identity/mobile-safe | AC-005/006 | Custom 1234:1234 XDG/DBus/profile; normal versus mobile-safe Chrome | Pass | `host-round5-runtime-custom-1234.log`; `host-round5-mobile-safe.log` |

## Acceptance-Criteria Results

| AC | Result | Direct Evidence / Scope Note |
| --- | --- | --- |
| AC-001 | Pass | Dockerfile and every tested image use official `ubuntu:24.04`; image OS identity is Ubuntu Noble 24.04. |
| AC-002 | Pass | Source/base inspection and real Docker Official Ubuntu base resolution; no alternative base introduced. |
| AC-003 | Pass | Exact `./build-multi-arch.sh --no-cache` on real `uname -m=arm64` reached BuildX, selected `linux/arm64`, clean-built, tagged and loaded. Initial unrelated Ubuntu mirror 404 passed on controlled exact retry. |
| AC-004 | Pass for local pre-publication gate | Clean default/`zh` images pass separately for ARM64/AMD64; local no-push OCI outputs each contain both platform manifests with correct variant/identity config. |
| AC-005 | Pass | ARM64 and AMD64 default/`zh` normal-entrypoint containers remained running; Supervisor services, VNC, websockify HTTP, DevTools and semantic Chromium render passed. |
| AC-006 | Pass | Default/custom identity, UID/GID, XDG/DBus/profile ownership, public Python 3.13, `gh`, Node 22, Yarn, `uv`, documented utilities and `en_US.UTF-8` passed; normal/mobile-safe Chrome behavior preserved. |
| AC-007 | Pass | `zh` package/locale/fcitx configuration, English default, Pinyin availability and real committed `你好` input passed. |
| AC-008 | Pass | Existing marker survived recreation; known stale Singleton/X artifacts were cleared; fresh live locks and normal services recovered. |
| AC-009 | Pass | Source contract and active documentation identify Ubuntu 24.04 and current build/run/tool contracts. |
| AC-010 | Pass | AMD64/ARM64 resolve Python `3.13.15-1+noble1` from Deadsnakes Noble; public commands resolve through `/usr/local` to `/usr/bin/python3.13`; OS `/usr/bin/python3` remains 3.12; `/opt/browser-tools` is Python 3.13 and owns tools. |
| AC-011 | Ready for Delivery; not executed here | Local release-equivalent gate passes. Docker Hub publication, remote manifests and published-image runtime identity were explicitly prohibited for this handoff. |
| AC-012 | Deferred as designed | Server adoption remains a separate ticket after verified publication; server repository was not touched. |
| AC-013 | Pass | Stable commands resolve to one Python 3.13 `/opt/browser-tools` owner; Supervisor/control report 4.3.0 and real config/services run without prior traceback; web assets, VNC/websockify/DevTools pass. |

## Commands And Results

| Order | Exact Command / Mode | Result | Evidence |
| --- | --- | --- | --- |
| 1 | Docker/BuildX/builder preflight; Bash syntax; initial source contract; `git diff --check` | Pass | `host-round5-source-and-preflight.log` |
| 2 | Real `build-multi-arch.sh` with controlled `uname`/`docker` boundaries for `arm64`, `aarch64`, `x86_64`, default/`zh`, load/no-cache/push/tag/error composition; no registry operation | Pass | `host-round5-build-wrapper-regression.log` |
| 3 | `./build-multi-arch.sh --no-cache` | Initial unrelated Ubuntu mirror/index 404; exact controlled retry Pass, ARM64, loaded/tagged | `host-round5-build-arm64-default.log`; `host-round5-build-arm64-default-retry1.log` |
| 4 | `./build-multi-arch.sh --variant zh --no-cache` | Pass, ARM64 `zh`, loaded/tagged | `host-round5-build-arm64-zh.log` |
| 5 | Direct `docker buildx build --no-cache --platform linux/amd64 --load` for default and `zh` task tags | Pass, both | `host-round5-build-amd64-default.log`; `host-round5-build-amd64-zh.log` |
| 6 | Direct clean ARM64 custom build with `USER_UID=1234`, `USER_GID=1234` | Pass | `host-round5-build-arm64-custom-1234.log` |
| 7 | Final `tests/validate-image.sh` matrix: ARM64/AMD64 default/`zh`, custom 1234 | Pass, 5/5 | `host-round5-image-matrix.log` |
| 8 | Corrected target-origin/tool probes on ARM64 and AMD64 | Pass, 2/2 | `host-round5-python-origin-and-tools.log` |
| 9 | `tests/validate-running-container.sh` through normal entrypoint on default/`zh` ARM64/AMD64, plus host port/protocol checks | Pass | per-runtime logs; final native rerun log |
| 10 | Normal/mobile-safe Chromium parent-argument checks and full mobile-safe runtime harness | Pass | `host-round5-mobile-safe.log` |
| 11 | Real zh Chromium/X/VNC/fcitx input automation | Pass | interaction log and screenshot |
| 12 | Profile marker/recreate/stale-lock recovery | Pass | profile recovery log |
| 13 | `docker buildx build --builder multi-platform-builder --platform linux/amd64,linux/arm64 --output type=oci,...` for default and `zh`; recursive OCI manifest/config inspection | Pass; no push | both multi-platform logs |
| 14 | Final Bash syntax, ShellCheck excluding only documented SC2086/SC2016 cases, source contract, `git diff --check` | Pass | `host-round5-final-repository-checks.log` |
| 15 | Remove task resources and restore original official local tags by full image ID | Pass | `host-round5-cleanup.log` |

## Observed Failures And Corrections

No final product failure remains.

1. **External mirror synchronization:** the first exact ARM64 default build failed while downloading unrelated Noble `ncurses` archives that the Ubuntu ports index referenced but returned HTTP 404. The exact no-cache command passed on the controlled retry with fresh repository metadata. Classification: transient external repository state, not an implementation failure.
2. **Image-harness package split:** the first image matrix assumed a nonexistent Noble `python3.13-minimal` package. The actual Deadsnakes layout provides `/usr/bin/python3.13` from `python3.13`. The durable test was corrected to the approved package/ownership behavior and all five final cases passed. Classification: API/E2E-owned coverage correction.
3. **Runtime procfs portability:** initial new process assertions relied on `/proc/<pid>/exe`; native non-root ptrace restrictions and Docker Desktop Rosetta (`/run/rosetta/rosetta`) make that host-kernel view unsuitable. The durable assertion now requires the exact isolated interpreter anywhere in the full NUL-delimited process command vector and resolves it to `/usr/bin/python3.13`. Native and emulated final reruns passed. Classification: API/E2E-owned coverage correction, not a mixed provider.
4. **Temporary origin probe quoting:** the first evidence-only probe had a shell quoting error. Corrected target probes passed on both architectures. Classification: temporary evidence harness correction.
5. **`gh` trace gap:** a final AC trace found that the existing image/source harnesses did not explicitly protect the documented GitHub CLI. Exact source/docs/command/version assertions were added and final source/image reruns passed. Classification: missing durable assertion closed before result.

All superseded failure output remains in the evidence logs for auditability and is explicitly separated from the final authoritative reruns.

## Prior Failure Resolution

| Failure | Prior State | Round-5 Result |
| --- | --- | --- |
| `APIE2E-F-001` — Noble default UID/GID collision | Resolved in IR-002 and prior API/E2E | Remains resolved across both architectures, both variants and custom 1234:1234 build/runtime. |
| `APIE2E-F-002` — Apple Silicon `arm64` wrapper rejection | Resolved in IR-003/API-REV-004 | Remains resolved: exact real-host command reaches BuildX, selects ARM64, clean-builds, tags, loads and passes current image/runtime gates. |

## Built-Target And Runtime Identity

- Clean local image IDs:
  - ARM64 default: `sha256:4f8b0cbd1cd11f0d36f1e53600b5388a89b9522c9e95995cb06344dae29b8997`
  - ARM64 `zh`: `sha256:56fbe31767162618582e6e1b77381382dbe1ba2ea4377ba5572f709b61e157de`
  - AMD64 default: `sha256:4f5deb58580f0f461d048e9228816c183ace34a1120cf6a6fb1eedde7aad0d14`
  - AMD64 `zh`: `sha256:1231fe673fc12d845353f1af5f4b43412c55a56c8b2b1360298e62dc244d3026`
  - ARM64 custom 1234:1234: `sha256:3dab483b4f7ce7b406ef1eb3a7ea8cb21c5270342ada8240d89d48b444469cf4`
- Target identity on AMD64 and ARM64: Ubuntu `24.04` Noble; public Python `3.13.15`; OS Python `3.12.3`; Python package `3.13.15-1+noble1` from `ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu noble/main`.
- Isolated tool owner/version: `/opt/browser-tools` Python `3.13.15`; Supervisor `4.3.0`; websockify `0.13.0`; `uv` `0.12.8`.
- Live Chromium evidence: `Chrome/151.0.7922.173`; VNC RFB `003.008`; websockify HTTP and DevTools semantic DOM pass.
- Local OCI indexes:
  - default index `sha256:974668c479d352718c684ac6fdce41bdeed07705afcb7ede7c82cdf361b5612d`
  - `zh` index `sha256:80a8662dc5f0de285587bb3248090491e3e7f93f9d849a79e539c749919e5995`
  - each recursively inspected index contained exact `linux/amd64` and `linux/arm64` image manifests with variant and 1000:1000 config.

These are local validation identities, not published immutable Docker Hub digests.

## Confidence Scorecard

| Category | Post-Repository | Final | Final Evidence / Residual |
| --- | ---: | ---: | --- |
| Requirement and acceptance-criteria proof | 90% | 96% | AC-001–010/013 directly pass; AC-011 remote and AC-012 sequencing remain outside this gate. |
| Changed-boundary execution directness | 95% | 100% | Real clean images, exact wrapper, public/OS Python ownership, isolated Supervisor and normal entrypoint executed. |
| Cross-boundary integration realism and mock gap | 88% | 97% | Real repositories, BuildX, containers, services, protocols and browser; only non-host wrapper aliases used controlled doubles. |
| Environment/configuration/identity/fixture fidelity | 92% | 98% | Both targets/variants, default/custom identity, XDG/DBus, profiles and host ports exercised. |
| Failure/edge/lifecycle/recovery evidence | 88% | 97% | Mirror retry, wrapper errors, native/Rosetta boundaries, mobile-safe, stale locks and recreation pass. |
| User-surface/browser/desktop confidence | 70% | 97% | Semantic DevTools render and real X/VNC Pinyin commit close the initial live gap. |
| Durable regression coverage quality/relevance | 94% | 95% | Three requirement-linked harnesses pass final reruns; proportional Code Review remains pending. |

- Overall post-repository confidence: `88%` (simple average, rounded).
- Overall final confidence: `97%` (97.1%, rounded).
- Confidence gain: real target builds, provider/runtime execution, both platform/variant indexes, lifecycle, browser and desktop-input evidence closed the initial IR-005 gaps.
- Applicable final category below 90%: `None`.
- Default clean target met: `Yes`.

## Dependencies Mocked Or Emulated

- Critical native Apple ARM64 path: real Docker/BuildX, repositories, image, normal entrypoint and browser; not mocked.
- AMD64: real AMD64 images/build manifests executed through Docker Desktop's supported emulation/Rosetta boundary on Apple Silicon. The image/provider contract was asserted from guest paths and full process command vectors rather than the host emulator's `/proc/exe` link.
- Controlled `uname`/`docker` doubles: used only for non-host alias and command-composition regression, including multi-platform `--push` composition. They never contacted a registry and do not substitute for the real ARM64 or local multi-platform builds.
- External package services: real Ubuntu, Deadsnakes, XtraDeb, NodeSource and PyPI endpoints were used by clean builds; no package mock was used.

## Broader Validation And User-Surface Evidence

- Decision/mode: `Required and completed`; real CLI/BuildX, image/runtime lifecycle, protocols, semantic Chromium, and X/VNC desktop input.
- Service readiness: Supervisor real config/control plus XFCE, TigerVNC, Chromium, socat, websockify and fcitx5 where applicable.
- Browser: semantic DOM was asserted through the real Chromium DevTools WebSocket, not by screenshot alone.
- Desktop input: the task-owned zh desktop dismissed the first-run keyring prompt, focused Chromium, toggled Pinyin with Ctrl+Space and committed `你好` into the DOM. The screenshot is supporting evidence.
- Persistence/recovery: a normal runtime-written profile marker remained after recreation; stale supported Chromium/X lock artifacts were replaced by fresh live locks without migration or profile deletion.

## Cleanup And Mutation Boundaries

| Resource / Boundary | Result |
| --- | --- |
| Six task containers and six task profile volumes | Stopped and removed |
| Five task image aliases plus backup aliases | Removed without force |
| Temporary default/`zh` OCI archives and parser | Removed after manifest/config evidence capture |
| Pre-existing local `latest` | Restored to `sha256:f5a12a4fc553d40158b6d6c5f87e3ea0a2bcfbc71e3cb8153f7a3aa310241029` |
| Pre-existing local `zh` | Restored to `sha256:24ca92cb4a274be088901f679ae9bb31317d2b73c3ab954d2fc8f631e6713071` |
| Task-created `1.4.0` and `1.4.0-zh` | Removed because both were absent at baseline |
| Shared BuildX builder/cache | Retained; no global prune |
| Docker Hub | No authentication/push/remote mutation |
| AutoByteus server repository | No access or modification |

## Evidence Inventory

All paths are under `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/`:

- `host-round5-source-and-preflight.log`
- `host-round5-build-wrapper-regression.log`
- `host-round5-tag-baseline.log`
- `host-round5-build-arm64-default.log` (initial transient mirror failure retained)
- `host-round5-build-arm64-default-retry1.log` (authoritative exact retry Pass)
- `host-round5-build-arm64-zh.log`
- `host-round5-build-amd64-default.log`
- `host-round5-build-amd64-zh.log`
- `host-round5-build-arm64-custom-1234.log`
- `host-round5-image-matrix-part1.log` (superseded harness assumption retained)
- `host-round5-image-matrix.log` (authoritative final 5/5 Pass)
- `host-round5-python-origin-and-tools.log` (corrected authoritative sections identified in log)
- `host-round5-runtime-arm64-default.log`
- `host-round5-runtime-arm64-zh.log`
- `host-round5-runtime-amd64-default.log`
- `host-round5-runtime-amd64-zh.log`
- `host-round5-runtime-custom-1234.log`
- `host-round5-runtime-final-native-rerun.log`
- `host-round5-mobile-safe.log`
- `host-round5-profile-stale-lock-recovery.log`
- `host-round5-zh-vnc-ime-interaction.log`
- `host-round5-zh-ime-authoritative.png`
- `host-round5-multiplatform-default.log`
- `host-round5-multiplatform-zh.log`
- `host-round5-final-repository-checks.log`
- `host-round5-cleanup.log`
- `host-round6-source-contract-fix.log` (API-REV-006 authoritative focused validation)

## Result Summary And Route

| Result | Scenario / Scope | Summary |
| --- | --- | --- |
| Pass | AE2E-SCN-001/002/003/006/007/008/009; AC-001–010/013 | All current local build, image, provider, runtime, browser, desktop-input, persistence/recovery and no-push multi-platform gates passed. |
| Ready for Delivery, not executed | AC-011 | Local pre-publication evidence is complete; remote publication/verification must wait for proportional test review. |
| Deferred as designed | AC-012 | Separate server adoption begins only after verified publication. |

Required next recipient: `/code_reviewer`. Requested action: focused proportional re-review of the `tests/validate-source-contract.sh` literal-line correction and negative-discrimination evidence for `APIE2E-TEST-F-001`. `tests/validate-image.sh` and `tests/validate-running-container.sh` already passed CRR-007 and were not changed in API-REV-006. No implementation-source rework, failure-origin review, or full Docker rerun is requested. Delivery remains blocked until this focused review passes.
