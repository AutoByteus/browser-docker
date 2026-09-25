# Design Spec

## Solution And Approval Basis

- Current solution revision ID: `SR-005`
- Approved requirements baseline / revision and user-approval reference: `requirements-doc.md` at `SR-004`, approved by the user 2026-09-25 ("approve."); DEC-005 (release trigger) delegated to the Solution Designer by the user 2026-09-25.
- Behavior-defining supplements and their approval references: None
- Design status: `Ready`
- Canonical investigation-notes path: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/investigation-notes.md`

## Current-State Read

- The browser base image (`browser_docker`, `origin/main` `4d03f29`, `VERSION` 1.4.0, Ubuntu 24.04) installs its whole package set in one `apt-get install -y …` RUN (Dockerfile layer 2) with apt's default `Install-Recommends=1`. Desktop extras pulled in that way Recommend `gnome-keyring`; `evolution-data-server` hard-Depends on it (RUN-007/012). 1.3.8 (Ubuntu 22.04) had none of these (RUN-006).
- Chromium (xtradeb 151) is launched only through the `/usr/bin/chromium` wrapper, which sources every `/etc/chromium.d/*` drop-in into `CHROMIUM_FLAGS` (TECH-003). Launch paths: supervisor `chrome` → `start-chrome.sh` → `/usr/bin/chromium`; server bridge/`xdg-open`/desktop → `chromium.desktop` → `/usr/bin/chromium`.
- Chromium 151's `FreedesktopSecretKeyProvider` uses the Secret Service for unknown/XFCE desktops and creates a default collection interactively when none exists; `--password-store=basic` disables it and the portal provider (TECH-005/006). Result today: a pending gcr dialog on every node; navigation blocked (BEH-001/002).
- The AutoByteus server image consumes the base via `FROM autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` (`latest`/`zh`) with no Chromium or keyring configuration of its own (TECH-004, RUN-013).
- No structural problem exists in the image design; the defect is an unintended transitive package plus an unset Chromium option.

## Task Size And Architectural Risk (Mandatory)

- Task size: `Small`
- Size rationale and supporting evidence: One repository (`browser_docker`). Changes: `Dockerfile` (one purge step, one COPY, dos2unix/chmod list), one new 5-line Chromium drop-in, `VERSION`, `README.md`, and assertions added to the three existing validation scripts. No new runtime owner, script, service or supervisor program. Server repository: no source change (re-publish only, delivery-owned).
- Architectural risk: `Low`
- Risk rationale and supporting evidence: Restores the known-good 1.3.x state (no keyring provider; Chromium on its built-in key) using Chromium's documented switch and the distribution's documented drop-in mechanism. Every mechanism was probed on the real 1.4.0-based image: dialog removed, navigation restored, keyring clients fail in 0 s, package removal limited to `gnome-keyring`, `libpam-gnome-keyring`, `evolution-data-server` in both default and zh (RUN-004, RUN-007..010, zh check). No API, schema, concurrency or ownership-boundary change. The security/persistence effects (built-in cookie key; one-time re-login where a keyring was typed) are user-approved and equal to 1.3.x behavior. Release uses the existing publish scripts/workflows unchanged.
- Escalation trigger if implementation or validation discovers new impact: Return `Design Impact` if (a) the purge would remove any package beyond the three named ones on any variant/arch, (b) any preserved check in `tests/validate-*.sh` fails after the change, (c) Chromium still activates `org.freedesktop.secrets`/portal Secret with the flag present, or (d) the xtradeb wrapper no longer sources `/etc/chromium.d`.

## Architecture Investigation Evidence

| Source / Command / Probe | Exact Path / Reference | Observation | Design Decision Supported | Remaining Uncertainty |
| --- | --- | --- | --- | --- |
| Wrapper read | `/usr/bin/chromium` lines 76–77, 153 (TECH-003) | Sources `/etc/chromium.d/*` for every launch | Drop-in is the single owner of the flag; `start-chrome.sh` unchanged | Future packaging → AC-001/003 checks |
| Chromium source | `freedesktop_secret_key_provider.cc`, `browser_process_impl.cc` (TECH-005/006) | `basic` skips Secret Service and portal providers | Use `--password-store=basic` | — |
| Probe B / G | RUN-004, RUN-010 | Flag alone or purge alone each remove the dialog | Keep both (defense in depth, approved) | — |
| Probe E / F | RUN-008, RUN-009 | Only package removal makes every keyring client fail fast | Purge `gnome-keyring` (REQ-006) | — |
| `apt-get -s purge` default + zh | RUN-007; zh check 2026-09-25 | Removes exactly `gnome-keyring`, `libpam-gnome-keyring`, `evolution-data-server` | Explicit purge; no `autoremove`, no global `--no-install-recommends` | amd64 package graph assumed identical → verified by image checks |
| Existing tests | `tests/validate-{source-contract,image,running-container,build-wrapper}.sh` | Established homes for source, image and runtime contracts | Extend existing scripts; no new test framework | — |
| Release mechanics | RUN-013 | Server needs no code change; `v*` tags fire 5 release workflows; `workflow_dispatch` exists for server docker; launcher `upgrade --all` recreates keeping volumes | DEC-005 release sequence | — |

## Intended Change

1. Stop shipping the interactive keyring service in the base image (purge `gnome-keyring`, `libpam-gnome-keyring`).
2. Make every Chromium launch use `--password-store=basic` through one `/etc/chromium.d` drop-in.
3. Lock both into the existing validation scripts, document them, and release base `1.4.1`; then re-publish the unchanged server images on the new base and upgrade nodes.

## Relevant Behavior And Production-Path Map (Mandatory)

| Behavior ID | Kind | Approved Requirement / Intent And Acceptance-Criteria IDs | Approved Trigger Or Governing Contract | Relevant Existing Behavior And Evidence Reference | Approved Change Or Preserved Outcome | Target Production Path / Lifecycle And Spine ID(s) |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | System | REQ-001/003/004, AC-001/003/004 | Container start | Dialog at Chromium start (RUN-001/002) | No dialog; Chromium on built-in key; all other startup behavior preserved | DS-001 |
| BEH-002 | System/User | REQ-002, AC-002 | DevTools / bridge / desktop navigation | Navigation stalls (RUN-003) | Pages load unattended | DS-001 |
| BEH-003 | User | REQ-004, AC-005 | Node upgrade on existing volume | Container-layer keyring (DATA-001) | No keyring; one-time re-login where applicable | DS-003 |
| BEH-004 | Operational | REQ-006, AC-008 | Image build | Keyring pulled by Recommends (RUN-012) | Keyring not shipped | DS-002 |
| BEH-005 | System | REQ-006, AC-007 | Any process calls Secret Service | Dialog/hang for `vncuser` clients (RUN-008) | Immediate ServiceUnknown | DS-001 |
| — | Operational | REQ-005, AC-006 | Release | 1.4.0 published; server on `latest`/`zh` | 1.4.1 published; server re-published; nodes upgraded | DS-003 |

## Relevant Supplemental Task Artifacts

| Artifact Path | Purpose | Related Requirement / Acceptance-Criteria IDs (When Applicable) | Relationship To This Design | Status / Approval Applicability |
| --- | --- | --- | --- | --- |
| `evidence/probe-chromium-d-dropin.txt` | Probe drop-in content | AC-001/003 | Shape of the production drop-in (production file adds comments) | Evidence only |
| `evidence/probe-*.png` | Before/after screenshots | AC-001/002 | Expected observable outcome | Evidence only |

## Task Design Health Assessment (Mandatory)

- Change posture: `Bug Fix`
- Current design issue found: `No` (configuration omission, not a structural flaw)
- Root cause classification: `Missing Invariant` — the image never asserted "no interactive keyring / Chromium uses basic store"; the Ubuntu 24.04 package graph silently broke it.
- Refactor needed now: `No`
- Evidence: TECH-001..006, RUN-006/007/012.
- Design response: Add the invariant in the two places that own it (package set in `Dockerfile`; Chromium launch options in the `/etc/chromium.d` drop-in) and assert it in the existing validation scripts.
- Refactor rationale: Owners, file placement and test structure are healthy for this scope.
- Intentional deferrals and residual risk: Global `--no-install-recommends` slimming deferred (out of scope); other desktop extras stay.

## Terminology

- *Keyring provider*: a process implementing `org.freedesktop.secrets` (here `gnome-keyring-daemon`, dialog via `gcr-prompter`).
- *Drop-in*: a shell snippet in `/etc/chromium.d/` sourced by `/usr/bin/chromium` before exec.

## Design Reading Order

Followed as in the template; mappings are applied proportionately to a Small/Low configuration change.

## Legacy Removal Policy (Mandatory)

- Policy: `No backward compatibility; remove legacy code paths.`
- Required action: Remove the unintended keyring packages from the image. No compatibility switch or opt-in to re-enable a keyring is added. `start-chrome.sh` does not duplicate the flag.

## Persisted Data / State Transition Decision (Mandatory When Persisted Data May Be Affected)

- Stored subject: Chromium profile volume `/home/vncuser/.config/chromium` (per-node named volume); container-layer `~/.local/share/keyrings` exists only in nodes where an operator typed a keyring password (e.g. `autobyteus-server-0`).
- Change: Chromium's encryption-key source becomes explicitly the built-in key; keyring and provider absent.
- Normal reader/writer behavior: Chromium reads the profile version-agnostically; values it cannot decrypt are treated as absent.
- Required semantics: All non-keyring-encrypted profile state keeps working.
- Constraints: Keyring files are in the container layer and disappear on re-create anyway.
- Decision: `Directly Usable — No Migration` for the profile; keyring-encrypted cookie/password values are `Discard or Rebuild` (rebuilt by one re-login; approved DEC-003).
- Rationale: A migration would require the typed keyring password inside an unattended upgrade and restores values of low value; approved loss is minimal.
- Supported ACs: AC-005.

## Data-Flow Spine Inventory

| Spine ID | Scope | Related Behavior ID(s) | Start | End | Governing Owner | Why It Matters |
| --- | --- | --- | --- | --- | --- | --- |
| DS-001 | Primary End-to-End | BEH-001/002/005 | Container start / navigation request | Page rendered, no dialog | Chromium launch configuration (`/etc/chromium.d` drop-in) | Carries the runtime behavior |
| DS-002 | Bounded Local | BEH-004 | Image build layer 2 | Image without keyring provider | `Dockerfile` package set | Where the provider enters/leaves |
| DS-003 | Primary End-to-End | BEH-003, REQ-005 | Base release | Upgraded nodes | Release process (delivery) | How the fix reaches agents |

## Primary Execution Spine(s)

- DS-001: `supervisord chrome → start-chrome.sh → /usr/bin/chromium (sources /etc/chromium.d/autobyteus-password-store) → chromium --password-store=basic → PosixKeyProvider → navigation`; bridge/desktop: `xdg-open → chromium.desktop → /usr/bin/chromium → (same)`.
- DS-003: `browser_docker 1.4.1 build-multi-arch --push (default, zh) → Docker Hub latest/zh → Server Docker Release workflow_dispatch (default, zh) → autobyteus/autobyteus-server:<tag>/latest[-zh] → autobyteus-docker upgrade --all → node containers re-created (volumes kept)`.

## Spine Narratives (Mandatory)

| Spine ID | Short Narrative | Main Domain Subject Nodes | Governing Owner | Key Off-Spine Concerns |
| --- | --- | --- | --- | --- |
| DS-001 | Whatever starts Chromium goes through the wrapper, which applies the drop-in; Chromium never contacts a keyring and navigation proceeds. Other processes asking for a keyring get ServiceUnknown because no provider exists. | wrapper, drop-in, Chromium | Drop-in | Validation assertions |
| DS-002 | The single install RUN installs the package set, then explicitly purges the keyring provider before apt cleanup. | Dockerfile layer 2 | `Dockerfile` | Image checks |
| DS-003 | Publish base, re-publish server images from the unchanged server source on the new base, then upgrade nodes with the launcher. | Images, workflows, launcher | Delivery | Digest/rollback records |

## Spine Actors / Main-Line Nodes

`Dockerfile` (layer 2 + COPY), `/etc/chromium.d/autobyteus-password-store`, `/usr/bin/chromium` wrapper (unchanged, distribution-owned), release scripts/workflows (unchanged).

## Ownership Map

- `Dockerfile`: owns the image package set and file placement (adds purge + COPY).
- `chromium.d/autobyteus-password-store` → `/etc/chromium.d/autobyteus-password-store`: sole owner of Chromium's password-store policy.
- `start-chrome.sh`: keeps owning supervisor launch arguments (DevTools, mobile-safe); must not duplicate the password-store policy.
- `tests/validate-*.sh`: own the source, image and runtime contracts.

## Thin Entry Facades / Public Wrappers (If Applicable)

| Facade / Entry Wrapper | Governing Owner Behind It | Why It Exists | Must Not Secretly Own |
| --- | --- | --- | --- |
| `/usr/bin/chromium` (distribution) | Drop-ins in `/etc/chromium.d` | Applies flags to every launch | Not modified by us |

## Removal / Decommission Plan (Mandatory)

| Item To Remove / Decommission | Why It Becomes Unnecessary | Replaced By Which Owner / File / Structure | Scope | Notes |
| --- | --- | --- | --- | --- |
| `gnome-keyring`, `libpam-gnome-keyring` packages | Interactive provider not wanted on agent nodes | None (no provider) | In This Change | Purge also removes `evolution-data-server` (hard dependency); expected |

## Return Or Event Spine(s) (If Applicable)

N/A — no event flow.

## Bounded Local / Internal Spines (If Applicable)

DS-002 only (build layer); described above.

## Off-Spine Concerns Around The Spine

| Off-Spine Concern | Related Spine ID(s) | Serves Which Owner | Responsibility | Why It Exists | Risk If Misplaced On Main Line |
| --- | --- | --- | --- | --- | --- |
| Validation assertions | DS-001/002 | Dockerfile, drop-in | Prove invariant per variant/arch | Regression guard | — |
| README documentation | DS-001/002 | Image consumers | Explain no-keyring posture and sensitivity of the profile volume | Downstream awareness | — |
| Release evidence (digests, rollback ids) | DS-003 | Delivery | Traceable publish | Rollback | — |

## Ownership Boundaries

The base image owns Chromium configuration and the package set; downstream images (AutoByteus server, all-in-one) inherit it and must not re-configure the password store. The distribution wrapper is consumed, not edited.

## Boundary Encapsulation Map

| Authoritative Boundary | Internal Owned Mechanism(s) It Encapsulates | Upstream Callers That Must Use The Boundary | Forbidden Bypass Shape | If Boundary API Is Too Thin, Fix By |
| --- | --- | --- | --- | --- |
| `/usr/bin/chromium` + `/etc/chromium.d` | Flag assembly | `start-chrome.sh`, `chromium.desktop`, bridge | Launching `/usr/lib/chromium/chromium` directly or adding the flag in `start-chrome.sh` | Add another drop-in, not per-caller flags |

## Dependency Rules

- `start-chrome.sh` continues to exec `/usr/bin/chromium` (never the binary directly).
- No other file sets `--password-store`.
- The server repository must not add a competing Chromium/keyring configuration.

## Interface Boundary Mapping

| Interface / API / Query / Command / Method | Subject Owned | Responsibility | Accepted Identity Shape(s) | Notes |
| --- | --- | --- | --- | --- |
| `CHROMIUM_FLAGS` drop-in contract | Chromium launch flags | Append `--password-store=basic` | Shell snippet sourced by wrapper | Distribution contract |

## Interface Boundary Check

| Interface | Responsibility Is Singular? | Identity Shape Is Explicit? | Ambiguous Selector Risk | Corrective Action |
| --- | --- | --- | --- | --- |
| `/etc/chromium.d/autobyteus-password-store` | Yes | Yes | Low | — |

## Main Domain Subject Naming Check

| Node / Subject | Current / Proposed Name | Name Is Natural And Self-Descriptive? | Naming Drift Risk | Corrective Action |
| --- | --- | --- | --- | --- |
| Drop-in | `autobyteus-password-store` (repo: `chromium.d/autobyteus-password-store`) | Yes (matches Debian drop-in naming: `default-flags`, `apikeys`) | Low | — |

## Existing Capability / Subsystem Reuse Check

| Need / Concern | Existing Capability Area / Subsystem | Decision | Why | If New, Why Existing Areas Are Not Right |
| --- | --- | --- | --- | --- |
| Apply flag to all launches | Distribution `/etc/chromium.d` | Reuse | Covers every launch path | — |
| Package removal | Dockerfile layer 2 | Extend | Same layer owns packages; keeps image layers minimal | — |
| Validation | Existing `tests/validate-*.sh` | Extend | Established contracts | — |
| Publish | `build-multi-arch.sh`; superrepo `release-server-docker.yml`; `autobyteus-docker upgrade` | Reuse | Unchanged | — |

## Subsystem / Capability-Area Allocation

| Subsystem / Capability Area | Owns Which Concerns | Related Spine ID(s) | Governing Owner(s) Served | Decision | Notes |
| --- | --- | --- | --- | --- | --- |
| Image build (`Dockerfile`) | Package set, file placement | DS-002 | Image | Extend | — |
| Chromium configuration (`chromium.d/`) | Password-store policy | DS-001 | Chromium | Create New (one file) | — |
| Validation (`tests/`) | Contracts | DS-001/002 | All | Extend | — |
| Release (delivery) | Publish/upgrade | DS-003 | Delivery | Reuse | — |

## Draft File Responsibility Mapping

See Final File Responsibility Mapping (no extraction needed).

## Reusable Owned Structures Check

N/A — no repeated structures.

## Shared Structure / Data Model Tightness Check

N/A — no shared data structures.

## Final File Responsibility Mapping

| File | Owning Subsystem / Capability Area | Owner / Boundary | Concrete Concern | Why This Is One File | Reuses Shared Structure? |
| --- | --- | --- | --- | --- | --- |
| `Dockerfile` | Image build | Image | Purge keyring packages; COPY drop-in; normalize/permission it | Existing owner | No |
| `chromium.d/autobyteus-password-store` (new) | Chromium configuration | Drop-in | Append `--password-store=basic` | One policy, one file | No |
| `VERSION` | Release | Image | `1.4.1` | Existing | No |
| `README.md` | Docs | Consumers | Document posture | Existing | No |
| `tests/validate-source-contract.sh` | Validation | Source contract | Static assertions | Existing | No |
| `tests/validate-image.sh` | Validation | Image contract | Package/file assertions | Existing | No |
| `tests/validate-running-container.sh` | Validation | Runtime contract | Process/D-Bus/navigation assertions | Existing | No |

## Applied Patterns (If Any)

Distribution drop-in configuration (`/etc/chromium.d`).

## Target Subsystem / Folder / File Mapping

| Path | Kind | Owner / Boundary | Responsibility | Why It Belongs Here | Must Not Contain |
| --- | --- | --- | --- | --- | --- |
| `chromium.d/` | Folder | Chromium configuration | Files copied verbatim to `/etc/chromium.d/` | Mirrors target path | Scripts executed at runtime |
| `chromium.d/autobyteus-password-store` | File | Drop-in | Flag export + rationale comment | — | Other flags |
| `Dockerfile` | File | Image build | Changes below | — | — |
| `tests/validate-*.sh` | Files | Validation | New assertions | — | — |

## Folder Boundary Check

| Path / Folder | Intended Structural Depth | Ownership Boundary Is Clear? | Mixed-Layer Or Over-Split Risk | Justification / Corrective Action |
| --- | --- | --- | --- | --- |
| `chromium.d/` | Off-Spine Concern (configuration) | Yes | Low | Mirrors install path; keeps repo root for scripts |

## Concrete Examples / Shape Guidance (Mandatory When Needed)

| Topic | Good Example | Bad / Avoided Shape | Why The Example Matters |
| --- | --- | --- | --- |
| Drop-in | `chromium.d/autobyteus-password-store`:<br>`# Sourced by /usr/bin/chromium for every launch (supervisor, xdg-open, desktop).`<br>`# AutoByteus nodes are agent-operated: never use an OS keyring, whose`<br>`# create/unlock dialogs block unattended browsing.`<br>`export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --password-store=basic"` | Adding the flag to `start-chrome.sh` only (misses `xdg-open`/desktop launches) | Single owner, all launch paths |
| Purge placement | Layer 2, after the zh `fi && \`:<br>`    # Agent-operated node: ship no interactive keyring service (it arrives only via`<br>`    # apt Recommends and blocks unattended use with a "new keyring" dialog).`<br>`    apt-get purge -y gnome-keyring libpam-gnome-keyring && \`<br>`    apt-get clean && rm -rf /var/lib/apt/lists/*` | Separate later `RUN` (layer bloat); `apt-get autoremove` (unbounded removals); global `--no-install-recommends` (out of scope) | Bounded, same layer |
| Drop-in install | `COPY chromium.d/autobyteus-password-store /etc/chromium.d/autobyteus-password-store` with the other COPYs; add to `dos2unix`; `chmod 0644`, root-owned (not added to the `chmod +x`/`chown vncuser` list) | Executable or vncuser-owned drop-in | Sourced config, not a script |
| Runtime keyring check | as `vncuser`: `DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UID/bus timeout 5 dbus-send --session --print-reply --dest=org.freedesktop.secrets /org/freedesktop/secrets org.freedesktop.DBus.Peer.Ping` → non-zero, output contains `ServiceUnknown`/`not provided by any .service files`, elapsed ≤ 2 s | Checking only process absence | Proves fail-fast (AC-007); `dbus-send` ships with the explicitly installed `dbus` |

## Backward-Compatibility Rejection Log (Mandatory)

| Candidate Compatibility Mechanism | Why It Was Considered | Rejection Decision | Clean-Cut Replacement / Removal Plan |
| --- | --- | --- | --- |
| Env/opt-in to keep gnome-keyring or a keyring password store | Someone might want an OS keyring | Rejected | Downstream images may install it deliberately; Chromium still uses `basic` |
| Migrating keyring-encrypted cookies to the built-in key | Preserve logins | Rejected | One-time re-login (approved) |
| APT negative pin on `gnome-keyring` | Also blocks re-install | Rejected (not needed) | Chromium drop-in already guards the browser; pin could break agents' deliberate installs |

## Derived Layering (If Useful)

N/A.

## Change / Refactor Sequence

1. `browser_docker` (this worktree, branch `codex/chromium-keyring-prompt`): add `chromium.d/autobyteus-password-store`; edit `Dockerfile` (purge step in layer 2 before `apt-get clean`; COPY; dos2unix list; `chmod 0644`); set `VERSION` to `1.4.1`; update `README.md` (Features/“No OS keyring” section: provider not shipped, Chromium `--password-store=basic` via `/etc/chromium.d/autobyteus-password-store`, profile volume is the sensitive store, keyring-using tools fail fast and use file fallbacks, upgrade from 1.4.0 may require one re-login where a keyring was created; downstream images must not re-configure the password store).
2. Tests:
   - `validate-source-contract.sh`: `VERSION` 1.4.1; Dockerfile contains the purge line and the COPY to `/etc/chromium.d/autobyteus-password-store`; drop-in contains the literal export line; `--password-store` appears nowhere else (`start-chrome.sh`, `base.conf`); README documents the posture.
   - `validate-image.sh` (both variants): `gnome-keyring`, `libpam-gnome-keyring` not installed; no `/usr/share/dbus-1/services/{org.freedesktop.secrets,org.freedesktop.impl.portal.Secret,org.gnome.keyring}.service`; drop-in present, root-owned, mode 644, and sourcing it yields `--password-store=basic`; `chromium` and `xfce4-session` still installed.
   - `validate-running-container.sh`: Chromium main process has `--password-store=basic`; extend the DevTools probe to also navigate to `http://127.0.0.1:6080/` and assert the rendered title (`Directory listing for /`) within 30 s (AC-002, no internet dependency); afterwards no `gcr-prompter`/`gnome-keyring-daemon` process and no `org.freedesktop.secrets` activation line in `/var/log/supervisor/dbus.err.log`; the AC-007 `dbus-send` check.
   - Negative control (evidence, not committed): run the new runtime checks against `autobyteus/chrome-vnc:1.4.0` (or the current server image) and confirm they fail.
3. Validate: source contract; build default + zh for arm64 (local) and amd64 (buildx); `validate-image.sh` for default, zh, custom UID; `validate-running-container.sh` default + zh; `validate-build-wrapper.sh` unchanged pass.
4. Delivery (DS-003, DEC-005):
   a. Merge to `origin/main`; `./build-multi-arch.sh --push` and `./build-multi-arch.sh --variant zh --push` → `1.4.1`/`latest`, `1.4.1-zh`/`zh`; verify amd64+arm64 manifests and record digests plus 1.4.0 rollback digests.
   b. Superrepo (no code change): `gh workflow run release-server-docker.yml -f release_tag=<latest published v* tag, currently v1.4.79>` then again with `-f publish_zh=true`; record before/after server digests (rollback = previous digests). Do **not** cut a new `v*` tag for this (would fire desktop/Android/iOS/gateway releases). Verify the published server images: no `gnome-keyring`, drop-in present, AC-001/002/007 on a throwaway container.
   c. Operator nodes: `autobyteus-docker upgrade --all` (pull + re-create, named volumes kept); spot-check one node for no dialog. Local server builds, if any, must `docker pull autobyteus/chrome-vnc:latest` (and `:zh`) first because `build.sh` has no `--pull`.

## Key Tradeoffs

- Two mechanisms instead of one: small redundancy accepted for a deterministic browser policy that survives later package installs (user-approved).
- Explicit purge vs. global `--no-install-recommends`: purge is bounded and verifiable; global slimming is a separate decision.
- Manual server re-publish of an existing tag vs. new release tag: avoids unrelated desktop/mobile releases; the re-published tag contains identical server code on a newer base (recorded digests allow rollback).

## Risks

- RSK-001 (accepted): built-in cookie key is obfuscation only; profile volume is sensitive.
- RSK-002: another app could someday prompt — mitigated, no provider exists.
- RSK-004: local builds reuse a stale `chrome-vnc:latest` — mitigated by delivery guidance (`docker pull` first); CI runners resolve fresh.
- RSK-005: future Ubuntu update makes a required package hard-depend on `gnome-keyring` → purge would remove it; caught by image checks (escalation trigger a).

## Guidance For Implementation

- Keep the purge inside the existing layer-2 RUN, after the zh block and before `apt-get clean`; do not add `autoremove`.
- The drop-in is sourced shell: keep it POSIX, comment-only besides the single `export` line; CRLF-safe via existing `dos2unix`.
- Do not change `start-chrome.sh`, `base.conf`, `entrypoint.sh`, ports, supervisor programs or profile-lock logic.
- Update the obsolete `VERSION must be 1.4.0` contract rather than adding a second version check.
- Record all command outputs as evidence under `requirements/chromium-keyring-prompt/evidence/`.
