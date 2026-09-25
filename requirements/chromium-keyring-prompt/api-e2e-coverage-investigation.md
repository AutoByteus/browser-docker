# API/E2E Coverage Investigation

## Investigation Meta

- Requirements Doc: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/requirements-doc.md` (Approved, SR-004)
- Investigation Notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/investigation-notes.md`
- Solution Revision Record: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/solution-revision-record.md`
- Design Spec (required on every route): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/design-spec.md` (Ready, SR-005)
- Supplemental Task Artifacts: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/evidence/` (`user-report-keyring-prompt.png`, `probe-a/b/c-*.png`, `probe-chromium-d-dropin.txt`, `implementation-ir001-*.log`); `handoff-architecture-design-complete.md`
- Design Review Report: `N/A — not applicable` (Small/Low direct route)
- Architecture Review Revision Record: `N/A — not applicable` (Small/Low direct route)
- Implementation Handoff: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/implementation-handoff.md`
- Implementation Revision Record: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/implementation-revision-record.md` (IR-001)
- Code Review Report: `N/A — not applicable` (direct low-risk route; no source review selected)
- Code Review Revision Record: `N/A — not applicable`
- Delivery Revision Record (delivery re-entry only): N/A
- Relevant Delivery Revision IDs: N/A
- API/E2E Revision Record (created after the first completed result): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/api-e2e-revision-record.md`
- Current API/E2E Revision ID: `API-REV-001`
- API/E2E Test-Case Ledger: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/api-e2e-test-case-ledger.md`
- Current Investigation Round: `1`
- Trigger: `implementation_engineer` "Implementation Complete" for IR-001 (source commit `6d4aa757b16279449e5c7e2b3ca198789b0f9deb`, artifacts commit `a428738`), direct API/E2E route.
- Prior Investigation Reviewed: None (first API/E2E round for this package).
- Latest Authoritative Investigation: this document.

## Routing Classification

- Task size: `Small`
- Architectural risk: `Low`
- Input route: `Direct Low-Risk`
- Successful-output route: `Delivery`
- Proportional test-code review decision: `Not Required — direct low-risk route`

## Current Requirement And Design Basis

Behavior that must be proven (SR-004 requirements, SR-005 design, IR-001 implementation):

- No keyring dialog, keyring daemon or Secret Service activation at any Chromium start. The Chromium main process carries `--password-store=basic` (AC-001, REQ-001/006).
- `http://` navigation over DevTools completes within 30 s, with no human interaction (AC-002, REQ-002).
- Every launch path goes through `/usr/bin/chromium` and the single drop-in `/etc/chromium.d/autobyteus-password-store`. The paths are supervisor autostart, the `xdg-open`/server bridge and the desktop launcher (AC-003, REQ-001).
- Existing contracts are preserved (AC-004, REQ-003): Supervisor, DevTools 9222/9223, VNC, websockify, profile write and stale-lock recovery, the mobile-safe profile, fcitx in zh, the default/zh variants, amd64/arm64 and custom UID.
- The existing profile volume is used directly with no migration. Keyring-encrypted values are discarded, so one re-login is needed (AC-005, REQ-004, DEC-003).
- A Secret Service request from `vncuser` fails in ≤ 2 s with ServiceUnknown (AC-007, REQ-006).
- `gnome-keyring` and `libpam-gnome-keyring` are absent, no `org.freedesktop.secrets` D-Bus service file remains, and `chromium` and XFCE are still present (AC-008, REQ-006).
- Design escalation triggers: (a) the purge removes more than `gnome-keyring`, `libpam-gnome-keyring` and `evolution-data-server`; (b) a preserved check fails; (c) the Secret Service or portal Secret is still activated while the flag is present; (d) the wrapper no longer sources `/etc/chromium.d`.
- Out of scope for API/E2E: AC-006 (publishing 1.4.1, re-publishing server images, upgrading nodes) is delivery-owned, DS-003.

## Changed Behavior Summary

| Behavior ID / Boundary | Change Type | Upstream Evidence | Coverage Consequence |
| --- | --- | --- | --- |
| BEH-001 Chromium start without keyring dialog | Changed | REQ-001/003/004, AC-001/003/004; design DS-001 | Runtime process, D-Bus log and X11 window checks per variant/arch |
| BEH-002 Navigation completes unattended | Changed | REQ-002, AC-002 | Real DevTools navigation (local `http://` durable; external https as a temporary probe) |
| BEH-003 Upgrade on an existing profile volume | Changed | REQ-004, AC-005; DATA-001 | Temporary lifecycle probes: 1.3.8 → 1.4.0 → fixed, and a typed keyring on 1.4.0 → fixed |
| BEH-004 No keyring provider shipped | Changed (Removed packages) | REQ-006, AC-008; DS-002 | Build-log removal set and image package/service-file checks |
| BEH-005 Keyring requests fail fast | Changed | REQ-006, AC-007 | `dbus-send` durable check plus real libsecret clients (vncuser and root) as a temporary probe |
| Supervisor/DevTools/VNC/websockify/profile/stale-lock/mobile-safe/fcitx/UID | Preserved | REQ-003, AC-004 | Existing validate-*.sh suites; restart and mobile-safe probes |
| Release version / build wrapper tags | Changed (`VERSION` 1.4.1) | REQ-005 (delivery), design step 1 | Source contract plus build-wrapper fake-BuildX test |

## Changed Surface And Boundary Classification

| Surface / Boundary | Affected? | Actual Changed Boundary | Repository Evidence Available | Material Risk Not Exercised By That Evidence | Candidate Broader Validation Mode |
| --- | --- | --- | --- | --- | --- |
| Domain / backend logic | No | — | — | — | — |
| API / transport / contract | Yes (runtime contract) | Chromium DevTools CDP navigation; session D-Bus Secret Service name | `validate-running-container.sh` drives real CDP and real D-Bus in a real container | External https site (TLS, network service) is not exercised; the local page is used | Temporary external-site CDP probe |
| Frontend component / state | No | — | — | — | — |
| Browser integration / user journey | Yes | The Chromium binary's password-store policy on every launch path | Supervisor path at runtime; image-level `sh -x` wrapper trace; desktop/xdg static routing checks | Cold launches through the real `xdg-open`, server bridge and desktop helper are not durable | Lifecycle/CLI launch-path probe in a running container |
| Authentication / session / permissions | Yes (secrets storage) | OS keyring removed; Chromium built-in key | Package, service-file and D-Bus fail-fast checks | Real libsecret client as `vncuser`/root; cookie encryption format | Temporary client and cookie probes |
| Desktop renderer / web-equivalent UI | No | No product UI. The only "UI" change is the absence of an OS dialog | — | Visual confirmation on the VNC framebuffer | X11 window enumeration plus a root-window screenshot (operator view) |
| Desktop shell / Electron-specific integration | No | — | — | — | — |
| Process / lifecycle | Yes | Container start, Chromium restart, container restart, stale-lock recovery | Fresh start only, in the durable scripts | Restart paths | Lifecycle probe |
| Persisted-data transition | Yes | Profile volume: Directly Usable, keyring-encrypted values discarded | None durable | Real older-profile reuse | Temporary upgrade probes |
| Worker / queue / distributed coordination | No | — | — | — | — |
| External integration | Yes (build-time) | Ubuntu 24.04 plus the xtradeb apt graph (purge removal set); downstream server image `FROM` | Build logs | Fresh package graph today; downstream installs re-adding the provider | Clean `--no-cache` rebuilds; static read of the server Dockerfile |

## Project Execution Discovery

- Assigned task worktree / workspace: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt` (branch `codex/chromium-keyring-prompt`, HEAD `a428738`; tracked source identical to `6d4aa75` outside `requirements/`, and the tree is clean).
- Project type and runtime stack: Docker image (Ubuntu 24.04, XFCE/TigerVNC, xtradeb Chromium, Supervisor 4.3.0 on Python 3.13). Validation is by Bash contract scripts in `tests/`.
- Conflicting, missing, or unclear project instructions: No `AGENTS.md`/`CLAUDE.md` in the repository. `README.md` documents `build-multi-arch.sh` and `run-container.sh`, and both write the shared tags `autobyteus/chrome-vnc:latest`/`zh`. To leave the user's local tags untouched, builds use the same BuildX command with task-local tags. The build wrapper's command composition is proven separately by `validate-build-wrapper.sh`.
- Required environment variables or secrets available: `N/A` (no secrets needed; public apt, PPA and Docker Hub access only).
- Host: Apple M1 Max (arm64), Docker Desktop 29.0.1, BuildX builder `multi-platform-builder` (docker-container, BuildKit v0.26.2). **No native amd64 host is available.** There is no remote Docker context, and pushing to CI is prohibited (local-only package), so amd64 runs under Docker Desktop emulation.

| Instruction / Configuration Path | Authority / Purpose | Commands, Setup, Or Constraints Learned |
| --- | --- | --- |
| `README.md` (Building, Running, Recovery sections) | Build/run authority | `build-multi-arch.sh [--variant zh] [--no-cache]` → `docker buildx build --load --platform <host> --tag … --build-arg IMAGE_VARIANT=…`. Run with `--cap-add SYS_ADMIN --security-opt seccomp=unconfined -v <profile-volume>:/home/vncuser/.config/chromium`. Profile volume and stale-lock recovery semantics |
| `run-container.sh`, `docker-compose*.yml` | Canonical run flags | Same flags. Ports 5900/9223 (6080 internal). `--restart unless-stopped` |
| `tests/validate-source-contract.sh`, `tests/validate-build-wrapper.sh` | Repository-only contracts | Run from any cwd (they `cd` to the repo root). No Docker needed |
| `tests/validate-image.sh IMAGE [default\|zh] [UID] [GID]` | Image contract | Runs `docker run --rm --entrypoint /bin/bash` |
| `tests/validate-running-container.sh CONTAINER [default\|zh] [UID]` | Runtime contract | Needs a container running the normal entrypoint; waits ≤ 120 s for Supervisor programs |
| `base.conf`, `start-chrome.sh`, `entrypoint.sh` | Launch paths | Supervisor `chrome` → `start-chrome.sh` → `/usr/bin/chromium`; `AUTOBYTEUS_NODE_PROFILE=mobile-safe` adds `--no-sandbox`; entrypoint clears stale profile locks |
| Superrepo `autobyteus-server-ts/docker/{Dockerfile.monorepo,open-vnc-browser-url.sh,xdg-open-root-bridge.sh,exo-open-root-bridge.sh}` (read-only) | Downstream consumer and server bridge | Runtime stage `FROM autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` and only `apt-get install -y --no-install-recommends git ripgrep`. The bridge runs `runuser -u vncuser -- env DISPLAY=:99 … /usr/bin/xdg-open URL` |

| Component / Dependency | Working Directory | Start / Setup Command | Runtime / Resource Notes | Readiness Check | Stop / Cleanup Method |
| --- | --- | --- | --- | --- | --- |
| Source export | `/tmp/api-e2e-keyring-src-6d4aa75` | `git archive 6d4aa75 \| tar -x` | Exact source commit | `VERSION`=1.4.1 | `rm -rf` |
| Images | host Docker | `docker buildx build --builder multi-platform-builder --load --no-cache --progress=plain --platform linux/{arm64,amd64} --tag autobyteus/chrome-vnc:api-e2e-keyring-<target> --build-arg IMAGE_VARIANT=<v> [--build-arg USER_UID=1234 --build-arg USER_GID=1234]` | ~5 GB each; amd64 emulated | `exit=0` + `docker image inspect` | `docker image rm` of `api-e2e-keyring-*` tags |
| Containers | host Docker | `docker run -d --name api-e2e-keyring-<target> --platform … --cap-add SYS_ADMIN --security-opt seccomp=unconfined -v api-e2e-keyring-<target>-profile:/home/vncuser/.config/chromium <image>` (no host ports published, to avoid collisions with the user's `autobyteus-server-*` ports) | Supervisor entrypoint | Supervisor programs RUNNING (script waits 120 s) | `docker rm -f` + `docker volume rm` |

| Data / Fixture / Identity Need | Existing Project Mechanism Or Creation Method | Environment / Data-Safety Notes | Cleanup / Retention |
| --- | --- | --- | --- |
| Empty profile volume per container | Named volume `api-e2e-keyring-<target>-profile` | Task-owned names only; user volumes untouched | Removed after the run |
| Older profile (1.3.8 v10 cookie; 1.4.0 pending dialog; 1.4.0 typed keyring + v11 cookie) | Local images `autobyteus/chrome-vnc:1.3.8-arm64`, `autobyteus/chrome-vnc:1.4.0` (arm64). Cookies are set via CDP `document.cookie` on `http://127.0.0.1:6080/`. The keyring password is typed into the real gcr dialog with `xdotool` | Throwaway containers/volumes only | Removed after the run |
| Identity | Image `vncuser` (UID 1000, or 1234 for the custom build); root for bridge/root-client probes | — | — |

## Persisted Data Transition Coverage Basis

- Approved decision: `Directly Usable — No Migration` for the Chromium profile volume. Keyring-encrypted (`v11`) values are `Discard or Rebuild` (one re-login, DEC-003).
- Design-spec and implementation-handoff references: design "Persisted Data / State Transition Decision"; handoff "Persisted Data Transition Check".
- Representative existing-data setup and required behavior:
  1. A profile created by 1.3.8 (built-in `v10` cookie), then run on 1.4.0 (dialog pending), then run on the fixed image. The 1.3.8 cookie must still be readable, with no dialog.
  2. A profile where a keyring password was typed on 1.4.0 and Chromium wrote a keyring-encrypted cookie, then the fixed image. Expected: no dialog and a normal start and navigation. The keyring-encrypted cookie is not usable (approved loss). New cookies persist across a restart.
- Evidence planned: temporary lifecycle probe (C11) with cookie inspection through CDP and the Cookies SQLite prefix.
- Migration-specific scenarios: N/A (no migration).
- Upstream ambiguity or reroute required: None.

## Existing Durable Coverage Inventory

| Path / Scenario | Current Assertion Or Intent | Related Requirement / AC / Design | Validity Decision | Evidence | Action |
| --- | --- | --- | --- | --- | --- |
| `tests/validate-source-contract.sh` (pre-existing assertions) | Ubuntu 24.04 base, runtime paths, ports, release script, README | REQ-003 | Still Valid | Passes on 6d4aa75 | Run |
| `tests/validate-source-contract.sh` `VERSION must be 1.4.1` (updated from 1.4.0) | Release version pin | REQ-005 / design step 1 | Still Valid (correctly updated, not duplicated) | Diff 4d03f29..6d4aa75 | Run |
| `tests/validate-source-contract.sh` no-keyring block (new) | Purge placement, COPY/dos2unix/chmod, exact drop-in, single `--password-store` owner, `start-chrome.sh` execs the wrapper, README posture | REQ-001/006, AC-003/008, design Dependency Rules | Still Valid (new, matches design) | Diff; my independent mutations S1–S15 | Run plus mutation check |
| `tests/validate-build-wrapper.sh` (tags now derived from `VERSION`) | Wrapper pushes the version and rolling tags; failure propagation | REQ-005 | Still Valid. The update was a necessary test-data correction: the old literal `1.4.0` was coupled to `VERSION`. The release version is still pinned once, in the source contract | Diff; W1/W2 mutations | Run |
| `tests/validate-image.sh` (pre-existing) | OS/Python/Supervisor/tools/locale/variant/UID | REQ-003, AC-004 | Still Valid | — | Run ×5 |
| `tests/validate-image.sh` no-keyring block (new) | Packages absent; `chromium`/`xfce4-session` present; service files absent; drop-in root 644 yields the flag; single owner in `/etc/chromium.d`; wrapper exec trace carries the flag; desktop/xdg/x-www-browser route to `/usr/bin/chromium` | AC-003, AC-008 | Still Valid (new) | Diff; implementation negative control | Run ×5; independent negative control |
| `tests/validate-running-container.sh` (pre-existing) | Supervisor, PID1, UID/XDG/D-Bus, VNC, websockify, DevTools, data: URL render, profile write, fcitx | REQ-003, AC-004 | Still Valid. The Chromium main-process parser was changed to cope with title rewriting; checked for equivalence below | Diff | Run ×5 |
| `tests/validate-running-container.sh` flag / http navigation / keyring block (new) | Main process has the flag; `http://127.0.0.1:6080/` title within 30 s; no `gcr-prompter`/`gnome-keyring-daemon`; no `org.freedesktop.secrets` activation; `vncuser` ping → ServiceUnknown ≤ 2 s | AC-001, AC-002, AC-003, AC-007 | Still Valid (new). Note: the activation-log check covers only `org.freedesktop.secrets`, not portal/prompter activations. That gap is covered by a temporary probe (C09) and recorded as a residual durable-coverage observation | Diff | Run ×5; independent negative control |

## Stale Or Obsolete Coverage Decisions

| Path / Scenario | Obsolete Assertion | Why It Is Obsolete | Upstream Evidence | Replacement Coverage | No-Replacement Rationale |
| --- | --- | --- | --- | --- | --- |
| `validate-source-contract.sh` `VERSION must be 1.4.0` | Version 1.4.0 | Approved bump to 1.4.1 | REQ-005, design step 1 | Same assertion now pins 1.4.1 | — |
| `validate-build-wrapper.sh` literal `autobyteus/chrome-vnc:1.4.0[-zh]` | Tag literal | Duplicated the version pin | Design "update the obsolete version contract rather than adding a second" | Tags derived from `VERSION` | — |

No durable scenario was removed.

## Durable Coverage To Add

None planned by API/E2E. The implementation already added the requirement-linked durable assertions to the three existing contract scripts. Their validity is checked by independent mutation and negative-control execution. The remaining scenarios (external site, cold launch paths, real keyring clients, upgrade chains, restarts) depend on the internet, old images or GUI automation of a real dialog. They stay temporary probes (see the Temporary plan for why).

## Durable Coverage To Update

None planned. Revisit if execution shows a durable assertion is invalid or non-discriminating.

## Durable Coverage To Remove

None.

## Repository Coverage Execution Plan And Results

| Order | Command | Working Directory / Configuration | Boundary Or Scenario Proven | Result | Evidence / Output Path |
| --- | --- | --- | --- | --- | --- |
| 1 | `bash -n`, `shellcheck -S warning tests/*.sh`, `sh -n` drop-in, `node --check` embedded probe, `git diff --check 4d03f29 6d4aa75` | worktree | Script and drop-in syntax | Pass | `evidence/api-e2e-rev001-repository-checks.log` |
| 2 | `tests/validate-source-contract.sh` | worktree | Source contract (AC-003/008 static, REQ-003) | Pass | same |
| 3 | `tests/validate-build-wrapper.sh` | worktree | Wrapper tagging from `VERSION` | Pass | same |
| 4 | 15 source and 2 wrapper mutations in temp copies of `6d4aa75` | `/tmp/api-e2e-keyring/mut.*` | Durable contracts discriminate | Pass (15/15 source mutations and W1 caught; W2 passes as designed) | `evidence/api-e2e-rev001-source-contract-mutations.log` |
| 5 | Clean `--no-cache` builds ×5 (arm64 default/zh/custom-1234; amd64 default/zh via Rosetta) | `/tmp/api-e2e-keyring-src-6d4aa75` | Build succeeds; removal set exactly 3 packages (escalation trigger a) | Pass (all exit 0; `REMOVED: evolution-data-server* gnome-keyring* libpam-gnome-keyring*` on all 5, fresh apt graph) | `evidence/api-e2e-rev001-build-<target>.log` |
| 6 | `tests/validate-image.sh` ×5 | worktree | AC-008, AC-003 image, AC-004 | Pass ×5 | `evidence/api-e2e-rev001-image-<target>.log` |
| 7 | `tests/validate-running-container.sh` ×5 | worktree | AC-001, AC-002, AC-003 supervisor, AC-004, AC-007 | Pass ×5 (nav 47–1484 ms; ping 7–397 ms) | `evidence/api-e2e-rev001-runtime-<target>.log` |
| 8 | Negative control on `autobyteus/chrome-vnc:1.4.0`: full scripts, then each new assertion alone | worktree | New assertions discriminate | Pass (every new assertion FAILs on 1.4.0) | `evidence/api-e2e-rev001-negative-control-1.4.0.log` |

## Test-Case Ledger Plan

- Ledger required: `Yes`. There are 13 independently meaningful cases, long-running builds (amd64 clean builds under emulation) and multi-container lifecycle probes, so interruption and context-compression risk is credible.
- Canonical ledger path: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/api-e2e-test-case-ledger.md`
- Ledger initialized before execution: `Partly`. It was created at ~05:07Z, after the two short repository-only cases C01/C02 had finished (recorded from their timestamped logs) and while C03 builds were running. It existed before any container-based case (C04–C13).
- Case granularity: one scenario or lifecycle check per case

| Case ID | Case / Journey | Requirement / AC IDs | Boundary / Execution Surface | Planned Command Or Entry Point | Planned Order | Evidence Expected |
| --- | --- | --- | --- | --- | --- | --- |
| C01 | Repository lint, source contract, build wrapper | AC-003/004/008 (static), REQ-005 | Repository | Order 1–3 above | 1 | `api-e2e-rev001-repository-checks.log` |
| C02 | Independent mutation checks of durable source contracts | Durable coverage quality | Repository | Order 4 | 2 | `api-e2e-rev001-source-contract-mutations.log` |
| C03 | Clean builds ×5 plus removal-set check | AC-008, escalation trigger a, RSK-005 | Build (BuildKit, fresh apt graph) | Order 5 | 3 | build logs |
| C04 | `validate-image.sh` ×5 | AC-003, AC-004, AC-008 | Image | Order 6 | 4 | `api-e2e-rev001-image-<target>.log` |
| C05 | `validate-running-container.sh` ×5 | AC-001, AC-002, AC-003, AC-004, AC-007 | Running container, real CDP and D-Bus | Order 7 | 5 | runtime logs |
| C06 | Negative control on 1.4.0 | Discrimination of the new assertions | Image + running container | Order 8 | 6 | negative-control log |
| C07 | Launch paths: warm and cold server bridge (`open-vnc-browser-url.sh` as root), cold `exo-open --launch WebBrowser`, cold `gtk-launch chromium` | AC-003, AC-002, REQ-001 | Running container, real launchers | Temporary probe script | 7 | `api-e2e-rev001-launch-paths-<target>.log` |
| C08 | External https sites over CDP (Wikipedia, example.com) within 30 s | AC-002 realism | Running container + internet | Temporary Node CDP probe | 8 | `api-e2e-rev001-external-navigation.log` |
| C09 | Operator view and D-Bus activation audit: no keyring/prompter window (X11 enumeration), root screenshot, every `Activating service` line free of secrets/portal-Secret/keyring/prompter | AC-001 ("no dialog"), REQ-001 (portal) | X11 display :99, D-Bus log | Temporary probe + `scrot` | 9 | screenshots + `api-e2e-rev001-operator-view.log` |
| C10 | Real keyring clients fail fast: libsecret store/lookup as `vncuser` and as root (inherited bus) | AC-007, REQ-006, SCN-004 | Session D-Bus, libsecret | Temporary Python gi probe | 10 | `api-e2e-rev001-keyring-clients.log` |
| C11 | Upgrade/persisted data: 1.3.8 v10 cookie → 1.4.0 pending → fixed; typed keyring + v11 cookie on 1.4.0 → fixed | AC-005, REQ-004, DEC-003 | Profile volume across images | Temporary lifecycle probe | 11 | `api-e2e-rev001-upgrade-*.log` + screenshots |
| C12 | Lifecycle and preserved profiles: `supervisorctl restart chrome`, `docker restart` (stale-lock recovery), mobile-safe profile | REQ-003, AC-001/004 | Process lifecycle | Runtime script rerun + probes | 12 | `api-e2e-rev001-lifecycle.log` |
| C13 | Downstream consumer readiness (static + simulated server runtime-stage install) | AC-006 readiness (delivery-owned), REQ-006 inheritance | Derived image layer | Read-only file read + throwaway container | 13 | `api-e2e-rev001-downstream.log` |

## Post-Repository Confidence Scorecard

Scored after C01–C06: repository checks, clean builds, the durable image and runtime contracts on all 5 targets, and the negative control.

| Confidence Category | Score | What Supports The Score | Remaining Uncertainty | Additional Validation That Could Improve It |
| --- | --- | --- | --- | --- |
| Requirement and acceptance-criteria proof | 85% | AC-001/002/007/008 proven on 5 targets by the durable scripts; AC-003 supervisor path at runtime plus static routing; AC-004 existing suites | AC-003 cold launch paths, AC-005 existing profiles and real keyring clients not exercised by repository checks | C07, C10, C11 |
| Changed-boundary execution directness | 90% | Real containers, real CDP, real D-Bus, real package graph | Launch paths other than Supervisor are only static | C07 |
| Cross-boundary integration realism and mock gap | 88% | No mocks; local http page | No real website; server bridge not exercised | C07 (bridge), C08 |
| Environment, configuration, identity, and fixture fidelity | 90% | default/zh × arm64/amd64, custom UID, clean builds from the exact commit | amd64 emulated only; fresh profiles only | C11; native amd64 unavailable |
| Failure, edge-case, lifecycle, and recovery evidence | 80% | Negative control discriminates every new assertion | No restart, stale-lock, mobile-safe or upgrade evidence | C11, C12 |
| User-surface, browser, and desktop-shell confidence | 80% | Process and D-Bus absence of the prompter | No visual or X11-level proof of "no dialog" | C09 |
| Durable regression coverage quality and relevance | 94% | 15/15 source mutations caught; every new image/runtime assertion fails on 1.4.0 | Activation audit limited to `org.freedesktop.secrets`; cold launches are static-only | — (optional improvement noted) |

- Overall post-repository confidence: 86.7% (simple average)
- Calculation method: simple average of the 7 applicable categories
- Every critical acceptance criterion directly proven: `No` (AC-003 non-supervisor paths, AC-005)
- Any applicable category below `90%`: `Yes`: requirement proof, integration realism, lifecycle, user surface
- Default clean-confidence target of `95%` met: `No`
- Material residual risks: cold launch paths, existing profile volumes, real clients, visible dialog absence, restarts

## Post-Broader-Validation Confidence Update

Broader validation (C07–C13) ran as planned. Final scores are in the execution coverage report: overall **95.1%**, no category below 90%, every in-scope critical AC directly proven.

## Broader Validation Decision

- Decision: `Required`
- Selected execution mode: `Lifecycle` + `CLI` (real launchers inside running containers), live `CDP` navigation (including external sites), the X11 operator view, and persisted-data lifecycle across images.
- Specific confidence gap or residual risk addressed: The durable scripts cover the supervisor path, a local page, a synthetic `dbus-send` client and fresh profiles only. Not covered: cold `xdg-open`/bridge/desktop launches (AC-003), real websites (AC-002 realism), the visible dialog absence (AC-001), real libsecret clients (AC-007/SCN-004), existing profile volumes (AC-005), restarts and mobile-safe (REQ-003).
- Why the selected mode can materially improve confidence: each probe exercises the real production path the durable scripts approximate.
- Expected confidence after the selected validation: ≥ 95%, limited only by amd64 being emulated.
- Browser-specific decision and rationale: the "browser" under test is Chromium inside the container. It is driven over its real DevTools WebSocket (not a host browser tab). A host browser cannot show the VNC desktop because websockify serves no noVNC client (`/usr/local/share/websockify` holds only Python modules). So the operator view is captured from the same X display with `scrot`, and windows are enumerated semantically with `xwininfo`/`xdotool`.
- If `Blocked`: native amd64 execution is unavailable (see Not Tested).

## Temporary Executable Validation Plan

| Scenario ID | Probe / Harness / Runtime Setup | Behavior Proven | Why This Should Not Remain As Durable Coverage |
| --- | --- | --- | --- |
| C07 | Superrepo `open-vnc-browser-url.sh` copied into the test container. Supervisor `chrome` stopped for cold launches; `exo-open`/`gtk-launch` run as `vncuser` | All launch paths carry the flag, and pages load | The bridge script belongs to another repository. Cold launches mutate Supervisor state. The durable image check already asserts the routing (`chromium.desktop`, xdg default, x-www-browser, wrapper trace) |
| C08 | Node CDP probe to public https sites | Real-site navigation | Internet dependency makes CI non-deterministic |
| C09 | `xwininfo -root -tree`, `xdotool search`, `scrot`; D-Bus log audit | No visible dialog; no portal/prompter activation | Screenshot evidence is not assertion-grade. The window-title audit could become durable, but the D-Bus secrets check already covers the trigger. Recorded as an optional durable improvement, not a blocker |
| C10 | `/usr/bin/python3` gi `Secret.password_store_sync` / `password_lookup_sync` | Real client fails fast | `dbus-send` already proves the D-Bus boundary durably |
| C11 | Old images 1.3.8/1.4.0 + `xdotool` typing into the real gcr dialog | Approved persisted-data outcome | Depends on historical images and GUI automation of the old defect |
| C12 | `supervisorctl restart chrome`, `docker restart`, `AUTOBYTEUS_NODE_PROFILE=mobile-safe` | Preserved lifecycle | Lifecycle orchestration outside the per-container script contract |
| C13 | Read-only superrepo read; throwaway container running the server's runtime-stage apt line | Downstream does not re-add the provider | Cross-repository; AC-006 verification of published images is delivery-owned |

## Not Tested / Infeasible / Deferred

| Behavior / Boundary | Reason | Risk | Required Follow-Up Or Escalation |
| --- | --- | --- | --- |
| Native amd64 execution | No amd64 host; pushing to CI is prohibited for this local-only package | Low: packages come from the real amd64 archive and binaries are real amd64. Only CPU emulation differs, and the timing limits (30 s / 2 s) have large margins | Delivery's AC-006 throwaway-container check of the published images; optionally an amd64 host |
| AC-006 publish / server re-publish / node upgrade | Delivery-owned (DS-003, DEC-005) | — | Delivery |
| Real `gh auth login` / git credential helper keyring fallback | Needs network credentials or accounts | Low: they call the same Secret Service D-Bus name that C05/C10 prove fails fast | None |

| GPG passphrase prompt through `pinentry-gnome3` → `gcr-prompter` (not a keyring) | Out of approved scope: requirements "Out Of Scope" limits removals to the three packages | Requires a passphrase-protected GPG key. Never observed; no `org.gnome.keyring.*` activation in any C09 audit | Informational. Solution Designer may open a follow-up ticket if wanted |

## Ambiguities Or Reroute Triggers

| Issue | Classification | Evidence | Recommended Recipient |
| --- | --- | --- | --- |
| None. No escalation trigger (a)–(d) fired: removal set is exactly the 3 packages on all 5 builds; every preserved check passes; no secrets/portal-Secret activation with the flag; the wrapper sources `/etc/chromium.d` (wrapper trace + cold launches) | — | C03–C07, C09 | — |

## Investigation Decision

- Proceed To API/E2E Execution: `Yes` (completed)
- Repository-Resident Durable Coverage Will Be Added / Updated / Removed: `No`. API/E2E made no durable change. The implementation's durable assertions were independently validated (mutations + negative control).
- Post-repository confidence: 86.7% → final 95.1% after broader validation
- Broader validation decision: `Required` (C07–C13), executed, all Pass
- Reroute Required Before Validation Execution: `No`
- Recommended Recipient If Reroute Required: N/A
- Notes: Resources created by this run use the prefix `api-e2e-keyring-*`. The user's `autobyteus-server-*` containers, their volumes and the local `latest`/`zh`/`1.4.0`/`1.3.8-*` tags are read or used as base images only, never modified. The implementation's `impl-keyring-*` images were used only to discover which probe tools exist in the image, not as evidence.
