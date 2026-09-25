# Handoff Summary

## Current Delivery State

- Ticket: `BRD-KEYRING-PROMPT-001` — AutoByteus nodes must never block on the GNOME "Choose password for new keyring" dialog
- Current delivery revision: `DR-002`
- Classification (unchanged by Delivery): `task_size=Small`, `architectural_risk=Low`; route: direct low-risk (Solution Designer → Implementation → API/E2E → Delivery). Architecture review, code review, and API/E2E test-code review: `N/A — not applicable`.
- User verification: received 2026-09-25 — "i thjink its already verified. so finalize and release" (reply to the DR-001 handoff, which listed the full AC-006 plan including re-creating all 7 nodes).
- Repository finalization: `main` fast-forwarded `4d03f29..6e02d7e` and pushed (remote verified) before publication; delivery records follow on `main`.
- Release: base `1.4.1`/`latest` and `1.4.1-zh`/`zh` (amd64 + arm64) published and verified; AutoByteus server `1.4.80`/`latest` and `1.4.80-zh`/`latest-zh` re-published on the new base and verified; all 7 operator nodes upgraded and verified.
- Cleanup: ticket worktree removed, local and remote ticket branch deleted, task/verification images removed.
- Terminal classification: `Delivery Completed`.

## What Changed (source commit `6d4aa75`, 8 files, +182/−9)

- `Dockerfile`: layer 2 purges `gnome-keyring` and `libpam-gnome-keyring` right before `apt-get clean` (apt also removes `evolution-data-server`); COPYs `chromium.d/autobyteus-password-store` → `/etc/chromium.d/autobyteus-password-store` (`dos2unix`, `0644`, root-owned).
- `chromium.d/autobyteus-password-store` (new): `export CHROMIUM_FLAGS="$CHROMIUM_FLAGS --password-store=basic"`; sourced by `/usr/bin/chromium` for supervisor, `xdg-open`/server bridge, and desktop launches.
- `VERSION`: `1.4.1`. `README.md`: Features bullet + "No OS keyring" section.
- `tests/validate-{source-contract,image,running-container,build-wrapper}.sh`: no-keyring invariant asserted at source, image, and runtime level; wrapper test reads `VERSION`.

## Published Identities

| Image | Tags | Index digest |
| --- | --- | --- |
| `autobyteus/chrome-vnc` | `1.4.1`, `latest` | `sha256:b2fde77f3bd7c73d412ea59d42e3b65290bae9f39d1ce85b5aaaac5d869596f4` |
| `autobyteus/chrome-vnc` | `1.4.1-zh`, `zh` | `sha256:19d4c0164e5c7006e38a81c0260611cbf26f871f2d3e749d574016676f4f9a67` |
| `autobyteus/autobyteus-server` | `1.4.80`, `latest` | `sha256:f42018efc2253507575034001b477f108c4a166ff3bd1769d662c47e8d78cfb7` |
| `autobyteus/autobyteus-server` | `1.4.80-zh`, `latest-zh` | `sha256:dc3efc572f201984cb34779671c69d8c137e475b1b509bedbddd4645d739aa01` |

Platform child digests, workflow runs, and build provenance are in `release-deployment-report.md` and `tickets/done/chromium-keyring-prompt/release-notes.md`.

## Validation Evidence

- Pre-release (API-REV-001 Pass, 95.1%): 5 clean builds, full source/image/runtime suites, 15/15 mutations caught, negative control on 1.4.0, all launch paths, real sites, operator view, real keyring clients, both upgrade shapes, lifecycle, downstream replay. Residual: amd64 under Rosetta emulation only.
- Published base, 4 exact child digests: `validate-image.sh` + `validate-running-container.sh` PASS; http nav 45–1159 ms; Secret Service `ServiceUnknown` in 6–195 ms.
- Published server, 4 exact child digests: 28 PASS / 0 FAIL each — runtime contract, server process running, all 4 launch paths incl. the shipped server bridge, operator view, libsecret clients.
- Upgraded nodes, 7/7 PASS (read-only): flag on Chromium, no keyring packages/processes/activation, Secret Service fail-fast 4–15 ms, server GraphQL 200. Operator view on `autobyteus-server-0` (previously typed keyring) and `-3` (zh): no keyring window.

## Follow-Ups / Notes

- "Restore pages? Chromium didn't shut down correctly" bubble is visible after node re-creation — separate ticket (DEC-004), out of scope here.
- Sites whose cookies were keyring-encrypted on `autobyteus-server-0` may need one re-login (approved DEC-003).
- Informational, out of approved scope: `gcr` + `pinentry-gnome3` remain (GPG passphrase prompt possible only with a passphrase-protected GPG key; never observed).
- Optional durable-test improvements suggested by API/E2E (not required): extend the runtime D-Bus audit to prompter/portal-Secret activations; add a cold `xdg-open` launch to the runtime script.

## Rollback Visibility

- Base: `1.4.0` `sha256:cb49a54d8e745a45351ecab1e5f47db0eee71b30ab2e15e8c3745b91f2941af1`; `1.4.0-zh` `sha256:597c8702e0a2418078aca64a7f4bc19e2a26af277af119a893d51a9215837c48`.
- Server (pre-re-publish): `1.4.80`/`latest` `sha256:08ca936169d8862f826558b8a112c51d2b02fef09be642fd4103e96a0f382414`; `latest-zh` = `1.4.66-zh` `sha256:d0b43e3eca7c5e2fd3a1cca4c3a3127a20f05208fa636b67e9324d4f58711dc5`; nodes previously on `1.4.78` `sha256:1acd3167b4ae01b83d07f9b9be2e35cad0727713e716a6ea5d3a2d2f0b6ff791`.

## Authoritative Artifact Package (on `main`; local checkout `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base-main-finalize`)

- Requirements (Approved SR-004): `requirements/chromium-keyring-prompt/requirements-doc.md`
- Investigation notes: `requirements/chromium-keyring-prompt/investigation-notes.md`
- Solution revision record: `requirements/chromium-keyring-prompt/solution-revision-record.md`
- Design spec (SR-005): `requirements/chromium-keyring-prompt/design-spec.md`
- Design handoff: `requirements/chromium-keyring-prompt/handoff-architecture-design-complete.md`
- Implementation handoff / revision record (IR-001): `requirements/chromium-keyring-prompt/implementation-handoff.md`, `implementation-revision-record.md`
- API/E2E (API-REV-001): `api-e2e-coverage-investigation.md`, `api-e2e-execution-coverage-report.md`, `api-e2e-revision-record.md`, `api-e2e-test-case-ledger.md`
- Delivery: `docs-sync-report.md`, `handoff-summary.md`, `release-deployment-report.md`, `delivery-revision-record.md`
- Release notes: `tickets/done/chromium-keyring-prompt/release-notes.md`
- Evidence: `requirements/chromium-keyring-prompt/evidence/` (`delivery-dr001-*`, `delivery-dr002-*`, `delivery-dr002-harness/`)
- Architecture review, code review, API/E2E test-code review: `N/A — not applicable` (Small/Low direct route)
