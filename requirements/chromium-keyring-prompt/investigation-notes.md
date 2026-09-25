# Investigation Notes

## Investigation Meta

- Package identifier: `BRD-KEYRING-PROMPT-001`
- Request / ticket: "In the server docker node, when one website is opened from chrome, this [Choose password for new keyring] popped up — how to disable it, please analyse" (user, 2026-09-24, screenshot `evidence/user-report-keyring-prompt.png`)
- Workspace root: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt`
- Repository mode: `Git`
- Task worktree / branch: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt` / `codex/chromium-keyring-prompt`
- Resolved base remote / branch / revision: `origin` / `main` / `4d03f29a46d6d7cf96649718731efe25bef335ab` (fetched 2026-09-24; browser image `VERSION` = `1.4.0`)
- Finalization target remote / branch: `origin` / `main` (browser image repository). Downstream server image (`autobyteus-workspace-superrepo`, `autobyteus-server-ts/docker/Dockerfile.monorepo`, `FROM autobyteus/chrome-vnc:${BASE_IMAGE_TAG:-latest}`) consumes the fix by rebuild only; see DEC-002.
- Bootstrap result: Worktree created from freshly fetched `origin/main`. The user's primary checkout (`/Users/normy/autobyteus_org/browser_docker`, branch `codex/python313-supervisor-compatibility`, 21 commits behind) was not modified.
- Bootstrap blocker: None
- Current solution revision ID: `SR-005`
- Investigation status: Complete. Requirements `Approved` (SR-004, 2026-09-25); design `Ready` (SR-005).

## Initial Request And Clarifications

- Original request: Analyse why the GNOME "Choose password for new keyring" dialog appears in the AutoByteus server Docker node's VNC desktop when Chromium opens a website, and how to disable it.
- Clarifications received: The base image source is `/Users/normy/autobyteus_org/browser_docker` (user, 2026-09-24).
- User-supplied facts and constraints: Screenshot shows Chromium (`about:blank` tab still loading, "Restore pages?" bubble) with the gcr keyring-creation dialog on `vncuser`'s XFCE desktop, 2026-09-24 10:30.
- Initial ambiguity: Which process requested the keyring (Chromium vs. Codex/Claude CLIs vs. desktop services) — resolved: Chromium (see RUN-002).

## Product And Domain Understanding

- Product area: `autobyteus/chrome-vnc` browser base image (Ubuntu 24.04, XFCE over TigerVNC, Chromium with DevTools on 9222/9223) and the `autobyteus/autobyteus-server` image built on it.
- Affected actors or systems: Human operator watching the node through VNC/noVNC; AutoByteus agents that drive the node's Chromium through DevTools (browser tools / `open_tab`); server-side URL opening via `open-vnc-browser-url.sh`.
- Existing user or operational purpose: Unattended, agent-driven browser in a container; the operator should not need to interact with OS dialogs for the browser to work.
- Relevant terminology: *Secret Service* (`org.freedesktop.secrets` D-Bus API), *gnome-keyring* (provider), *gcr-prompter* (dialog process), Chromium *password store* (`basic` / `gnome-libsecret` / `kwallet*`), *os_crypt* (Chromium's cookie/password encryption-key layer), `v10` (built-in key) vs `v11` (keyring-held key) encrypted values.

## Source Log

| Date | Source Type | Exact Source / Command / Query | Why Consulted | Relevant Finding | Follow-Up |
| --- | --- | --- | --- | --- | --- |
| 2026-09-24 | Code | `git show origin/main:{Dockerfile,start-chrome.sh,base.conf,entrypoint.sh}` (browser_docker) | Find how Chromium/desktop are provisioned | `apt-get install -y ... chromium xfce4 xfce4-terminal` **without `--no-install-recommends`**; `start-chrome.sh` runs `/usr/bin/chromium --no-first-run --disable-gpu --disable-dev-shm-usage --remote-debugging-port=9222` with **no `--password-store`**; supervisor `chrome` program sets no `XDG_CURRENT_DESKTOP` | TECH-001..003 |
| 2026-09-24 | Code | `git show fb0f593:Dockerfile` (1.3.8) | Compare with previous release | 1.3.8 was `FROM ubuntu:22.04`, same package list | RUN-006 |
| 2026-09-24 | Code | `git show origin/personal:autobyteus-server-ts/docker/{Dockerfile.monorepo,open-vnc-browser-url.sh,...}` (superrepo) | Server layering | Server runtime is `FROM autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` (default `latest`); adds no Chromium flags; `open-vnc-browser-url.sh` opens URLs as `vncuser` via `xdg-open` → `chromium.desktop` → `/usr/bin/chromium` | TECH-004 |
| 2026-09-24 | Runtime | `docker ps`; `docker exec <c> ps ...` on 7 local `autobyteus-server-*` containers | Check prevalence | All 7 run Ubuntu 24.04 images; all 7 have `gnome-keyring-daemon --components=secrets`; 6 of 7 have `/usr/libexec/gcr-prompter` pending (server-3, `latest-zh`, for 11 days). server-0 has no prompter because the user typed a password at 10:31 | RUN-001 |
| 2026-09-24 | Runtime | `docker exec autobyteus-server-1 cat /var/log/supervisor/dbus.err.log` | Identify requester | `Activating service name='org.freedesktop.secrets' requested by ':1.8' (uid=1000 pid=41 comm="/usr/lib/chromium/chromium ...")` at 07:10:52 (Chromium startup), then gnome-keyring activates `org.gnome.keyring.SystemPrompter` | RUN-002 |
| 2026-09-24 | Runtime | `chromium --version`; `dpkg -l`; `apt-cache rdepends --installed gnome-keyring`; `apt-cache show network-manager-gnome gvfs-backends` | Package origin | Chromium `151.0.7922.173-1xtradeb1.2404.1`; `gnome-keyring 46.1`, `gcr`, `libpam-gnome-keyring`, `xdg-desktop-portal(-gtk)` installed; gnome-keyring arrives via **Recommends** of `network-manager-gnome` and `gvfs-backends` (pulled by the `xfce4` stack) | TECH-002 |
| 2026-09-24 | Runtime | `ls ~/.local/share/keyrings`; `Local State` `os_crypt` | State | Fresh containers: keyrings dir empty (no default collection). server-0: `Default_Keyring.keyring` + `default` created 10:31 in the **container layer** (not a volume). `/home/vncuser/.config/chromium` **is** a named volume (`autobyteus-server-N-chromium-profile`) | DATA-001 |
| 2026-09-24 | Web/Code | `raw.githubusercontent.com/chromium/chromium/main/components/os_crypt/async/browser/freedesktop_secret_key_provider.cc` | Backend-selection rules | `GetKey`: `password_store_ == "basic"` → `FinalizeFailure(kDisabled)` (use built-in key). Otherwise auto-detect: `DESKTOP_ENVIRONMENT_OTHER` (no `XDG_CURRENT_DESKTOP`) **and** `XFCE` → `InitializeFreedesktopSecretService()`. `OnReadAliasDefault`: if alias `default` is `/` → `CreateCollection(label=kDefaultCollectionLabel, alias="default")` via prompt → gnome-keyring's "Choose password for new keyring … 'Default Keyring'" dialog | TECH-005 |
| 2026-09-24 | Web/Code | `chrome/browser/browser_process_impl.cc` (main) lines ~1622–1648 | Is portal also disabled by the flag? | `if (password_store != "basic") { SecretPortalKeyProvider (if kDbusSecretPortal) ; FreedesktopSecretKeyProvider }`; `PosixKeyProvider` always added. `--password-store=basic` therefore disables **both** keyring paths | TECH-006 |
| 2026-09-24 | Web/Doc | https://chromium.googlesource.com/chromium/src/+/main/docs/linux/password_storage.md | Supported flag values | `--password-store=basic|gnome-libsecret|kwallet|kwallet5|kwallet6`; falls back to `basic` if the store is unavailable | — |
| 2026-09-24 | Runtime | `/usr/bin/chromium` wrapper lines 76–77, 153 | Where flags can be injected for all launch paths | Wrapper sources every file in `/etc/chromium.d/*` (except README / `*.dpkg*`) and execs `$LIBDIR/chromium $CHROMIUM_FLAGS "$@"`; `chromium.desktop` `Exec=/usr/bin/chromium %U` | TECH-003 |
| 2026-09-24 | Runtime | `docker run --rm autobyteus/chrome-vnc:1.3.8-arm64 ...` | Regression origin | 1.3.8 (Ubuntu 22.04, Chromium 149): **gnome-keyring not installed, no `org.freedesktop.secrets`/portal D-Bus service** → Chromium's Secret Service lookup fails silently → built-in key, no dialog | RUN-006 |
| 2026-09-24 | Runtime | A/B/C probes (see Runtime findings) | Validate cause, fix and stop-gap | Confirmed | — |

## Relevant Existing Behavior And Supported Product Paths

| Behavior ID | Kind | Supported Trigger Or Governing Contract | Current Supported Product Behavior Path / Lifecycle | Current Outcome / Invariants | Evidence | Confidence / Unknown |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | System | Container start → supervisor `chrome` program | Chromium starts unattended with DevTools on 9222 (socat 9223) inside `vncuser`'s XFCE session | On 1.4.0: Chromium immediately requests the Secret Service; because no default keyring exists, a modal "Choose password for new keyring" dialog appears on the VNC desktop and stays until a human answers | RUN-001, RUN-002 | High |
| BEH-002 | System / User | Agent browser tool (DevTools `json/new`/CDP) or server `open-vnc-browser-url.sh` opens a website | Tab is created and navigates | On 1.4.0, while the dialog is pending, navigation does **not** complete (probe: page title empty after 90 s; user screenshot shows the tab still loading). Works immediately after the dialog is answered/cancelled | RUN-003, RUN-005 | High (observed); exact internal wait mechanism not traced — cookie store/os_crypt init is the likely gate (Cookies DB absent in control, present with fix) |
| BEH-003 | User | Operator answers the dialog with a password | gnome-keyring creates `Default Keyring` in `/home/vncuser/.local/share/keyrings` (container layer) and Chromium stores its v11 key there | Dialog gone for this container's life; but keyring is lost on container **re-creation** while the Chromium profile volume persists; a restart also leaves a locked keyring that prompts to unlock | DATA-001 | High for storage locations; restart/unlock behavior inferred from gnome-keyring semantics, not probed |
| BEH-004 | Operational | Previous 1.3.x base images | No Secret Service provider → Chromium uses built-in (`basic`) key | No dialog; browsing works unattended | RUN-006 | High |
| BEH-005 | User | Operator browses via VNC after abrupt container stop | Chromium shows "Restore pages? Chromium didn't shut down correctly." | Independent of keyring; caused by container stop killing Chromium | Screenshot | High — out of scope (DEC-004) |

## Relevant Codebase And Technical Facts

| Path / Component / Contract | Current Responsibility Or Behavior | Requirement Implication | Architecture Question / Design Implication |
| --- | --- | --- | --- |
| TECH-001 `browser_docker/start-chrome.sh` | Only supervisor launch path; sets DevTools, no password-store | Covers supervisor launches only | A flag here would not cover `xdg-open`/desktop-menu launches when Chromium isn't already running |
| TECH-002 `browser_docker/Dockerfile` layer 2 | Installs `xfce4` etc. with Recommends → brings `gnome-keyring`, `gcr`, `libpam-gnome-keyring`, `xdg-desktop-portal`, `network-manager-gnome`, `gvfs-backends`, `evolution-data-server` | Removing keyring package is possible but broader (dependency surface, image contents) | Package-level alternative (DEC-001 option B) |
| TECH-003 `/usr/bin/chromium` + `/etc/chromium.d/` (xtradeb/Debian wrapper) | Sources drop-ins into `CHROMIUM_FLAGS` for **every** `/usr/bin/chromium` launch | A single drop-in covers supervisor, `xdg-open`/`chromium.desktop`, and XFCE menu launches | Likely single owner for the flag (design phase to confirm) |
| TECH-004 superrepo `autobyteus-server-ts/docker/*` | Inherits base; no Chromium flag; bridges `xdg-open`/`exo-open` for root | Server gets the fix by rebuilding on the new base; no server source change needed unless an interim hotfix is chosen (DEC-002) | — |
| TECH-005 Chromium `FreedesktopSecretKeyProvider` (M151) | Unknown desktop (`OTHER`) and `XFCE` → Secret Service; missing default collection → interactive `CreateCollection` prompt | Root cause of the dialog; environment tweaks (e.g. `XDG_CURRENT_DESKTOP`) cannot avoid it — only `basic` or no provider can | — |
| TECH-006 Chromium `BrowserProcessImpl` provider wiring | `--password-store=basic` skips both `SecretPortalKeyProvider` and `FreedesktopSecretKeyProvider`; `PosixKeyProvider` remains | One flag disables all keyring interaction | — |

## Structural And Payload Surface Inventory

### Payload Or Content Surfaces

- Files: browser image `Dockerfile`, `start-chrome.sh`, optional new `/etc/chromium.d/` drop-in, `README.md`, `VERSION`, `tests/validate-*.sh`.
- Existing readers: `/usr/bin/chromium` wrapper (reads `/etc/chromium.d/*`); supervisor `base.conf`.
- Evidence paths: see Source Log.

### Structural Surfaces

- Deployment configuration only (container image contents / browser launch flags). No APIs, schemas, or server code.
- Evidence paths: browser_docker `origin/main`.

### Potential Structural Impacts To Investigate

- API or external-contract change: None.
- Persistence schema or invariant change: Chromium cookie/password encryption key source changes from "keyring (never obtained)" to built-in; see DATA-001.
- Security or privacy boundary change: Yes (minor) — browser-stored secrets on the profile volume protected by Chromium's built-in key rather than a keyring-held key. Needs explicit user acceptance (DEC-001).
- Concurrency or lifecycle change: Removes a startup blocker.
- Deployment change: New browser image release (1.4.1 default + zh, amd64 + arm64) and server image rebuild.
- Confirmed absent: server source changes (unless DEC-002 interim hotfix).

## Runtime, Probe, Or Reproduction Findings

All probes used throwaway containers from local `autobyteus/autobyteus-server:latest` (1.4.0-based, Chromium 151) with the same `--security-opt seccomp=unconfined --cap-add SYS_ADMIN` as the real nodes, server program removed, then deleted. The user's running containers were only inspected read-only.

| Method / Command | Scenario | Observation | Requirement Implication | Artifact / Evidence Path |
| --- | --- | --- | --- | --- |
| RUN-001 `ps` in 7 live containers | Prevalence | gcr-prompter pending in 6/7 containers since container start (server-3 for 11 days) | Affects every 1.4.0-based node, default and zh | — |
| RUN-002 `dbus.err.log` | Requester | Chromium PID 41 activated `org.freedesktop.secrets` at startup → gnome-keyring → SystemPrompter | Chromium is the sole trigger | — |
| RUN-003 Probe A (control) + DevTools `json/new https://www.wikipedia.org` | Reproduce | Dialog appears; tab stuck "Loading…"; title empty at +10/30/60/90 s; Cookies DB absent | Dialog blocks agent browsing, not just cosmetic | `evidence/probe-a-control-prompt-blocks-navigation.png` |
| RUN-004 Probe B: `/etc/chromium.d/zz-autobyteus-password-store` adds `--password-store=basic` | Candidate fix | Flag present on browser process; **no** `org.freedesktop.secrets` activation, no gnome-keyring-daemon, no gcr-prompter; Wikipedia loads; Cookies DB written | Fix eliminates dialog and restores browsing | `evidence/probe-b-password-store-basic-loads.png`, `evidence/probe-chromium-d-dropin.txt` |
| RUN-005 Probe C: click **Cancel** on dialog | Stop-gap for running nodes | Page loads immediately; no keyring file created | Safe manual workaround until images are rebuilt (dialog returns on next Chromium start) | `evidence/probe-c-cancel-unblocks-navigation.png` |
| RUN-006 1.3.8 image inspection | Regression origin | No gnome-keyring, no Secret Service/portal D-Bus services | Regression introduced by Ubuntu 24.04 package set in 1.4.0 | — |
| RUN-007 `apt-get -s purge gnome-keyring` in throwaway container | Removal blast radius | Purges only `gnome-keyring` + `evolution-data-server` (hard `Depends`); `gvfs-backends`, `network-manager-gnome`, `libpam-gnome-keyring` only *Recommend* it and stay | Removing the provider is contained; e-d-s (calendar/contacts) was also absent in 1.3.8 | — |
| RUN-008 Probe E: Chromium `--password-store=basic` only, then a generic libsecret client (`/usr/bin/python3` + `gi.repository.Secret.password_store_sync`, i.e. what `gh`, git credential helpers, Python `keyring`, OAuth token stores use) run as `vncuser` | Is the Chromium flag alone enough for an agent machine? | Chromium fine, but the client **raised the same keyring dialog and hung 20 s until killed** | Flag alone leaves every other keyring-using agent tool able to block → requirement must cover all processes, not just Chromium | — |
| RUN-009 Probe F: `gnome-keyring libpam-gnome-keyring evolution-data-server` purged + Chromium flag | Combined fix | No dialog; Wikipedia loads; same client **fails in 0 s** with `The name org.freedesktop.secrets was not provided by any .service files` (tools can fall back to file storage) | Satisfies REQ-001/002 for all processes | — |
| RUN-010 Probe G: keyring purged, **no** Chromium flag | Is the flag still needed? | Also no dialog, page loads | Package removal alone would also work | — |
| RUN-012 `apt-cache rdepends --installed` + `apt-config dump` in `autobyteus/autobyteus-server:latest` (2026-09-25) | Where does gnome-keyring come from? | Not listed in our `Dockerfile`; apt default `APT::Install-Recommends "1"`, and Layer 2 `apt-get install -y ... xfce4 ...` has no `--no-install-recommends`. Installed reverse deps: `evolution-data-server` (**Depends**), `gvfs-backends`, `network-manager-gnome`, `libpam-gnome-keyring` (**Recommends**); these themselves arrive as Recommends of other desktop extras (e.g. `indicator-datetime`, `unity-greeter`, `gnome-screensaver`, `gnome-bluetooth-sendto`) | Keyring is an unintended transitive extra of the base image; removing it targets exactly what we never asked for. Blanket `--no-install-recommends` would drop many more packages → too broad for this ticket | — |
| RUN-013 Release-mechanics read (2026-09-25): superrepo `origin/personal` `.github/workflows/release-*.yml`, `autobyteus-server-ts/docker/{build.sh,build-multi-arch.sh}`, `scripts/public/docker/autobyteus-docker.d/bash/{core.sh,docker-runtime.sh}`; `git tag` | How the fixed base reaches server images and nodes | Server `Dockerfile.monorepo`: `FROM autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` (`latest`; `zh` via build arg) → **no server code change needed**. `release-server-docker.yml` runs on `v*` tag push (default variant) or `workflow_dispatch` (`release_tag`, optional `release_ref`, `publish_zh=true` for zh); uses GHA cache, no `pull:` flag — fresh runners resolve the base tag from Docker Hub, so a new base digest rebuilds the runtime stage. **Every `v*` tag also triggers `release-desktop/android/ios/messaging-gateway`**. Latest tags: `v1.4.79`, `v1.4.78`. Local `build.sh`/`build-multi-arch.sh` have no `--pull` (a stale local `chrome-vnc:latest` would be reused). Node launcher: `autobyteus-docker upgrade --all` → `docker pull` saved image ref → "Image changed … recreating the managed container while keeping named volumes" | DEC-005: re-publish server images via manual `workflow_dispatch` only; upgrade nodes with the launcher | — |
| RUN-011 Throwaway container: as **root** with the server's inherited `DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus` (confirmed in PID 1 env), `gdbus ... GetId` and a libsecret store call | Can server-run agent tools (Codex, Claude Code, `gh`, run as root) reach the keyring? | `vncuser`'s session bus **rejects root** (`The connection is closed`); store call fails in 0 s; no dialog from it. `gnome-keyring` is a separate apt package (daemon `gnome-keyring-daemon` + D-Bus service files), not part of Chromium; Chromium does not depend on it | Chromium flag alone covers the agent path; uninstall only matters for tools run manually as `vncuser` in the desktop → user chose the simple solution | — |

## Stakeholder And User Evidence

| Source / Actor | Need, Problem, Or Constraint | Evidence Strength | Requirement Implication | Open Question |
| --- | --- | --- | --- | --- |
| User (operator) | Wants the keyring popup disabled in server docker nodes | Direct request + screenshot | REQ-001 | Accept built-in-key protection? (DEC-001) |
| User (operator), 2026-09-24 second follow-up | "If the simple solution works, then I would go for the simple solution instead of … uninstall this key ring" | Direct decision | DEC-001 = Chromium flag only; uninstall moved out of scope | Overall SR-003 approval |
| User (operator), 2026-09-24 follow-up | "I want to disable the keyring … the server Docker is supposed to be used by the agent itself … the agent is not like a human … suddenly they are blocked" | Direct clarification | Agent-first: no interactive keyring for any process; REQ-001 broadened; supports DEC-001 A+B | Final approval of SR-002 baseline |

## External Contracts, Standards, And Dependencies

| Contract / Dependency | Version / Authority | Relevant Behavior Or Constraint | Evidence | Unknown / Risk |
| --- | --- | --- | --- | --- |
| Chromium Linux password store | Chromium 151 (xtradeb `151.0.7922.173-1xtradeb1.2404.1`); Chromium docs `password_storage.md` | `--password-store=basic` is a documented, supported switch; disables keyring providers | TECH-005/006 | Future Chromium could change semantics — covered by an image validation check (AC-003) |
| xtradeb/Debian Chromium wrapper | `/usr/bin/chromium` | `/etc/chromium.d/*` drop-ins are sourced | TECH-003 | Wrapper convention could change in future packages — validation check |
| gnome-keyring / Secret Service | gnome-keyring 46.1 | Missing default collection + `CreateCollection` ⇒ interactive prompt | RUN-002 | — |

## Persisted Data And State Facts

- DATA-001 Affected stored subject: Chromium profile (`/home/vncuser/.config/chromium`, named volume per node) — cookies/saved passwords encryption.
- Current state: In nodes where the dialog is still pending, Chromium never obtained a keyring key. In a node where the operator typed a password (server-0), Chromium may have written v11 values encrypted with a key held in a keyring that lives in the **container layer**, not a volume.
- Acceptable loss (proposed): Values encrypted with a keyring key become unreadable after the change → affected sites require one re-login. The keyring itself would be lost on container re-creation anyway.
- Remaining evidence gap: Whether server-0 actually wrote v11 values after 10:31 was not inspected (not needed for the decision).

## Product Design Request Context

- Product Design request in the current input: `Not stated`
- Not applicable (container/infra behavior).

## Product Design Findings

N/A — not applicable.

## Supplemental Artifact Inventory

| Artifact Path | Owner | Purpose | Scope | Related Requirement / AC IDs | Status | Approval Applicability / State |
| --- | --- | --- | --- | --- | --- | --- |
| `evidence/user-report-keyring-prompt.png` | User | Original report | BEH-001 | REQ-001 | Final | Evidence only |
| `evidence/probe-a-control-prompt-blocks-navigation.png` | Solution Designer | Reproduction | BEH-001/002 | AC-001, AC-002 | Final | Evidence only |
| `evidence/probe-b-password-store-basic-loads.png` | Solution Designer | Candidate-fix validation | REQ-001/002 | AC-001..003 | Final | Evidence only |
| `evidence/probe-c-cancel-unblocks-navigation.png` | Solution Designer | Stop-gap validation | BEH-003 | — | Final | Evidence only |
| `evidence/probe-chromium-d-dropin.txt` | Solution Designer | Exact probe drop-in content | REQ-001 | AC-003 | Probe (not production) | Evidence only; design decides final form |

## Assumptions, Unknowns, And Risks

| ID | Type | Description | Why It Matters | Resolution / Owner | Status |
| --- | --- | --- | --- | --- | --- |
| RSK-001 | Risk | Built-in key offers obfuscation only; anyone with the profile volume can decrypt cookies | Security posture of agent browser sessions | User decision DEC-001; same default as Puppeteer/Playwright-launched Chromium | Open |
| RSK-002 | Risk | Other apps (evolution-data-server, nm-applet) could still create a keyring later | Could reintroduce a dialog | Not observed in any probe or live node; only Chromium requested it | Low / monitor |
| RSK-003 | Risk | A tool run manually as `vncuser` in the VNC desktop can still raise the dialog (RUN-008) | Human-only path; agents run as root (RUN-011) | Accepted residual; follow-up: uninstall `gnome-keyring` if ever observed | Accepted (user decision) |
| RSK-004 | Risk | Local server builds (`build.sh`/`build-multi-arch.sh`, no `--pull`) reuse a stale local `chrome-vnc:latest` | Rebuilt image could silently keep 1.4.0 | Delivery: `docker pull` base first; CI runners resolve fresh (RUN-013) | Mitigated by guidance |
| RSK-005 | Risk | Future Ubuntu update makes a required package hard-depend on `gnome-keyring` | Purge would remove it | Image checks assert `chromium`/`xfce4-session` present; escalation trigger | Monitor |
| UNK-001 | Unknown | Exact internal reason navigation blocks while prompt is pending | Explanation completeness only | Not needed for the fix; observed behavior is sufficient | Accepted |

## Requirement Implications

- The dialog is not cosmetic: it blocks agent navigation → fix is required at the image level so every node (default/zh, amd64/arm64) works unattended.
- The single trigger is Chromium's keyring usage; disabling it via Chromium's supported `basic` store is sufficient and verified (RUN-004).
- Built-in key protection is a security-posture change that needs explicit user acceptance.
- Keyring-held v11 data (only where an operator typed a password) becomes unreadable → one-time re-login acceptable?

## Notes For Architecture Design

- Verify the flag reaches every `/usr/bin/chromium` launch path (supervisor, `xdg-open`/`chromium.desktop`, XFCE menu) — `/etc/chromium.d` drop-in is the candidate single owner; `start-chrome.sh` alone is insufficient.
- Keep the Chromium DevTools contract (9222/9223), `--no-sandbox` mobile-safe profile, and profile-lock recovery unchanged.
- Add a durable image/runtime validation assertion (no Secret Service activation by Chromium, no gcr-prompter after navigation).
- Release: browser image `1.4.1` (default + zh; amd64 + arm64), then rebuild server images.
