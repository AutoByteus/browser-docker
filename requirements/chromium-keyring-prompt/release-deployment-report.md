# Delivery / Release / Deployment Report

## Release / Publication / Deployment Scope

- Ticket: `BRD-KEYRING-PROMPT-001`
- Classification: `task_size=Small`, `architectural_risk=Low`, direct low-risk route (architecture review, code review, and API/E2E test-code review `N/A — not applicable`)
- Base image: `docker.io/autobyteus/chrome-vnc` `1.4.1` + `latest`, `1.4.1-zh` + `zh`, `linux/amd64` + `linux/arm64` (REQ-005, AC-006, DEC-002)
- Downstream: AutoByteus server images (default + zh) re-published on the new base from unchanged server source via manual `Server Docker Release` `workflow_dispatch` for `v1.4.80` (DEC-005); no new `v*` tag
- Rollout: operator nodes via `autobyteus-docker upgrade --all` (named volumes kept)
- Final result: `Completed` (`DR-002`)

## Handoff Summary

- Handoff summary artifact: `requirements/chromium-keyring-prompt/handoff-summary.md`
- Handoff summary status: `Updated`
- Delivery revision record: `requirements/chromium-keyring-prompt/delivery-revision-record.md`
- Current delivery revision ID: `DR-002`
- Notes: The ticket worktree was removed after finalization; the durable artifacts live on `main` (local checkout `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base-main-finalize`).

## Initial Delivery Integration Refresh

- Bootstrap base reference: `origin/main` @ `4d03f29a46d6d7cf96649718731efe25bef335ab`
- Latest tracked remote base reference checked: `4d03f29a46d6d7cf96649718731efe25bef335ab` (DR-001, 2026-09-25T05:40Z; re-checked after user verification, unchanged)
- Base advanced since bootstrap or previous refresh: `No`
- New base commits integrated into the ticket branch: `No`
- Local checkpoint commit result: `Not needed`
- Integration method: `Already current`
- Integration result: `Completed`
- Post-integration executable checks rerun: `Yes` (repository-level smoke)
- Post-integration verification result: `Passed`
- No-rerun rationale (only if no new base commits were integrated): The branch already contained `origin/main`; the API/E2E-validated tree was the integrated state.
- Delivery edits started only after integrated state was current: `Yes`
- Handoff state current with latest tracked remote base: `Yes`
- Blocker (if applicable): None
- Evidence: `evidence/delivery-dr001-integration-refresh.log`

## User Verification

- Initial explicit user completion/verification received: `Yes`
- Initial verification / acceptance reference: 2026-09-25, user reply to the DR-001 handoff: "i thjink its already verified. so finalize and release" (the handoff listed the full AC-006 plan, including `autobyteus-docker upgrade --all` re-creating all 7 nodes)
- Renewed verification required after later re-integration: `No` (`origin/main` did not advance)
- Renewed verification received: `Not needed`
- Renewed verification / acceptance reference: —

## Docs Sync Result

- Docs sync artifact: `requirements/chromium-keyring-prompt/docs-sync-report.md`
- Docs sync result: `Updated`
- Docs updated: `README.md` (Features + "No OS keyring", in source commit `6d4aa75`, verified accurate by Delivery); `tickets/done/chromium-keyring-prompt/release-notes.md`
- No-impact rationale (if applicable): N/A

## Ticket State Transition

- Ticket moved to `tickets/done/<ticket-name>`: `Yes` (after user verification, before the final commit)
- Archived ticket path: `tickets/done/chromium-keyring-prompt/` (release notes; the remaining ticket artifacts stay under `requirements/chromium-keyring-prompt/` per repository convention)

## Version / Tag / Release Commit

- `VERSION` = `1.4.1` (source commit `6d4aa75`); `build-multi-arch.sh` derived `1.4.1`/`latest` and `1.4.1-zh`/`zh`.
- Git tag: not part of this repository's documented release method; none created.
- Release input commit: `main` @ `6e02d7e6855b988d48b5ed44a0316b7ba34b5bf4`.

## Repository Finalization

- Bootstrap context source: `handoff-architecture-design-complete.md` → finalization target `origin/main`
- Ticket branch: `codex/chromium-keyring-prompt`
- Ticket branch commit result: `Completed` — `6e02d7e` (`docs(release): record keyring-prompt validation and 1.4.1 delivery handoff`)
- Ticket branch push result: `Completed` — remote ref verified at `6e02d7e`
- Finalization target remote: `origin` (`git@github.com-ryan:AutoByteus/browser-docker.git`)
- Finalization target branch: `main`
- Target advanced after verification / acceptance: `No` (refetched: `4d03f29`)
- Delivery-owned edits protected before re-integration: `Not needed`
- Re-integration before final merge result: `Not needed`
- Target branch update result: `Completed` — local `main` current with `origin/main` `4d03f29`
- Merge into target result: `Completed` — fast-forward `4d03f29..6e02d7e`; source contract and build-wrapper checks PASS on `main`
- Push target branch result: `Completed` — remote `main` verified at `6e02d7e` before publication
- Repository finalization status: `Completed`
- Blocker (if applicable): None
- Evidence: `evidence/delivery-dr002-repository-finalization.log`

## Release / Publication / Deployment

- Applicable: `Yes`
- Method: `Release Script` (base) + `GitHub Release` workflow `workflow_dispatch` (server) + `Deployment Path` (launcher)
- Method reference / command:
  1. `./build-multi-arch.sh --push --no-cache` then `./build-multi-arch.sh --variant zh --push --no-cache` from `main` @ `6e02d7e`
  2. `docker buildx imagetools inspect` per tag; pull/run each exact platform child digest with `tests/validate-image.sh` + `tests/validate-running-container.sh` (`evidence/delivery-dr002-harness/verify-published.sh`)
  3. `gh workflow run release-server-docker.yml --repo AutoByteus/autobyteus-workspace -f release_tag=v1.4.80` (run `36108457202`), then `-f publish_zh=true` (run `36110680037`)
  4. Published server images: throwaway container per variant × platform with launcher-equivalent env/volumes; base runtime contract + API/E2E probes (launch paths incl. the shipped server bridge, operator view, keyring clients) (`evidence/delivery-dr002-harness/verify-server.sh`)
  5. `docker pull autobyteus/chrome-vnc:latest` / `:zh` locally (RSK-004); `autobyteus-docker upgrade --all`; read-only checks on all 7 nodes (`evidence/delivery-dr002-harness/check-node.sh`) + operator-view probe on `autobyteus-server-0` and `-3`
- Release/publication/deployment result: `Completed`
- Release notes handoff result: `Used` (`tickets/done/chromium-keyring-prompt/release-notes.md`)
- Blocker (if applicable): None

### Published Base Identities

| Variant | Immutable tag | Rolling tag | Index digest | linux/amd64 child | linux/arm64 child |
| --- | --- | --- | --- | --- | --- |
| default | `1.4.1` | `latest` | `sha256:b2fde77f3bd7c73d412ea59d42e3b65290bae9f39d1ce85b5aaaac5d869596f4` | `sha256:31e3d3d8d15e16cba0187a74fd017a59e35ec70f5729d5dcb47acfe7144713e0` | `sha256:f35358e25b29fac65b31b58e8024d4449e75c6db4af65281943f50a9114514ce` |
| `zh` | `1.4.1-zh` | `zh` | `sha256:19d4c0164e5c7006e38a81c0260611cbf26f871f2d3e749d574016676f4f9a67` | `sha256:12046d628acb55680a493a6f1066f5cd25542e49efc5985c45dd3501b429b454` | `sha256:ef303811c7cbf5d0452cd899f47fe0d640a0e463455be3f5e82c1d219303f565` |

- Immutable = rolling per variant: `Pass`. Exactly one `linux/amd64` + one `linux/arm64` runtime manifest per tag; the two `unknown/unknown` descriptors are BuildX attestation manifests.
- Build purge on all 4 platform/variant builds removed exactly `evolution-data-server`, `gnome-keyring`, `libpam-gnome-keyring` (escalation trigger (a) not fired).
- Evidence: `delivery-dr002-publish-{default,zh}.log`, `delivery-dr002-remote-manifests-{default,zh}.log`

### Published Base Runtime Verification (exact child digests)

| Variant | Platform | `validate-image.sh` | `validate-running-container.sh` | http nav (≤ 30 s) | Secret Service fail-fast (≤ 2 s) |
| --- | --- | --- | --- | --- | --- |
| default | arm64 | PASS | PASS | 45 ms | 6 ms |
| default | amd64 (emulated) | PASS | PASS | 1159 ms | 195 ms |
| `zh` | arm64 | PASS | PASS | 45 ms | 7 ms |
| `zh` | amd64 (emulated) | PASS | PASS | 1017 ms | 185 ms |

Chromium `153.0.8010.52`; keyring packages not installed; drop-in present. Evidence: `delivery-dr002-published-{default,zh}-{arm64,amd64}.log`.

### Re-published Server Identities (same server code `v1.4.80`, new base)

| Variant | Tags | Workflow run | Built FROM | Index digest | linux/amd64 | linux/arm64 |
| --- | --- | --- | --- | --- | --- | --- |
| default | `1.4.80`, `latest` | `36108457202` (success, 07:35–08:09Z) | `chrome-vnc:latest@sha256:b2fde77f…` | `sha256:f42018efc2253507575034001b477f108c4a166ff3bd1769d662c47e8d78cfb7` | `sha256:3350660fd39e5b7bffd32b5d29d88b02bbc78c3103b593424993cde462719bb0` | `sha256:91e7ee2d142b9e05ee271a5ade9fc0dca466535b36f6c114348ff9c9cffcf292` |
| zh | `1.4.80-zh`, `latest-zh` | `36110680037` (success, 08:01–08:41Z) | `chrome-vnc:zh@sha256:19d4c016…` | `sha256:dc3efc572f201984cb34779671c69d8c137e475b1b509bedbddd4645d739aa01` | `sha256:484fd8ebf3a7ac4bd03457a5fff1ec02d7854d5e554c252082cc8843be637cc5` | `sha256:a69be5d61cf67d7c416ccb2d878d00d5b3c808f7cf820203cf821fc7eb7f87cc` |

- `v1.4.80` was the latest published release (GitHub "Latest") at dispatch time; no new `v*` tag was created.
- Server verification (all 4 platform/variant images, 28 PASS / 0 FAIL each): base runtime contract (AC-001/002/007); `autobyteus_server` RUNNING and answering HTTP; keyring packages absent; drop-in the only `--password-store` owner; C07 launch paths via the shipped `/usr/local/bin/open-vnc-browser-url.sh` (warm + cold), cold `exo-open`, cold `gtk-launch` (AC-003); C09 operator view (no keyring window/process/activation); C10 libsecret clients fail fast (≤ 40 ms). Evidence: `delivery-dr002-server-{default,zh}-{arm64,amd64}.log`, `delivery-dr002-server-{default,zh}-operator-view.png`, `delivery-dr002-server-release-{default,zh}.log`.

## Post-Finalization Cleanup

- Dedicated ticket worktree path: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt`
- Worktree cleanup result: `Completed` (clean tree; branch merged into `main` before removal)
- Worktree prune result: `Completed`
- Local ticket branch cleanup result: `Completed` (`git branch -d`, was `6e02d7e`)
- Remote branch cleanup result: `Completed` (`origin/codex/chromium-keyring-prompt` deleted; remote ref absent)
- Images: removed the 5 implementation `impl-keyring-*` images, 4 `dr002-published-*` verification tags, and 4 digest-pulled server child images; retained `chrome-vnc:latest`/`zh` (now 1.4.1), `chrome-vnc:1.4.0`, `autobyteus-server:latest`/`latest-zh` (in use by nodes). The launcher itself removed the superseded node images `1acd3167…` (1.4.78) and `d0b43e3e…` (1.4.66-zh). No task containers or volumes remain.
- Retained: finalization-target `main` worktree `/Users/normy/autobyteus_org/browser_docker-worktrees/ubuntu-24-minimal-base-main-finalize` (authoritative local checkout); the user's primary checkout `/Users/normy/autobyteus_org/browser_docker` untouched.
- Blocker (if applicable): None
- Evidence: `delivery-dr002-worktree-cleanup.log`, `delivery-dr002-cleanup.log`

## Escalation / Reroute (Use Only If Final Handoff Cannot Complete)

- Classification: N/A
- Recommended recipient: N/A
- Why final handoff could not complete: N/A

## Release Notes Summary

- Release notes artifact created before verification / acceptance: `tickets/in-progress/chromium-keyring-prompt/release-notes.md` (DR-001)
- Archived release notes artifact used for release/publication: `tickets/done/chromium-keyring-prompt/release-notes.md`
- Release notes status: `Updated` (final digests recorded)

## Deployment Steps

1. RSK-004: local `autobyteus/chrome-vnc:latest` refreshed `f5a12a4f…` (1.3.8) → `b2fde77f…` (1.4.1); `:zh` `24ca92cb…` (1.3.8-zh) → `19d4c016…` (1.4.1-zh) (`delivery-dr002-local-base-pull.log`).
2. `autobyteus-docker upgrade --all` (08:47:21–08:48:21Z, exit 0): each node pulled its saved ref and was re-created keeping named volumes. `autobyteus-server-0,1,2,4,5,6` → `autobyteus-server:latest` `f42018ef…` (server 1.4.78 → 1.4.80); `autobyteus-server-3` → `latest-zh` `dc3efc57…` (server 1.4.66-zh → 1.4.80-zh).
3. Before upgrade every node ran the old base with `gnome-keyring-daemon` processes present. After upgrade, read-only checks on all 7 nodes: keyring packages absent, drop-in present, Chromium main process carries `--password-store=basic`, no `gnome-keyring-daemon`/`gcr-prompter`, no Secret Service/keyring/portal-Secret activation, `vncuser` Secret Service request → `ServiceUnknown` in 4–15 ms, server GraphQL 200 — 7/7 PASS (`delivery-dr002-node-upgrade.log`).
4. Operator view on `autobyteus-server-0` (the node where a keyring password had been typed) and `autobyteus-server-3` (zh): no keyring/prompter/unlock window in the X11 tree, no prompt process, no keyring activation (`delivery-dr002-node-operator-view.log`, `delivery-dr002-node-autobyteus-server-{0,3}-operator-view.png`). The screenshots show Chromium's "Restore pages?" bubble — the separate, out-of-scope ticket (DEC-004), not a regression of this change.

## Environment Or Persisted-Data Transition Notes

- Approved persisted-data decision: `Directly Usable — No Migration` for the Chromium profile volume; keyring-encrypted cookie/password values `Discard or Rebuild` (one re-login; DEC-003)
- Delivery action required: `None`
- Result and evidence: Nodes re-created on their existing named volumes; Chromium started without dialog on all 7 (including `autobyteus-server-0`). Sites whose cookies were keyring-encrypted on `autobyteus-server-0` may need one re-login (approved). API/E2E C11 proves both upgrade shapes.
- Migration completion, validation, recovery, and rollout evidence, only when `Migration Required`: N/A

## Verification Checks

All passed — see the tables above and "Deployment Steps". AC coverage at delivery: AC-001/002/003/007 on published base (4) and server (4) images and on the 7 upgraded nodes (AC-002 navigation not exercised on user nodes to avoid touching their browser state; proven on the published server images); AC-004/008 via the image/runtime contracts on published images; AC-005 via API/E2E C11 plus the upgraded `autobyteus-server-0`; AC-006 complete.

## Rollback Criteria

- Trigger: published-image contract failure or node regression. None observed.
- Base baselines (retained immutable): `1.4.0` `sha256:cb49a54d8e745a45351ecab1e5f47db0eee71b30ab2e15e8c3745b91f2941af1`; `1.4.0-zh` `sha256:597c8702e0a2418078aca64a7f4bc19e2a26af277af119a893d51a9215837c48`.
- Server baselines (pre-re-publish, still pullable by digest): `1.4.80`/`latest` was `sha256:08ca936169d8862f826558b8a112c51d2b02fef09be642fd4103e96a0f382414`; `latest-zh` was `1.4.66-zh` `sha256:d0b43e3eca7c5e2fd3a1cca4c3a3127a20f05208fa636b67e9324d4f58711dc5` (`1.4.66-zh` tag retained); nodes previously ran `1.4.78` `sha256:1acd3167b4ae01b83d07f9b9be2e35cad0727713e716a6ea5d3a2d2f0b6ff791`.
- Method: `docker buildx imagetools create -t <repo>:<tag> <repo>@<baseline digest>` then verify; nodes via `autobyteus-docker upgrade --all --image <repo>@<digest>` (or `--tag`).

## Final Status

- Explicit user testing/verification complete: `Yes`
- Repository finalization complete: `Yes`
- Applicable release/deployment/rollout complete or not required: `Yes`
- Applicable safe cleanup complete or not required: `Yes`
- Unresolved blocker: `None`
- Successful terminal package eligible for return: `Yes`
- Terminal package sent to `/solution_designer`: `Yes` (accepted, `DELIVERED`, run `solution_designer_e71a8e894c394d1c9bf6b65e050637f4`)
- Terminal message/reference: see `delivery-revision-record.md` DR-002
