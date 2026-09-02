# Requirements Investigation Notes

## Investigation Meta

- Request / ticket: `BRD-UBUNTU24-001`
- Workspace root: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base`
- Repository mode: `Git`
- Dedicated task worktree / branch: `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base`; `requirements/ubuntu-24-minimal-base`
- Tracked upstream: `origin/requirements/ubuntu-24-minimal-base` at `951da036e1f6e600b79e7ba7ee8897a3108410af`
- Current integrated branch revision: `cc30abff0769553c84fb1ebb453c28e6123f4218`
- Resolved base and expected finalization branch: `origin/main` / `main`; refreshed 2026-09-01 at `fb0f59372254b853e85c69046aa921f1d59d96c7`
- Current relation to base: `HEAD...origin/main = 14 ahead / 0 behind`; `cc30abf` is a merge of the pre-integration ticket candidate and current `origin/main`.
- Bootstrap result: Existing dedicated ticket worktree reused; remote refs refreshed successfully. Uncommitted Delivery-owned artifact edits were present before this rework and were not overwritten.
- Current requirements revision ID: `RER-007`
- Current solution revision ID: `SR-002`
- Investigation status: Complete for revised design re-review. `ARCH-REV-001` otherwise passed the structural design and returned only `ARCH-F-001`; the active server-adoption brief and stale DEC-003 statement are corrected in SR-002. Full final Docker build/runtime/publication validation remains downstream.

## Initial Request, Approval, And Re-entry

- Original request: replace the too-old Ubuntu 22 browser image base with the stable minimal Ubuntu 24 base.
- Clarified/approved scope: “minimal” means Canonical's official minimal Ubuntu OCI base, not pruning the installed browser/desktop/tool payload. Browser image `1.4.0`/`1.4.0-zh` is ticket one; server/all-in-one adoption is a separate ticket after verified publication.
- Superseded decision: RER-004/RER-006 selected Noble-native Python 3.12.
- Re-entry trigger: after `IR-004` integrated current `origin/main`, the user stated, “i would still use 3.13, because main branch has already tested so i believe they have a reason why they use 3.13”.
- Re-entry classification: `Requirement Gap` for the Python target plus `Design Impact` because interpreter source/ownership intersects Supervisor, the entrypoint, pip-installed operational tools, and stable asset paths.
- Guardrail: integrated commit `cc30abf` is evidence and a starting point only; it must not advance as the final target while it still selects Python 3.12 and distribution Supervisor.

## Product And Domain Understanding

- Product area: multi-architecture browser/desktop Docker image with Chromium, XFCE, TigerVNC, websockify, remote debugging, developer runtimes/tools, optional Chinese locale/input, persistent Chromium profiles, and configurable runtime identity.
- Operational actor: image maintainer builds locally or publishes default/`zh` manifests for AMD64/ARM64.
- Runtime actor: downstream container user starts the image through supported run/Compose surfaces and reaches VNC, websockify, and Chromium DevTools.
- Publication actor: Delivery publishes immutable `1.4.0`/`1.4.0-zh` plus rolling `latest`/`zh` only after the integrated validation gate passes.
- Relevant terms:
  - **Distribution interpreter**: Noble's `/usr/bin/python3` owned by Ubuntu packages; currently Python 3.12.
  - **Developer interpreter**: public `python3`/`python` behavior promised by this image; revised target Python 3.13.
  - **Operational tools environment**: `/opt/browser-tools`, one Python 3.13 virtual environment that owns Supervisor 4.3.0, websockify, and `uv`.
  - **Stable public path**: a version-independent `/usr/local/bin/*` or `/usr/local/share/websockify` path that does not expose a `python3.13/site-packages` location to service configuration.

## Source Log

| Date | Source Type | Exact Source / Command / Query | Why Consulted | Relevant Finding | Follow-Up |
| --- | --- | --- | --- | --- | --- |
| 2026-09-01 | User | Original ticket conversation and RER-001–RER-006 | Establish approved base, scope, release, preservation, and sequencing contracts. | Ubuntu 24.04 minimal official base, version 1.4.0, default/`zh`, AMD64/ARM64, preserved runtime, publish-first sequencing were approved. | Preserve all except the superseded Python version. |
| 2026-09-01 | User | Downstream Python decision relayed by Implementation Engineer | Resolve the contradiction after IR-004. | User explicitly chose Python 3.13 because main had already tested it. | Revise REQ-007/ACs and design before implementation. |
| 2026-09-01 | Command | `git fetch origin --prune`; `git rev-parse`; `git rev-list --left-right --count HEAD...origin/main` | Verify authoritative worktree and latest tracked base. | Worktree is on `cc30abf`; `origin/main=fb0f593`; branch is 14 ahead / 0 behind. | Use this integrated tree as current-state evidence. |
| 2026-09-01 | Code | Current `Dockerfile`, `base.conf`, `entrypoint.sh`, `start-chrome.sh`, `build-multi-arch.sh`, README, VERSION | Inspect the real integrated candidate. | Candidate uses `ubuntu:24.04`, Python 3.12, distribution Supervisor, Python 3.12 `/opt/browser-tools`, stable websockify assets, dynamic UID paths, gh, and mobile-safe Chrome; release remains 1.4.0. | Replace only the stale Python/tool provider path while preserving the rest. |
| 2026-09-01 | Code/History | `git show origin/main:Dockerfile`; commits `6aa8421`, `410b1f4`, `fb0f593` | Understand the tested main-branch Python 3.13 direction. | Main on Ubuntu 22.04 adds Deadsnakes, installs Python 3.13, globally pip-installs Supervisor 4.3.0/websockify/uv, and launches `/usr/local/bin/supervisord`; 1.3.8 was published. | Reuse the compatible version and launch boundary, not the unsafe Noble-global installation shape. |
| 2026-09-01 | Doc | `tickets/done/python313-gh-tooling/*`; `tickets/in-progress/python313-supervisor-compatibility/*` | Confirm prior runtime result and root cause. | Published 1.3.7 default/zh manifests covered AMD64/ARM64 and reported Python 3.13; Supervisor 4.2.1 failed on Python 3.13 through `pkgutil.ImpImporter`; pip Supervisor 4.3.0 plus `/usr/local/bin/supervisord` ran the real config without that failure and 1.3.8 was published. | Require Supervisor 4.3.0 and normal-entrypoint proof in the Noble matrix. |
| 2026-09-01 | Report | `implementation-handoff.md`, `implementation-revision-record.md` (`IR-004`), `delivery-revision-record.md` (`DR-003`) | Understand integration choices and protected prior validation. | IR-004 intentionally rejected Python 3.13 only because RER-006 then mandated 3.12; it incorporated gh/start-chrome and preserved all other Noble fixes. | Treat the new user decision as superseding intent, not an IR-004 defect. |
| 2026-09-01 | Report | `code-review-report.md`, `api-e2e-coverage-investigation.md`, `api-e2e-execution-coverage-report.md`, `api-e2e-test-review-report.md` | Recover pre-integration proof and the validated matrix shape. | CRR-004/CRR-005 and API-REV-004 passed the pre-integration 3.12 candidate; those results are stale for the new Python/tool boundary but define reusable scenario coverage. | Rerun the complete integrated matrix after implementation. |
| 2026-09-01 | Web | `https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa` and package/build listings | Verify stable Deadsnakes support for Noble Python 3.13 and target architectures. | PPA explicitly lists Ubuntu 24.04 Python 3.13 and successful AMD64/ARM64 builds; it warns that the PPA is unsupported/untrusted and recommends isolated third-party package installation. | Record mutable external dependency risk and validate package origin at build time. |
| 2026-09-01 | Web | Canonical Ubuntu Python setup/availability documentation | Check Noble system-Python ownership. | Noble's system/default interpreter is Python 3.12; Canonical advises not replacing the system Python and using isolated environments for pip packages. | Keep `/usr/bin/python3` distribution-owned; select the developer interpreter through `/usr/local`. |
| 2026-09-01 | Runtime | `docker run --rm --platform linux/arm64 ubuntu:24.04 ...` retained in `evidence/solution-sr001-python313-noble-probe.log` | Probe the proposed Noble Python/tool boundary. | Noble ARM64 resolved Deadsnakes `3.13.15-1+noble1`; `/usr/local/bin/python3`/`python` reported 3.13 while `/usr/bin/python3` stayed 3.12; Python 3.13 venv installed Supervisor 4.3.0, websockify 0.13.0, uv 0.12.8; stable commands/assets worked. | Use as feasibility evidence, not final image validation. |
| 2026-09-01 | Runtime | `docker run --rm --platform linux/amd64 ubuntu:24.04 ...` retained in `evidence/solution-sr001-python313-noble-amd64-availability.log` | Check current Noble AMD64 package availability. | `python3.13`, `python3.13-dev`, and `python3.13-venv` each resolved `3.13.15-1+noble1`. | Full AMD64 build/runtime remains API/E2E work. |
| 2026-09-01 | Review | `design-review-report.md` / `architecture-review-revision-record.md` (`ARCH-REV-001`, `ARCH-F-001`) | Review SR-001 for implementation readiness. | Structural design passed; the current server-adoption supplement still named Python 3.12, and the requirements dependency table incorrectly said DEC-003 awaited approval. | Align the active brief to Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0, add it to design change/removal inventories, correct DEC-003 wording, append SR-002, and re-review. |

## Relevant Existing Behavior And Supported Product Paths

| Behavior ID | Kind | Supported Trigger Or Governing Contract | Current Supported Product Path / Lifecycle | Current Outcome / Invariants | Evidence | Confidence / Unknown |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | Maintainer invokes `build-multi-arch.sh` with default, `--no-cache`, `--load`, `--push`, and optional `--variant zh`. | Script reads VERSION, selects local platform or AMD64/ARM64 publication mode, passes `IMAGE_VARIANT`, builds Dockerfile, and assigns immutable plus rolling tags. | Integrated candidate is Ubuntu 24.04/version 1.4.0 and preserves tags/platforms; its Python payload is stale at 3.12. | Current sources; IR-004; prior API-REV-004. | High source confidence; final 3.13 matrix untested. |
| BEH-002 | System | Supported run/Compose surface starts the image. | Entrypoint prepares configured identity, XDG/DBus, VNC/profile/lock state, then Supervisor owns DBus, TigerVNC, XFCE, optional fcitx5, CopyQ, Chrome, socat, and websockify. | Integrated candidate preserves runtime behavior but runs distribution Supervisor with Python 3.12; main separately proved Python 3.13 plus Supervisor 4.3.0 on Jammy. | Current sources; main release/fix artifacts; prior runtime evidence. | High path confidence; combined Noble+3.13 boundary needs full execution. |
| BEH-003 | Contract | User reads README or inspects image identity. | README states Ubuntu/Python/tool features; VERSION/build script determine image identity. | Current integrated README says Ubuntu 24.04/Python 3.12 and is stale for the approved final target. | README, VERSION, Dockerfile. | High. |

## Relevant Codebase And Technical Facts

| Path / Component | Current Responsibility Or Behavior | Revised Requirement Implication | Architecture Decision |
| --- | --- | --- | --- |
| `Dockerfile` | Single owner for base, apt sources/packages, user identity, variants, runtime/tool installation, stable paths, and copied scripts. | Retain `ubuntu:24.04`, configured identity, variants, gh/Node/Yarn/browser stack, and version 1.4.0; replace Python/tool ownership coherently. | Re-add stable `ppa:deadsnakes/ppa`; install `python3.13`, `python3.13-dev`, `python3.13-venv`; do not install distribution `supervisor`; keep Noble `python3` for OS internals; expose Python 3.13 and isolated tools through `/usr/local`. |
| `/opt/browser-tools` | Current candidate venv owns websockify/uv under Python 3.12. | Preserve isolation while changing interpreter and adding compatible Supervisor. | Build it explicitly with `/usr/bin/python3.13`; install `supervisor==4.3.0`, websockify, uv; symlink public commands and stable assets. |
| `entrypoint.sh` | Governs runtime preparation then execs `/usr/bin/supervisord`. | Normal startup must use the compatible provider. | Change final exec to `/usr/local/bin/supervisord`; no fallback to `/usr/bin`. |
| `base.conf` | Governs service graph; uses stable `/usr/local/share/websockify`; invokes Chrome wrapper. | Preserve service names/order/paths and configured XDG behavior. | No service-graph redesign; keep stable websockify asset path. |
| `build-multi-arch.sh` | Owns AMD64/ARM64, Apple/Linux ARM aliases, variant, load/push, and tags. | All behavior remains authoritative. | No source change expected; validate unchanged. |
| `tests/validate-source-contract.sh` | Encodes old 3.12/no-Deadsnakes/distribution-Supervisor assumptions. | Current durable coverage becomes stale under RER-007. | API/E2E must revise after implementation, then route durable-test changes through Code Review. |
| `tests/validate-image.sh` | Validates image identity, Python 3.12 origin, isolated websockify/uv, variants, utilities, identity. | Retain shape but update target and assert public/distro interpreter separation plus Supervisor ownership/version. | API/E2E-owned durable edit after implementation. |
| `tests/validate-running-container.sh` | Validates Supervisor processes, VNC/websockify/DevTools, profile write, and semantic browser render. | Reuse and expand to assert compatible Supervisor/public paths and no Python 3.13 compatibility crash. | API/E2E-owned durable edit/execution. |

## Structural And Payload Surface Inventory

### Payload Or Content Surfaces

- README Ubuntu/Python/Supervisor feature statement.
- VERSION remains `1.4.0`.
- Requirements, README target, and the active deferred server-adoption brief must record the same Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 identity.

### Structural Surfaces

- Dockerfile dependency and tool-provider boundary.
- Entrypoint's authoritative Supervisor executable.
- Supervisor service graph and stable websockify asset path.
- BuildX script and release/tag contract.
- Durable source/image/runtime coverage harnesses.
- No API, persistence schema, deployment topology, or server repository source change is authorized.

### Architecture-Design Trigger Assessment

- API/external contract: public developer interpreter changes from the stale 3.12 candidate to user-approved 3.13; all other launch/port/tag/publication contracts are preserved.
- Lifecycle: service graph stays unchanged, but its provider/entry executable must change to Supervisor 4.3.0.
- Ownership: distribution Python, public developer Python, and Python-installed operational tools need explicit non-overlapping owners.
- Legacy pressure: stale 3.12 package/coverage paths, distribution Supervisor, global pip/update-alternatives, and Python-version-specific web assets must not survive as parallel paths.
- Classification: `Design Impact`; architecture review is required before implementation.

## Runtime, Probe, Or Reproduction Findings

| Method / Command | Scenario | Observation | Implication | Evidence Path |
| --- | --- | --- | --- | --- |
| ARM64 Noble ephemeral container with stable Deadsnakes PPA, Python 3.13 venv, Supervisor/websockify/uv | Feasibility of target tool boundary | Passed. Public Python 3.13 and isolated tools coexisted with Noble `/usr/bin/python3` 3.12. | Target boundary is feasible on native ARM64. | `requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-probe.log` |
| AMD64 Noble ephemeral container under Docker Desktop emulation; apt candidate checks | Target-architecture source availability | Passed for Python 3.13 package family. | Source can serve both required architectures; not a substitute for full build/runtime. | `requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-amd64-availability.log` |
| Prior main 1.3.8 executable validation and release manifests | Python 3.13 Supervisor compatibility | Supervisor 4.3.0 and `/usr/local/bin/supervisord` removed the `pkgutil.ImpImporter` startup failure; default/zh manifests were published for AMD64/ARM64 on Jammy. | Version and entrypoint boundary should be retained; Noble combination still requires execution. | `tickets/in-progress/python313-supervisor-compatibility/*`; `tickets/done/python313-gh-tooling/*` |
| Prior ticket API-REV-004 | Preservation matrix | Pre-integration Noble/Python 3.12 default/zh and runtime matrix passed at 96% confidence. | Scenario intent is reusable; result is stale after REQ-007 change. | `api-e2e-coverage-investigation.md`; `api-e2e-execution-coverage-report.md` |

## Persisted Data And State Facts

- Affected stored/external subject: Chromium profile state mounted at `/home/vncuser/.config/chromium`.
- Data-model or schema change: none.
- Current readers/writers: Chromium, entrypoint lock-recovery logic, Docker volume lifecycle.
- Required invariant: recreating a container with the same volume preserves profile state and stale-lock recovery.
- Decision: `Not Affected`; no migration is required. Runtime preservation must still be revalidated because interpreter/tool changes affect startup sequencing.

## Product Design Context

- UI/UX or prototype work: `N/A`. This is an operational container/runtime change; semantic Chromium rendering is executable validation, not a product-design request.

## Supplemental Artifact Inventory

| Artifact Path | Owner | Purpose | Scope | Related Requirement / AC IDs | Status | Approval Applicability |
| --- | --- | --- | --- | --- | --- | --- |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/requirements-revision-record.md` | Solution Designer / original Requirements Engineer | Durable requirement history through RER-007. | All | All | Current | User-approved behavior basis. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/server-base-image-adoption-follow-up.md` | Solution Designer / original Requirements Engineer | Preserve the separate server-ticket trigger and intake context aligned to the published Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 artifact. | Follow-up only | REQ-007–REQ-009; AC-011–AC-013 | Current — corrected in SR-002 | Sequencing approved; still deferred, separate, and non-authorizing. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-probe.log` | Solution Designer | ARM64 Noble feasibility evidence for public Python 3.13 plus isolated Supervisor/websockify/uv. | Design evidence | REQ-007; AC-006, AC-010, AC-013 | Current | N/A — evidence only. |
| `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base/requirements/ubuntu-24-minimal-base/evidence/solution-sr001-python313-noble-amd64-availability.log` | Solution Designer | AMD64 Noble package-availability evidence. | Design evidence | REQ-003, REQ-007; AC-004, AC-010 | Current | N/A — evidence only. |

## Assumptions, Unknowns, And Risks

| ID | Type | Description | Why It Matters | Resolution / Owner | Status |
| --- | --- | --- | --- | --- | --- |
| ASM-001 | Assumption | Explicit `ubuntu:24.04` remains the approved stable minimal base. | Prevents a floating/newer distribution substitution. | User-approved RER-006/RER-007. | Validated. |
| ASM-002 | Assumption | Python 3.13 means the public developer commands, not replacement of Noble's distribution interpreter. | Avoids breaking OS-owned Python scripts while satisfying observable behavior. | Design decision backed by Canonical guidance and probe. | Validated for design; implementation proof pending. |
| RISK-001 | Risk | Deadsnakes, PyPI, XtraDeb, NodeSource, and npm inputs are mutable. | Clean platform builds may change independently of repository source. | API/E2E distinguishes dependency outage from product defect and records resolved versions. | Open. |
| RISK-002 | Risk | Main's global pip/update-alternatives approach worked on Jammy but can couple Noble OS scripts and operational tools to Python 3.13. | A literal merge of both parents would create mixed ownership and possible runtime breakage. | Reject global system mutation; use `/usr/local` plus isolated venv. | Addressed by design. |
| RISK-003 | Risk | `websockify`/`uv` remain unpinned and their package paths include interpreter version internally. | An exposed internal path would break on Python updates. | Resolve assets at build time and expose stable `/usr/local/share/websockify`; validate link target. | Addressed by design; execution pending. |
| RISK-004 | Risk | Supervisor 4.3.0 is pinned for known Python 3.13 compatibility while Ubuntu also offers a distribution Supervisor. | Installing both permits accidental path drift or mismatched CLI/daemon versions. | Remove distribution Supervisor from apt list; expose both daemon and ctl from one venv. | Addressed by design; execution pending. |
| UNK-001 | Unknown | Full final matrix result for Noble + Python 3.13. | Required for release readiness. | API/E2E after implementation and code review. | Open. |
| RISK-005 | Risk | Server consumers use moving `latest`/`zh`. | Publication timing affects downstream reproducibility. | Keep server changes out of scope; separate ticket consumes verified immutable identity. | Deferred. |

## Requirement Implications

The user-approved final image is the union of the already validated directions, not either parent verbatim: retain the ticket's official `ubuntu:24.04`, configured-identity and stable-path fixes, version `1.4.0`, full variants/platforms, and runtime contracts; supersede its Python 3.12 selection with Python 3.13; retain main's proven Supervisor 4.3.0 compatibility boundary and current gh/Chrome-wrapper behavior; and improve interpreter/tool ownership so Noble's distribution Python is not replaced and Python-installed operational tools are not globally mixed with OS packages. Every current handoff artifact on SCN-005, including the deferred server-adoption brief, must identify that same public Python 3.13/Supervisor 4.3.0 release rather than the historical 3.12 candidate.

## Notes For Downstream Design, Implementation, And Validation

- Use stable `ppa:deadsnakes/ppa` for `python3.13`, `python3.13-dev`, and `python3.13-venv` on Noble.
- Keep `/usr/bin/python3` distribution-owned; expose `python3` and `python` as 3.13 from `/usr/local`.
- Build `/opt/browser-tools` with `/usr/bin/python3.13`; install `supervisor==4.3.0`, websockify, and `uv` there.
- Expose `supervisord`, `supervisorctl`, `websockify`, and `uv` through stable `/usr/local/bin` paths and websockify assets through `/usr/local/share/websockify`.
- Remove apt `supervisor`, `/usr/bin/supervisord` runtime use, Python 3.12 developer-target assertions, global pip/update-alternatives, and version-specific public websockify paths.
- Preserve Ubuntu 24.04, `1.4.0`, default/zh, AMD64/ARM64, Apple/Linux ARM aliasing, configured UID/GID, dynamic XDG/DBus, gh, Node/Yarn, Chrome mobile-safe mode, VNC/DevTools/websockify, locale/input, profile/recovery, tags/load/push, and publication sequencing.
- Required final matrix: default and zh × AMD64 and ARM64 source/image checks; normal-entrypoint runtime at least per platform and variant as feasible; default plus non-1000 configured identity; public/distro interpreter ownership; Supervisor 4.3.0 config/start/status and absence of prior traceback; stable websockify/uv paths; VNC/HTTP/WebSocket/DevTools/semantic render; zh locale/input; mobile-safe Chrome args; profile persistence/stale-lock recovery; local load/tag semantics; no-push multi-platform readiness; and published manifest/runtime identity only after the pre-publication gate passes.
- Durable test updates belong to API/E2E after implementation and must return through Code Review before Delivery.
- The active server-adoption brief is corrected to consume the verified Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 release, but remains deferred/separate/non-authorizing. Architecture re-review, implementation, source review, API/E2E, Delivery, publication, finalization, and server adoption remain blocked in that order.
