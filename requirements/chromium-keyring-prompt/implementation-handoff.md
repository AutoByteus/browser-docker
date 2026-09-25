# Implementation Handoff

- Package: `BRD-KEYRING-PROMPT-001` — AutoByteus nodes must never block on the GNOME "Choose password for new keyring" dialog
- Repository / worktree: `browser_docker`, `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt`
- Branch / base: `codex/chromium-keyring-prompt` / `origin/main` @ `4d03f29a46d6d7cf96649718731efe25bef335ab` (VERSION 1.4.0)
- Source commit: `6d4aa757b16279449e5c7e2b3ca198789b0f9deb` (`fix(image): stop the keyring dialog from blocking agent Chromium`, author Ryan Zheng). Local only, not pushed; nothing published.
- Date: 2026-09-25

## Upstream Artifact Package

- Upstream review applicability and handoff-rule result: `task_size=Small`, `architectural_risk=Low` → direct implementation (independent architecture review not selected); Solution Designer route record in `handoff-architecture-design-complete.md`.
- Requirements doc (Approved, SR-004): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/requirements-doc.md`
- Investigation notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/investigation-notes.md`
- Solution revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/solution-revision-record.md`
- Design spec (Ready, SR-005): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/design-spec.md`
- Solution Designer handoff: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/handoff-architecture-design-complete.md`
- Supplemental task artifacts (evidence only): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/evidence/` (`user-report-keyring-prompt.png`, `probe-a/b/c-*.png`, `probe-chromium-d-dropin.txt`)
- Design review report: `N/A — not applicable` (Small/Low direct route)
- Architecture review revision record: `N/A — not applicable` (Small/Low direct route)
- Triggering rework report, revision record, or evidence: N/A (initial implementation)

## Current Implementation Summary

The base image no longer ships an interactive Secret Service provider, and every Chromium launch uses Chromium's built-in (`basic`) password store:

1. `Dockerfile` layer 2 purges `gnome-keyring` and `libpam-gnome-keyring` right before `apt-get clean`. apt also removes `evolution-data-server`, which hard-depends on `gnome-keyring`. That is the expected, approved set.
2. New `chromium.d/autobyteus-password-store` is copied to `/etc/chromium.d/autobyteus-password-store` (dos2unix, `0644`, root-owned). The distribution wrapper `/usr/bin/chromium` sources it for supervisor, `xdg-open`/bridge and desktop launches and appends `--password-store=basic`.
3. The invariant is asserted in the existing validation scripts, documented in `README.md`, and `VERSION` is `1.4.1`.

- Implementation cycle: `Initial`
- Implementation revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/implementation-revision-record.md`
- Current implementation revision ID: `IR-001`
- Related solution revision IDs: `SR-005` (design), `SR-004` (approved requirements)
- Related architecture-review revision IDs: `N/A`
- Related code-review revision IDs: `N/A`
- Related API/E2E revision IDs: `N/A`
- Related delivery revision IDs: `N/A`
- Triggering finding IDs: `N/A`

## Routing Classification (Mandatory)

- Task size: `Small`
- Architecture risk: `Low`
- Design classification section / evidence reference: `design-spec.md` → "Task Size And Architectural Risk (Mandatory)"
- Classification confirmed or changed: `Confirmed`
- Evidence and rationale for confirmation or change: The change stayed within the designed owners: 8 files, +182/−9. The Dockerfile has one purge line plus COPY/dos2unix/chmod, there is one 4-line drop-in, and the rest is VERSION, README and assertions in the existing test scripts. No new runtime owner, API, schema, concurrency or boundary change. None of the four escalation triggers fired. (a) The purge removed exactly `evolution-data-server`, `gnome-keyring`, `libpam-gnome-keyring` on arm64 default/zh/custom-UID and amd64 default/zh. (b) Every existing check still passes. The one stale `1.4.0` tag literal in `validate-build-wrapper.sh` was test data coupled to `VERSION`, not a behavior regression; see Deviations. (c) There was no `org.freedesktop.secrets` activation with the flag present, and no portal Secret provider exists. (d) The xtradeb wrapper still sources `/etc/chromium.d/*`, proven by the image-level `sh -x` exec trace.
- Selected route: `Direct API/E2E`
- Lightweight implementation self-review completed for the direct route: `Yes` (see below)
- New design impact or escalation trigger: `None`

### Lightweight Implementation Self-Review

- Design conformance:
  - Purge sits inside the existing layer-2 RUN, after the zh block and before `apt-get clean`. There is no `autoremove` and no global `--no-install-recommends`.
  - The drop-in is POSIX and holds only comments plus the single `export` line. It is CRLF-safe via `dos2unix` and is not executable or vncuser-owned.
  - `start-chrome.sh`, `base.conf`, `entrypoint.sh`, ports, supervisor programs and profile-lock logic are unchanged.
- Single policy owner: `--password-store` appears nowhere else. This is asserted in both the source contract and the image contract (`/etc/chromium.d`).
- Version contract: the obsolete `VERSION must be 1.4.0` check was updated rather than duplicated. The duplicate hard-coded tag in the build-wrapper test was replaced by reading `VERSION`.
- Test quality:
  - Every new assertion was mutation-checked. The source contract caught 9 of 9 injected defects.
  - The new image and runtime assertions each fail on their own against the unfixed `autobyteus/chrome-vnc:1.4.0`.
  - The runtime assertions are robust to Chromium's rewritten process title and to Rosetta's prefixed command line (both observed; see Environment notes).
- No compatibility switches, legacy paths or dead code were introduced. Shell lint (`bash -n`, `shellcheck -S warning`) is clean, and the embedded Node probe passes `node --check`.

## Reviewed Behavior Implementation Trace

| Behavior ID | Approved Change / Preserved Outcome | Implemented Production Path / Key Files | Result / Notes |
| --- | --- | --- | --- |
| BEH-001 (REQ-001/003/004, AC-001/003/004) | No keyring dialog at Chromium start; Chromium on built-in key; other startup behavior preserved | supervisord `chrome` → `start-chrome.sh` (unchanged) → `/usr/bin/chromium` sources `/etc/chromium.d/autobyteus-password-store` → `/usr/lib/chromium/chromium --password-store=basic …` | Main process carries the flag on all 5 targets; no `gcr-prompter`/`gnome-keyring-daemon`; no `org.freedesktop.secrets` activation; all preserved checks (Supervisor, DevTools 9222/9223, VNC, noVNC, profile write, fcitx in zh) pass. `Local State` has no `os_crypt` keyring entry; Cookies DB written |
| BEH-002 (REQ-002, AC-002/003) | Navigation completes unattended | DevTools `Page.navigate http://127.0.0.1:6080/` → title `Directory listing for /` | Loads in 46–100 ms natively, ~1.1 s under amd64 emulation (limit 30 s). Supplementary: `xdg-open` bridge hand-off loads; a cold `xdg-open` launch (supervisor Chromium stopped) runs through `chromium.desktop` → `/usr/bin/chromium` and carries the flag |
| BEH-003 (REQ-004, AC-005) | No keyring on upgrade; one-time re-login only where a keyring was typed | Profile volume read directly (`Directly Usable — No Migration`) | Supplementary: a volume used by 1.4.0 (dialog left pending) reused by the fixed image passes the full runtime contract; stale-lock recovery still triggers. The typed-keyring re-login case is documented in README, not reproduced |
| BEH-004 (REQ-006, AC-008) | Keyring provider not shipped | `Dockerfile` layer 2 `apt-get purge -y gnome-keyring libpam-gnome-keyring` | Not installed on all 5 builds; no `org.freedesktop.secrets` / `org.freedesktop.impl.portal.Secret` / `org.gnome.keyring` service files; `chromium`, `xfce4`, `xfce4-session`, `network-manager-gnome`, `gvfs-backends` still installed |
| BEH-005 (REQ-006, AC-007) | Any keyring request fails immediately | No Secret Service provider on the session bus | `vncuser` `dbus-send … org.freedesktop.secrets … Peer.Ping` → `ServiceUnknown … not provided by any .service files` in 9–62 ms natively, ~220 ms emulated (limit 2 s) |
| — (REQ-005, AC-006) | Release 1.4.1, server re-publish, node upgrade | Delivery-owned (design step 4, DEC-005) | Not performed. `VERSION` is 1.4.1 so `build-multi-arch.sh` tags `1.4.1`/`latest` and `1.4.1-zh`/`zh` |

## Key Files Or Areas

- `Dockerfile`: purge line (layer 2), `COPY chromium.d/autobyteus-password-store /etc/chromium.d/autobyteus-password-store`, dos2unix list, `chmod 0644`.
- `chromium.d/autobyteus-password-store` (new): sole owner of Chromium's password-store policy.
- `VERSION`: `1.4.1`.
- `README.md`: Features bullet; "No OS keyring" section (provider purged incl. e-d-s; drop-in and flag on all launch paths; built-in key is obfuscation and the profile volume is sensitive; keyring-using tools fail fast and use file fallbacks; 1.4.0 upgrade may need one re-login where a keyring was typed; downstream images must not re-configure the password store).
- `tests/validate-source-contract.sh`: VERSION 1.4.1; purge directly precedes `apt-get clean`; COPY/dos2unix/chmod; drop-in content exact; drop-in not executable/vncuser-owned; `--password-store` absent from `Dockerfile`, `start-chrome.sh`, `base.conf`, `entrypoint.sh`, `supervisord.conf`, `start-vnc.sh`; `start-chrome.sh` execs `/usr/bin/chromium`; README posture.
- `tests/validate-image.sh`: keyring packages absent; `chromium`/`xfce4-session` present; Secret Service service files absent (named files and any `Name=org.freedesktop.secrets`); drop-in `root:root 644` and yields ` --password-store=basic`; no other `/etc/chromium.d` file sets `--password-store`; `sh -x /usr/bin/chromium --version` as `vncuser` execs Chromium with the flag; `chromium.desktop` `Exec=/usr/bin/chromium %U`; `xdg-mime` http default `chromium.desktop`; `x-www-browser` → `/usr/bin/chromium`.
- `tests/validate-running-container.sh`: main Chromium process carries the flag; DevTools probe extended to `http://127.0.0.1:6080/` within 30 s; new post-navigation block: no keyring processes, no activation line in `/var/log/supervisor/dbus.err.log`, fail-fast `vncuser` Secret Service request ≤ 2 s.
- `tests/validate-build-wrapper.sh`: expected tags derived from `VERSION`.

## Deviations From The Design Text (All Implementation-Scoped)

- `validate-build-wrapper.sh` changed. The design said it would pass "unchanged", but it hard-coded the `1.4.0` tags, which the approved VERSION bump made stale. It now reads `VERSION`, so the wrapper is still checked for tagging whatever `VERSION` declares. Mutation checks: a wrapper hard-coding `9.9.9` fails, and `VERSION=2.0.0` passes. The release version stays pinned exactly once, in `validate-source-contract.sh`, following the design's "update the obsolete version contract rather than adding a second version check". This does not change behavior.
- Assertions were added beyond the design's list, each backing an existing AC or design dependency rule:
  - the image-level wrapper exec trace (AC-003 / escalation trigger d)
  - desktop/xdg-open/x-www-browser routing through `/usr/bin/chromium` (AC-003)
  - `start-chrome.sh` still execs `/usr/bin/chromium` (Dependency Rules)
  - no competing `--password-store` inside `/etc/chromium.d`

## Important Assumptions

- The apt package graph at build time is the one observed on 2026-09-25 (`ubuntu:24.04@sha256:008173c2…`, Ubuntu 24.04.5, xtradeb Chromium 153.0.8010.52). A later graph change that removes more packages would show in the build log's `The following packages will be REMOVED` line and in the `chromium`/`xfce4-session` image assertion.
- `http://127.0.0.1:6080/` (websockify directory listing) is a valid no-internet stand-in for "an http page". The 1.4.0 control shows it is blocked by the pending dialog exactly like the investigation's Wikipedia probe.

## Known Risks

- RSK-001 (accepted): built-in cookie key is obfuscation only; README flags the profile volume as sensitive.
- RSK-004 (delivery): local server builds reuse a stale `autobyteus/chrome-vnc:latest`/`zh`. On this host they are still ~2-month-old images, so `docker pull` first.
- RSK-005: a future hard dependency on `gnome-keyring` would be purged. The image assertions on `chromium`/`xfce4-session` plus the build-log removal list catch it.
- Observation (out of approved scope, informational): `gcr` (prompter D-Bus services) and `pinentry-gnome3` remain. They can show a GPG *passphrase* prompt if something uses a passphrase-protected GPG key. That is not a Secret Service provider, and it predates this change. `evolution-data-server-common` leaves `org.gnome.evolution.dataserver.UserPrompter0.service`, which points at the removed `/usr/libexec/evolution-user-prompter`, so it is inert.

## Task Design Health Assessment Implementation Check

- Reviewed change posture: `Bug Fix`
- Reviewed root-cause classification: `Missing Invariant`
- Reviewed refactor decision: `No Refactor Needed`
- Implementation matched the reviewed assessment: `Yes`
- If challenged, routed as `Design Impact`: `N/A`
- Evidence / notes: The invariant now lives in its two owners (package set in `Dockerfile`; launch policy in the `/etc/chromium.d` drop-in) and is asserted in the existing source/image/runtime contracts. No owner or file-placement issue surfaced.

## Legacy / Compatibility Removal Check

- Backward-compatibility mechanisms introduced: `None` (no opt-in to keep a keyring, no migration of keyring-encrypted cookies, no APT pin)
- Legacy old-behavior retained in scope: `No`
- Dead/obsolete code, obsolete files, unused helpers/tests/flags/adapters, and dormant replaced paths removed in scope: `Yes` (keyring packages purged; obsolete `1.4.0` version pins replaced)
- Shared structures remain tight: `Yes` (no shared structures involved)
- Canonical shared design guidance was reapplied during implementation, and file-level design weaknesses were routed upstream when needed: `Yes` (none found)
- Changed source implementation files stayed within proactive size-pressure guardrails: `Yes` (`Dockerfile` ~230 lines, +9/−2; drop-in 4 lines; test files are outside the hard limit)
- Notes: —

## Persisted Data Transition Check (When Applicable)

- Approved decision: `Directly Usable — No Migration` for the Chromium profile volume; keyring-encrypted values `Discard or Rebuild` (one re-login, DEC-003)
- Design-spec decision reference: `design-spec.md` → "Persisted Data / State Transition Decision"
- Implementation follows the approved decision without an unapproved migration or version-specific runtime fallback: `Yes`
- Direct-use evidence or discard/rebuild result, when applicable: a 1.4.0-used profile volume was reused by the fixed image and the full runtime contract passed (`implementation-ir001-upgrade-volume-arm64-default.log`).
- Migration implementation and focused checks, only when `Migration Required`: N/A
- Deviation from the reviewed transition decision: `None`

## Environment Or Dependency Notes

- Host: Apple Silicon (arm64), Docker 29.0.1, BuildX builder `multi-platform-builder`. linux/amd64 images ran under Docker Desktop Rosetta emulation.
- Images were built with direct `docker buildx build --load` using task-local tags `autobyteus/chrome-vnc:impl-keyring-{arm64-default,arm64-zh,arm64-custom-1234,amd64-default,amd64-zh}`, so the host's `autobyteus/chrome-vnc:latest`/`zh` tags were not overwritten. Those images are still on the host and can be removed. All task containers and volumes were removed. The user's `autobyteus-server-*` containers were only listed, never modified.
- Observed runtime facts the tests handle:
  - Chromium 153 rewrites its browser process title into one space-joined string, so the `/proc/<pid>/cmdline` argv is no longer NUL-separated.
  - Under Rosetta the command line is prefixed with `/run/rosetta/rosetta`.
  - The runtime script therefore matches space-delimited flags on the unanchored `/usr/lib/chromium/chromium ` process and picks the main process as the one without `--type=`. The first parser attempts failed for exactly these reasons before the fix, as recorded in the evidence logs.
- Chromium moved from 151 (investigation) to 153 (xtradeb) since the design probes. `--password-store=basic` behaves as designed on 153 (no Secret Service activation).

## Local Implementation Checks Run

All evidence is under `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/evidence/`. Final script hashes are recorded in `implementation-ir001-repository-checks.log`.

| Check | Result | Evidence |
| --- | --- | --- |
| `bash -n` + `shellcheck -S warning` on `tests/*.sh`; `node --check` on the embedded probe; `sh -n` on the drop-in; `git diff --check` | Clean | `implementation-ir001-repository-checks.log` |
| `tests/validate-source-contract.sh` (+ 9 mutation checks, all caught) | PASS | `implementation-ir001-repository-checks.log` (mutations run in a temp copy during development) |
| `tests/validate-build-wrapper.sh` (+ 2 mutations) | PASS after the VERSION-derived fix; failed before it on the stale `1.4.0` literal | `implementation-ir001-repository-checks.log` |
| Builds: arm64 default, zh, custom UID/GID 1234; amd64 default, zh | All `exit=0`; purge removes exactly `evolution-data-server gnome-keyring libpam-gnome-keyring` on every build | `implementation-ir001-build-*.log` |
| `tests/validate-image.sh`: arm64 default, zh, custom 1234; amd64 default, zh | PASS ×5 | `implementation-ir001-image-arm64.log`, `implementation-ir001-custom-uid-1234-arm64.log`, `implementation-ir001-image-runtime-amd64.log` |
| `tests/validate-running-container.sh` (final script): arm64 default, zh, custom 1234; amd64 default, zh | PASS ×5 | `implementation-ir001-runtime-arm64-final-script.log`, `implementation-ir001-image-runtime-amd64.log`, `implementation-ir001-custom-uid-1234-arm64.log` |
| Negative control on `autobyteus/chrome-vnc:1.4.0` (arm64, digest `sha256:cb49a54d…`): full runtime + image scripts, then each new assertion on its own | Every new assertion FAILs (flag, http navigation 30 s timeout, keyring processes, D-Bus activation, Secret Service ping succeeds, and 11 image assertions); preserved routing checks pass | `implementation-ir001-negative-control-1.4.0.log` |
| Supplementary: `xdg-open` hand-off, cold `xdg-open` launch, 1.4.0 → fixed profile-volume reuse | Flag present on cold launch; pages load; no keyring activity | `implementation-ir001-runtime-arm64-default.log`, `implementation-ir001-upgrade-volume-arm64-default.log` |
| Cleanup | Task containers/volumes removed; local `latest`/`zh` untouched | `implementation-ir001-cleanup.log` |

These are implementation-scoped checks. They are not API/E2E sign-off.

## Frontend Rendered-Result Check (When Applicable)

`Not Applicable`: container image and launch configuration only. The VNC desktop change is the *absence* of an OS dialog, which is covered by the runtime assertions above. No product UI surface changed.

## Downstream Coverage Hints / Suggested Scenarios

- Build from source commit `6d4aa75` independently. Run the full suites for default + zh on both arches, custom UID, and the 1.4.0 negative control.
- On a VNC-visible node, confirm visually that no keyring dialog appears after start and after opening a site. The investigation's `probe-a`/`probe-b` screenshots show before/after.
- Open a URL through the AutoByteus server bridge path (`open-vnc-browser-url.sh` → `xdg-open`) on a server image built on the new base. This is delivery's AC-006 check, but the base-level `xdg-open` path is already covered supplementarily here.
- Keyring-client fail-fast from the desktop user with a real tool (e.g., `python3` + `gi.repository.Secret`, or `gh auth login` choosing its file fallback). Investigation probe E is the reference.
- Upgrade on an existing profile volume where a keyring password *was* typed on 1.4.0. Expected: no dialog; affected sites may need one re-login (AC-005, documented only).

## API / E2E / Executable Coverage Investigation And Execution Still Required

- Independent executable validation of AC-001, AC-002, AC-003, AC-004, AC-005, AC-007 and AC-008 on default + zh, amd64 + arm64. Native amd64, if available, would remove the emulation-only limitation.
- AC-006 (publish `1.4.1`/`latest`/`1.4.1-zh`/`zh`, re-publish server images via `workflow_dispatch`, `autobyteus-docker upgrade --all`) remains delivery-owned and was not performed.
