# Implementation Revision Record

The current code (branch `codex/chromium-keyring-prompt`, source commit `6d4aa757b16279449e5c7e2b3ca198789b0f9deb`) and `implementation-handoff.md` are authoritative. This record only locates each implementation round.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Finding IDs | Classification | Related Revision IDs | Result |
| --- | --- | --- | --- | --- | --- |
| IR-001 | Solution Designer, `handoff-architecture-design-complete.md` (SR-005), initial implementation | N/A | `Initial Baseline` | `SR-005` (requirements `SR-004`); ARCH-REV `N/A`; CRR `N/A`; API-REV `N/A`; DR `N/A` | Implemented design steps 1–3; all local checks pass on default, zh and custom UID (arm64 native, amd64 emulated); new checks fail on the 1.4.0 negative control; ready for direct API/E2E |

## Revision Entries

### IR-001 — No OS keyring: purge the provider and set Chromium to the basic password store

- Triggering role, report path, and round: Solution Designer, `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/handoff-architecture-design-complete.md`, initial implementation round.
- Triggering finding IDs: N/A
- Classification: `Initial Baseline`
- Prior authoritative result: N/A
- Current authoritative result: Implementation complete at source commit `6d4aa75`; classification confirmed `Small` / `Low`; direct API/E2E route.
- Related solution revision IDs: `SR-005` (design), `SR-004` (approved requirements)
- Related architecture-review revision IDs: N/A (Small/Low direct route)
- Related code-review revision IDs: N/A
- Related API/E2E revision IDs: N/A
- Related delivery revision IDs: N/A
- Why this baseline is recorded: First implementation of the approved `BRD-KEYRING-PROMPT-001` design.
- Approved behavior or requirement IDs affected: BEH-001..005; REQ-001..004 and REQ-006 (REQ-005 release is delivery-owned); AC-001..005, AC-007, AC-008 (AC-006 delivery-owned).
- Implementation delta:
  - `Dockerfile`: `apt-get purge -y gnome-keyring libpam-gnome-keyring` placed right before `apt-get clean` in layer 2 (after the zh block); COPY of the drop-in to `/etc/chromium.d/autobyteus-password-store`, added to the `dos2unix` list, `chmod 0644`, root-owned (not added to the `chmod +x` or `chown vncuser` lists).
  - `chromium.d/autobyteus-password-store` (new): comments plus `export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --password-store=basic"`.
  - `VERSION`: `1.4.1`. `README.md`: Features bullet and "No OS keyring" section.
  - Tests: `validate-source-contract.sh` (VERSION 1.4.1 replaces 1.4.0; purge placement; COPY/dos2unix/chmod; drop-in content; `--password-store` nowhere else; `start-chrome.sh` still execs `/usr/bin/chromium`; README posture), `validate-image.sh` (keyring packages absent, `chromium`/`xfce4-session` present, Secret Service D-Bus service files absent, drop-in owner/mode/effect, wrapper exec trace carries the flag, desktop/xdg-open/x-www-browser route through `/usr/bin/chromium`), `validate-running-container.sh` (main Chromium process carries the flag; DevTools `http://127.0.0.1:6080/` renders within 30 s; afterwards no `gcr-prompter`/`gnome-keyring-daemon`, no `org.freedesktop.secrets` activation, `vncuser` Secret Service request fails with ServiceUnknown in ≤ 2 s).
  - `validate-build-wrapper.sh`: expected BuildX tags are now built from `VERSION` instead of the hard-coded `1.4.0`, which the version bump had made stale. The design expected this script to pass unchanged; see handoff "Deviations".
- Changed files or areas: `Dockerfile`, `chromium.d/autobyteus-password-store`, `VERSION`, `README.md`, `tests/validate-source-contract.sh`, `tests/validate-image.sh`, `tests/validate-running-container.sh`, `tests/validate-build-wrapper.sh`.
- Local validation and result: Source contract and build-wrapper PASS (with mutation checks); builds succeed for arm64 default/zh/custom-UID 1234 and amd64 default/zh, and the purge removes exactly `evolution-data-server`, `gnome-keyring`, `libpam-gnome-keyring` on all five; `validate-image.sh` PASS on all five; `validate-running-container.sh` PASS on all five with the final script; negative control on `autobyteus/chrome-vnc:1.4.0`: every new image and runtime assertion fails on its own. Supplementary: cold `xdg-open` launch carries the flag, bridge hand-off loads, and reusing a 1.4.0 profile volume passes. Evidence: `requirements/chromium-keyring-prompt/evidence/implementation-ir001-*.log`.
- Next recipient or routing: `/api_e2e_engineer` (rule: implementation complete, Small/Medium + Low, self-review complete).
- Remaining limitations or risks: amd64 validated only under Rosetta emulation on the arm64 host. Nothing was published (delivery-owned). Informational: `gcr` and `pinentry-gnome3` remain (GPG passphrase prompts, not a Secret Service provider; outside the approved scope). Chromium is now 153 (the investigation used 151); the flag was verified at runtime on 153.
