# Delivery / Release / Deployment Report — chrome-vnc 1.4.2 (autobyteus-598)

## Release / Publication / Deployment Scope

- Release request (`Release Requested`, Solution Designer, 2026-11-21) on the founder's word: *"Release for browser docker please"*. Handoff: `handoff-release-request.md`.
- Released: `autobyteus/chrome-vnc` `1.4.2` (default) and `1.4.2-zh`, `linux/amd64` + `linux/arm64`. The rolling tags `latest` and `zh` moved. Content: the X socket directory restart fix (autobyteus-596, `tickets/done/x11-unix-restart/`).
- Downstream step 1 (the server's base pins) was done in `AutoByteus/autobyteus-workspace` and merged to `personal`.
- Not done, by the request:
  - no AutoByteus release tag;
  - no server-image rebuild or re-publish;
  - `autobyteus-server-0/1/2` untouched.

## Project Release Guide

- Release guide path and revision: `RELEASE.md` at `main` @ `9c0356d` (created by autobyteus-596). Superrepo: `RELEASE.md` "Server Docker system level" on `personal`.
- Deviations from the guide and why: `None`. The release also ran the checks before the push, as the request asked; the guide had them only after publishing.
- Guide fix, made with the founder's direction: `RELEASE.md` gains "Checks Before Publishing". This answers autobyteus-596's open decision: build and check every variant on every architecture before the push, because the push moves `latest`/`zh`. This release showed it is practical (amd64 under emulation: about 15 minutes per build, 2–3 minutes for the checks). "Checks After Publishing" stays, because the release builds with `--no-cache`.

## Release Decision

- Decision: `Stable` image release `1.4.2` / `1.4.2-zh`.
- Decided by: the founder ("Release for browser docker please").

## Checks Before Publishing

- Builds from `main` @ `9c0356d`, under local tags `rel598-<variant>-<arch>:local`, never pushed. Command: `docker buildx build --builder multi-platform-builder --load --platform linux/<arch> --build-arg IMAGE_VARIANT=<variant>`. All four exit 0 (`evidence/delivery/D-01-prepush-builds.txt`):

  | Build | Duration |
  | --- | --- |
  | default arm64 | 5.6 min |
  | default amd64 | 14.4 min |
  | zh arm64 | 6.4 min |
  | zh amd64 | 16.7 min |

- Checks in labelled throwaway containers (`evidence/delivery/D-02-prepush-checks.txt`, `evidence/delivery/checks/pre-*.log`): `validate-image.sh`, `validate-running-container.sh` and `validate-restart-recovery.sh` all exit 0 for default/arm64, default/amd64, zh/arm64 and zh/amd64, which is 12 of 12. Each restart run ends with "PASS: after a root X server took over /tmp/.X11-unix, the desktop recovered after a Supervisor restart of Xvnc, docker restart, and kill/start; /tmp/.X11-unix stayed root root 1777."
- Before the push:
  - `1.4.2` and `1.4.2-zh` were confirmed unpublished;
  - rollback baselines recorded: `latest` = `1.4.1` = `sha256:b2fde77f3bd7c73d412ea59d42e3b65290bae9f39d1ce85b5aaaac5d869596f4`; `zh` = `1.4.1-zh` = `sha256:19d4c0164e5c7006e38a81c0260611cbf26f871f2d3e749d574016676f4f9a67`.

## Version / Tag / Release Commit

- `VERSION` 1.4.2 (autobyteus-596, `37edc71`). Published from `main` @ `9c0356d`. No git tag (RELEASE.md: the image tags are the release).

## Repository Finalization

- browser_docker:
  - Nothing to merge before publishing: `main` already held 1.4.2.
  - This release's records (this folder, the updated 1.4.2 release notes, the `RELEASE.md` step) go to `main` from `codex/release-1.4.2` as a fast-forward. The commit is in the terminal message.
  - Checks before pushing `main`: `tests/validate-source-contract.sh`, `tests/validate-build-wrapper.sh`.
- superrepo (`AutoByteus/autobyteus-workspace`):
  - Branch `codex/chrome-vnc-1.4.2-digests` with commit `ebeec5840f`:
    - `system-level.json`: `baseImages.default` = `sha256:86b7891d…6a50b`, `baseImages.zh` = `sha256:c381f2e8…68783`, `level` 1 → 2, `systemInputsSha256` = `61cd87f9a8cca3c3df207db0d7b36807f3dace192b9288b00102ff9c809725b7`;
    - the `Dockerfile.monorepo` `ARG BASE_IMAGE_DIGEST` default = the default index digest;
    - record `tickets/done/chrome-vnc-1.4.2-digests/release-deployment-report.md`.
  - Checks: `node scripts/server-package/check-system-level.mjs` gives "System level 2: the system part is unchanged (61cd87f9…)"; the TESTING.md "Server Docker Release workflow steps" unittests give `Ran 73 tests … OK`; the Secret Gate PASS on the ticket commit and on the merged state; artifact hygiene PASS.
  - `origin/personal` moved during the release (`ecd6d4556c` → `9f6add773b`: autobyteus-22 and 591). Those commits change nothing under `autobyteus-server-ts/docker/`, so the hash holds. The check and tests were rerun on the merged state: PASS.
  - `--no-ff` merge `81f6aa8be4` pushed: `9f6add773b..81f6aa8be4 HEAD -> personal`.
- Superrepo user checkout (`/Users/normy/autobyteus_org/autobyteus-workspace-superrepo`, on `personal`, no local commits): fast-forwarded to `81f6aa8be4`.
- browser_docker checkouts:
  - the primary `/Users/normy/autobyteus_org/browser_docker` is on `codex/python313-supervisor-compatibility`, so it is left untouched;
  - the local `main` worktree `browser_docker-worktrees/ubuntu-24-minimal-base-main-finalize` is fast-forwarded after the records' push (terminal message).

## Release / Publication / Deployment

- Applicable: `Yes`
- Method: `Project Release Guide`. Commands: `./build-multi-arch.sh --push --no-cache` (default, 18:23–18:46 UTC), then `./build-multi-arch.sh --variant zh --push --no-cache` (18:46–19:16 UTC). Both exit 0 (`evidence/delivery/D-03-publish.txt`, `D-03b-publish-manifest-lines.txt`).
- Pipelines triggered: none (the repository has no CI).
- Published (`evidence/delivery/D-04-published-index-inspect.txt`):

| Tags | Index digest | linux/amd64 | linux/arm64 |
| --- | --- | --- | --- |
| `1.4.2`, `latest` | `sha256:86b7891d3d1d74e1b3bd42c44df9729d56343127b6f745f1f3fda8d6a6e6a50b` | `sha256:730bcd148ce6abc66a7119285c6934177ff41f9409795562fbf723f660735561` | `sha256:fdd91bd5b93d45d47a0953583917704366d95542f911e75e8c603ea6b5fa1cb1` |
| `1.4.2-zh`, `zh` | `sha256:c381f2e82fc0f0da9a74367e1c4e5029e195c90016e0dd187f9269768dd68783` | `sha256:ceb3ab231290d84a05fdbf9c3d187839a611612c9573605b29ba735154e07ddd` | `sha256:2ea28997a55b2c1f4ee48801cadf477c85292eb1c4abb084b235d4836a292957` |

- Published artifacts checked against what the release should produce:
  - each immutable tag and its rolling tag resolve to the same index;
  - exactly one `linux/amd64` and one `linux/arm64` runtime manifest per index;
  - the two `unknown/unknown` entries are BuildX attestations.
- Checks after publishing (`evidence/delivery/D-05-published-checks.txt`, `checks/pub-*.log`): each child digest was pulled by `--platform`, and all three checks exit 0 for all four, 12 of 12.
- Failed jobs: `None`
- Release/publication/deployment result: `Completed` for the base images. The downstream rollout is pending (below).
- Release notes handoff result: `Used`. `tickets/done/x11-unix-restart/release-notes.md` now records the publication, the source commit and the digests.

## Remaining Rollout Steps (not in this request)

1. Rebuild and publish the AutoByteus server image from `personal` (≥ `81f6aa8be4`): the next beta or stable, or a server re-publish, on the founder's word.
2. Recreate the nodes on it (`autobyteus-docker upgrade`).

- Consequence of level 2: server packages built from `personal` now need level 2. A node on a level-1 server image (today's nodes) refuses them until it is recreated on a server image built from this change. That is the same path by which nodes get the fixed base.
- Until then, a node whose desktop went FATAL after an X server takeover recovers with the README command in `browser_docker` (DEC-005 of autobyteus-596).

## Post-Finalization Cleanup

- Plan, run after the records' push:
  - remove the worktrees `browser-docker-release-1.4.2` and `chrome-vnc-1.4.2-digests`;
  - delete the local and remote branches `codex/release-1.4.2`, `codex/chrome-vnc-1.4.2-digests` and the two `finalize/` branches;
  - remove the four local `rel598-*:local` images, the four pulled `autobyteus/chrome-vnc@<child>` images and any `rel598-*` container;
  - remove the scratch folder `/tmp/rel598`.
- Kept: the published images, the founder's `autobyteus-server-0/1/2` (not touched), and `autobyteus/chrome-vnc:latest`/`zh` if any local container uses them.
- Record copy: `/Users/normy/autobyteus_org/autobyteus-delivery-records/release-chrome-vnc-1.4.2-autobyteus-598-20261121/`.
- The result is reported in the terminal message.

## Rollback Criteria

- Base images: point `latest` and `zh` back at the baselines above with `docker buildx imagetools create` (RELEASE.md "Rollback"). The `1.4.2` tags stay; a fix goes out as 1.4.3.
- Server pins: revert `81f6aa8be4` on `personal`. No server image was built from it yet.

## Final Status

- Verification (the release guide's checks before and after publishing): `Yes`, 24 of 24
- Repository finalization complete: `Yes`. Superrepo `81f6aa8be4` on `personal`; browser_docker records to `main` (terminal message)
- Release complete: `Yes` for the base images; the server-image rollout is outside this request
- Cleanup: after the records' push; result in the terminal message
- Unresolved blocker: `None`
- Terminal package sent to the Solution Designer: after the cleanup
