# Handoff Summary

## Current Delivery State

- Ticket: `BRD-KEYRING-PROMPT-001` — AutoByteus nodes must never block on the GNOME "Choose password for new keyring" dialog
- Current delivery revision: `DR-001`
- Classification (unchanged by Delivery): `task_size=Small`, `architectural_risk=Low`; route: direct low-risk (Solution Designer → Implementation → API/E2E → Delivery). Architecture review, code review, and API/E2E test-code review: `N/A — not applicable`.
- Repository / worktree: `browser_docker`, `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt`, branch `codex/chromium-keyring-prompt`
- Integrated state for verification: HEAD `a42873867a21b43f92c81ef60a6059e18631f464` (source commit `6d4aa757b16279449e5c7e2b3ca198789b0f9deb`) on top of `origin/main` `4d03f29a46d6d7cf96649718731efe25bef335ab`, plus uncommitted ticket artifacts (API/E2E reports and evidence, delivery artifacts, release notes).
- Integration refresh: `origin/main` refetched 2026-09-25T05:40Z, still `4d03f29` (the bootstrap base). Branch 2 ahead / 0 behind → `Already current`; no merge/rebase; no checkpoint commit needed. Delivery smoke on HEAD: `validate-source-contract.sh` PASS, `validate-build-wrapper.sh` PASS, source `git diff --check` clean (`evidence/delivery-dr001-integration-refresh.log`).
- User verification: **Received** 2026-09-25 — "i thjink its already verified. so finalize and release" (reply to the DR-001 handoff, which listed the full AC-006 plan including `autobyteus-docker upgrade --all` re-creating all 7 nodes). Finalization and release are in progress (`DR-002`).
- The user's primary checkout `/Users/normy/autobyteus_org/browser_docker` is untouched.

## What Changed (source commit `6d4aa75`, 8 files, +182/−9)

- `Dockerfile`: layer 2 purges `gnome-keyring` and `libpam-gnome-keyring` right before `apt-get clean` (apt also removes `evolution-data-server`); COPYs `chromium.d/autobyteus-password-store` → `/etc/chromium.d/autobyteus-password-store` (`dos2unix`, `0644`, root-owned).
- `chromium.d/autobyteus-password-store` (new): `export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --password-store=basic"`; sourced by `/usr/bin/chromium` for supervisor, `xdg-open`/server bridge, and desktop launches.
- `VERSION`: `1.4.1`. `README.md`: Features bullet + "No OS keyring" section.
- `tests/validate-{source-contract,image,running-container,build-wrapper}.sh`: no-keyring invariant asserted at source, image, and runtime level; wrapper test reads `VERSION`.

## Validation Evidence (API-REV-001 Pass, 95.1%)

- 5 clean `--no-cache` builds from a `git archive` of `6d4aa75`: arm64 default / zh / UID 1234, amd64 default / zh. Each purge removed exactly `evolution-data-server`, `gnome-keyring`, `libpam-gnome-keyring`. No design escalation trigger fired.
- `validate-source-contract`, `validate-build-wrapper`, `validate-image` ×5, `validate-running-container` ×5: all PASS. Http navigation 47–1484 ms (limit 30 s); `vncuser` Secret Service request → `ServiceUnknown` in 7–397 ms (limit 2 s).
- 15/15 source-contract mutations caught; every new image/runtime assertion fails on its own against unfixed `autobyteus/chrome-vnc:1.4.0`.
- AC-003 launch paths on 4 targets: real superrepo `open-vnc-browser-url.sh` bridge (warm + cold), cold `exo-open --launch WebBrowser`, cold `gtk-launch chromium` → every new Chromium main process carries `--password-store=basic`; pages render unattended in 0–6 s.
- Real sites (Wikipedia, example.com, github.com) load in 0.2–4.8 s; cookie store works without a keyring.
- Operator view (X11 enumeration + screenshots, 4 targets): no dialog; D-Bus audit shows no secrets / portal Secret / keyring-prompter activation. The 1.4.0 control screenshot shows the exact dialog.
- Real keyring clients (libsecret) fail fast as `vncuser` and root; on 1.4.0 the same `vncuser` store hangs.
- AC-005 upgrades: 1.3.8 → 1.4.0 (dialog pending) → fixed keeps the old cookie readable; typed-keyring 1.4.0 → fixed shows no dialog and drops only the keyring-encrypted cookie (approved one-time re-login).
- Lifecycle (Supervisor restart, SIGKILL + `docker start`, graceful restart, mobile-safe) and downstream replay (server runtime-stage `apt-get install --no-install-recommends git ripgrep` on the fixed base re-adds nothing) pass.
- Residual (non-blocking): amd64 validated under Rosetta emulation only (real amd64 packages/binaries; ≥ 5× timing margin). Informational/out of scope: `gcr` + `pinentry-gnome3` remain (GPG passphrase prompt possible only with a passphrase-protected GPG key; never observed).

## What To Verify (suggested)

1. Review the change: `git -C /Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt show 6d4aa75`.
2. Optional hands-on check on a locally built image (does not touch your `latest`/`zh` tags):
   `cd /Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt && docker buildx build --load -t autobyteus/chrome-vnc:verify-keyring . && ./run-container.sh --tag verify-keyring --name verify-keyring --vnc-port 5999 --debug-port 9299 --profile-volume verify-keyring-profile`
   then open VNC `localhost:5999` and browse a site — no keyring dialog should appear. Optionally `tests/validate-running-container.sh verify-keyring default`. Remove afterwards with `docker rm -f verify-keyring && docker volume rm verify-keyring-profile && docker rmi autobyteus/chrome-vnc:verify-keyring`.
3. Review evidence screenshots: `requirements/chromium-keyring-prompt/evidence/api-e2e-rev001-operator-view-*.png` (fixed) vs `api-e2e-rev001-negative-control-1.4.0-operator-view.png` (1.4.0 dialog).

## What Happens After Your Verification (AC-006 plan)

1. Archive release notes `tickets/in-progress/chromium-keyring-prompt/` → `tickets/done/chromium-keyring-prompt/`; commit ticket artifacts; push `codex/chromium-keyring-prompt`; refresh `origin/main`; merge (fast-forward expected) and push `main`.
2. Publish the base from `main`: `./build-multi-arch.sh --push` → `1.4.1` + `latest`; `./build-multi-arch.sh --variant zh --push` → `1.4.1-zh` + `zh` (amd64 + arm64). Verify manifests, record digests, pull/run each platform child digest and re-run the image/runtime contract on the published images.
3. Re-publish the unchanged AutoByteus server images on the new base (DEC-005): `gh workflow run release-server-docker.yml --repo AutoByteus/autobyteus-workspace -f release_tag=<latest published v* tag>` (currently **`v1.4.80`**, re-resolved at release time), then again with `-f publish_zh=true`. No new `v*` tag. This overwrites `autobyteus-server:1.4.80`/`latest` and creates `1.4.80-zh`/`latest-zh` with identical server code on the new base. Verify AC-001/002/007 on throwaway containers of the published server images (default + zh), including the server bridge.
4. Operator nodes: `autobyteus-docker upgrade --all`. **This pulls and re-creates all 7 managed nodes** (`autobyteus-server-0..6`; named volumes kept), interrupting any agent work running in them. Six nodes follow `latest` (now `1.4.78` server code → `1.4.80`); `autobyteus-server-3` follows `latest-zh` (now `1.4.66-zh` → `1.4.80-zh`, a larger server-code jump). Nodes where a keyring password was typed (e.g. `autobyteus-server-0`) may need one re-login on affected sites. Spot-check one node for no dialog.
5. Clean up: remove verification containers/images and the `impl-keyring-*` task images, remove this worktree and the local/remote ticket branch after `main` holds the final records.

## Rollback Visibility

- Base: `1.4.0`/`latest` `sha256:cb49a54d8e745a45351ecab1e5f47db0eee71b30ab2e15e8c3745b91f2941af1`; `1.4.0-zh`/`zh` `sha256:597c8702e0a2418078aca64a7f4bc19e2a26af277af119a893d51a9215837c48`.
- Server (pre-re-publish): `1.4.80`/`latest` `sha256:08ca936169d8862f826558b8a112c51d2b02fef09be642fd4103e96a0f382414`; `latest-zh` = `1.4.66-zh` `sha256:d0b43e3eca7c5e2fd3a1cca4c3a3127a20f05208fa636b67e9324d4f58711dc5`. Operator nodes currently run `latest` = `1.4.78` (`sha256:1acd3167b4ae01b83d07f9b9be2e35cad0727713e716a6ea5d3a2d2f0b6ff791`) and `latest-zh` (`d0b43e3e…`).

## Authoritative Artifact Package (absolute paths)

- Requirements (Approved SR-004): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/requirements-doc.md`
- Investigation notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/investigation-notes.md`
- Solution revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/solution-revision-record.md`
- Design spec (SR-005): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/design-spec.md`
- Design handoff: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/handoff-architecture-design-complete.md`
- Implementation handoff / revision record (IR-001): `.../implementation-handoff.md`, `.../implementation-revision-record.md`
- API/E2E (API-REV-001): `.../api-e2e-coverage-investigation.md`, `.../api-e2e-execution-coverage-report.md`, `.../api-e2e-revision-record.md`, `.../api-e2e-test-case-ledger.md`
- Delivery: `.../docs-sync-report.md`, `.../handoff-summary.md`, `.../release-deployment-report.md`, `.../delivery-revision-record.md`
- Release notes (archived): `tickets/done/chromium-keyring-prompt/release-notes.md`
- Evidence: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/evidence/`
- Architecture review, code review, API/E2E test-code review: `N/A — not applicable` (Small/Low direct route)
