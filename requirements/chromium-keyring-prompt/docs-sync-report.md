# Docs Sync Report

## Scope

- Ticket: `BRD-KEYRING-PROMPT-001` — AutoByteus nodes must never block on the GNOME "Choose password for new keyring" dialog
- Trigger: `api_e2e_engineer` API/E2E Pass (`API-REV-001`, round 1, final confidence 95.1%) on the direct low-risk route (`task_size=Small`, `architectural_risk=Low`)
- Bootstrap base reference: `origin/main` @ `4d03f29a46d6d7cf96649718731efe25bef335ab` (VERSION 1.4.0)
- Integrated base reference used for docs sync: `origin/main` @ `4d03f29a46d6d7cf96649718731efe25bef335ab` (refetched 2026-09-25T05:40Z; unchanged; ticket branch 2 ahead / 0 behind — already current)
- Post-integration verification reference: `requirements/chromium-keyring-prompt/evidence/delivery-dr001-integration-refresh.log` (`validate-source-contract.sh` PASS, `validate-build-wrapper.sh` PASS, source `git diff --check` clean)
- Docs reviewed against: ticket branch `codex/chromium-keyring-prompt` HEAD `a42873867a21b43f92c81ef60a6059e18631f464` (source commit `6d4aa757b16279449e5c7e2b3ca198789b0f9deb`)

## Why Docs Were Updated

- Summary: The implementation commit already carries the long-lived documentation change (README "No OS keyring" section and Features bullet). Delivery verified it line-by-line against the integrated, API/E2E-validated behavior and found it accurate and complete, so no additional README edit was needed. Delivery added the release record for `1.4.1` (`tickets/in-progress/chromium-keyring-prompt/release-notes.md`), following this repository's release-note convention.
- Why this should live in long-lived project docs: The image's no-keyring posture is a consumer-facing contract. Downstream images (AutoByteus server, all-in-one) and operators need to know that no Secret Service provider exists, that Chromium's password store is pinned through `/etc/chromium.d`, that the profile volume is sensitive, and that a one-time re-login may follow an upgrade from 1.4.0.

## Long-Lived Docs Reviewed

| Doc Path | Why It Was Reviewed | Result (`Updated`/`No change`/`Needs follow-up`) | Notes |
| --- | --- | --- | --- |
| `README.md` → Features | New posture bullet | `No change` (already updated in `6d4aa75`) | "No OS keyring: nothing blocks unattended use on a 'Choose password for new keyring' dialog" matches AC-001/002 evidence |
| `README.md` → "No OS keyring" | Canonical description of the invariant | `No change` (already updated in `6d4aa75`) | Each bullet verified against evidence: purge set = exactly `gnome-keyring`, `libpam-gnome-keyring`, `evolution-data-server` (C03 ×5); drop-in path/flag and all launch paths (C04/C07); built-in key is obfuscation + profile sensitive (RSK-001, approved); fail-fast "not provided by any .service files" (C10); 1.4.0 upgrade re-login (C11b); downstream must not reconfigure (design Dependency Rules) |
| `README.md` → Building / zh / Verifying multi-arch | Release commands used for AC-006 | `No change` | `VERSION` = `1.4.1`; `./build-multi-arch.sh --push` and `--variant zh --push` produce `1.4.1`/`latest` and `1.4.1-zh`/`zh` (build-wrapper contract PASS) |
| `README.md` → Running / profile volume / recovery | Preserved behaviors (REQ-003) | `No change` | Profile volume, stale-lock recovery, ports unchanged (C05/C12) |
| `VERSION` | Release identity | `No change` (already `1.4.1` in `6d4aa75`) | Pinned once in `tests/validate-source-contract.sh` |
| `chromium.d/autobyteus-password-store` | In-file rationale comment | `No change` | Comment states all three launch paths and the agent-operated rationale |
| `Dockerfile` purge comment | In-file rationale | `No change` | Accurate |
| `.env.chrome-vnc.example`, `docker-compose*.yml`, `run-container.sh` | Could mention keyring/password store | `No change` | No keyring or password-store configuration; nothing to update |
| Superrepo `autobyteus-server-ts/docker/Dockerfile.monorepo`, `docker/Dockerfile.allinone`, server/docker READMEs (read-only) | Downstream consumers | `No change` | Only consume `autobyteus/chrome-vnc:${tag}`; `git grep` finds no keyring/password-store text. Server source changes are out of scope (requirements); no downstream doc claims the old behavior |
| `tickets/in-progress/chromium-keyring-prompt/release-notes.md` | Release record | `Updated` (created) | Pre-verification release notes; moved to `tickets/done/` after user verification |

## Docs Updated

| Doc Path | Type Of Update | What Changed | Why |
| --- | --- | --- | --- |
| `README.md` (in source commit `6d4aa75`, verified by Delivery) | Behavior/contract docs | Features bullet + "No OS keyring" section | Documents the new invariant for consumers and operators |
| `tickets/in-progress/chromium-keyring-prompt/release-notes.md` (Delivery) | Release notes | New `1.4.1` / `1.4.1-zh` notes (publication pending) | Repository release-record convention (`tickets/done/<ticket>/release-notes.md`) |

## Durable Design / Runtime Knowledge Promoted

| Topic | What Future Readers Need To Understand | Source Ticket Artifact(s) | Target Long-Lived Doc |
| --- | --- | --- | --- |
| No Secret Service provider | Ubuntu 24.04 desktop extras pull `gnome-keyring` via apt Recommends; the build purges it (and `evolution-data-server`) so keyring requests fail fast | `investigation-notes.md` (RUN-007/012), `design-spec.md` DS-002 | `README.md` "No OS keyring"; enforced by `tests/validate-image.sh` |
| Single owner of Chromium password-store policy | `/etc/chromium.d/autobyteus-password-store` is sourced by `/usr/bin/chromium` for every launch; no other file sets `--password-store`; downstream images must not reconfigure it | `design-spec.md` Ownership Map / Dependency Rules | `README.md`; enforced by `tests/validate-source-contract.sh` + `tests/validate-image.sh` |
| Profile-volume sensitivity | Built-in key is obfuscation; the profile volume is the sensitive store | `requirements-doc.md` QR-002/RSK-001 | `README.md` |
| Upgrade data continuity | Upgrading from 1.4.0 where a keyring password was typed → one re-login for affected sites | `requirements-doc.md` DEC-003, `api-e2e-execution-coverage-report.md` C11 | `README.md` |
| Runtime invariant checks | Runtime contract asserts the flag, http navigation ≤ 30 s, no keyring processes/activation, Secret Service fail-fast ≤ 2 s | `implementation-handoff.md` | `tests/validate-running-container.sh` (executable doc) |

## Removed / Replaced Components Recorded

| Old Component / Path / Concept | What Replaced It | Where The New Truth Is Documented |
| --- | --- | --- |
| `gnome-keyring`, `libpam-gnome-keyring` (implicit apt Recommends, 1.4.0) | No provider (purged); `evolution-data-server` removed as its hard dependent | `README.md` "No OS keyring"; `Dockerfile` layer-2 comment |
| Chromium's implicit OS-keyring selection (Secret Service on XFCE) | `--password-store=basic` via `/etc/chromium.d/autobyteus-password-store` | `README.md`; drop-in comment |
| `VERSION must be 1.4.0` contract; hard-coded `1.4.0` tags in `validate-build-wrapper.sh` | `VERSION` 1.4.1 pinned once in the source contract; wrapper test reads `VERSION` | `tests/validate-source-contract.sh`, `tests/validate-build-wrapper.sh` |

## No-Impact Decision (Use Only If Truly No Docs Changes Are Needed)

- Docs impact: Not `No impact` — the long-lived README change exists (authored in the source commit and verified accurate by Delivery); Delivery added release notes.
- Rationale: N/A

## Delivery Continuation

- Result: `Pass`
- Next delivery action: Hold for explicit user verification of the integrated handoff (`handoff-summary.md`), then archive release notes, finalize the repository, publish `1.4.1`, re-publish the server images, verify, and upgrade operator nodes (AC-006).
- Notes: Informational, out of approved scope (not documented as a feature): `gcr`/`pinentry-gnome3` remain and could show a GPG passphrase prompt only for a passphrase-protected GPG key; not a Secret Service request and never observed.

## Blocked Or Escalated Follow-Up (Use Only If Docs Sync Cannot Complete)

- Classification: N/A
- Recommended recipient: N/A
- Why docs could not be finalized truthfully: N/A
