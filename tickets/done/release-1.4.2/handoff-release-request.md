# Release Request: browser_docker 1.4.2 / 1.4.2-zh and the server base-digest bump

- Classification: `Release Requested` (Solution Designer, 2026-11-21). No software change to design. The superrepo pin bump is the rollout step that `browser_docker/RELEASE.md` "Watching The Rollout" step 1 names.
- Task: Project Task `autobyteus-598` (Project `project_a1377344-25db-482a-97cc-ecfdb0fb495a`), from `/project_task_manager` (run `project_task_manager_7c8dce0c4a8b44f88e776a83809dee03`).
- Requested by: the founder, in his words (2026-11-21): *"Release for browser docker please"*. The Task's further direction is from the Project Task Manager.
- What is released: the X socket directory restart fix (autobyteus-596). Release notes: `tickets/done/x11-unix-restart/release-notes.md`.

## Worktrees

| Repository | Worktree | Branch | Base | Target |
| --- | --- | --- | --- | --- |
| browser_docker (`AutoByteus/browser-docker`, images `autobyteus/chrome-vnc`) | `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-release-1.4.2` | `codex/release-1.4.2` | `origin/main` @ `9c0356dcd19734fdeee01189d5fb307ac256adc6` (`VERSION` 1.4.2; code `7164571`) | publish from this commit; release records to `origin/main` |
| superrepo (`AutoByteus/autobyteus-workspace`) | `/Users/normy/autobyteus_org/autobyteus-worktrees/chrome-vnc-1.4.2-digests` | `codex/chrome-vnc-1.4.2-digests` | `origin/personal` @ `ecd6d4556c881168f447c73ed09c156de6ee0b10` | merge to `origin/personal` |

Both branches track their base. Push the ticket branches explicitly by name.

## Scope (from the Task)

1. Publish `autobyteus/chrome-vnc` `1.4.2` (default) and `1.4.2-zh`, `linux/amd64` + `linux/arm64`, and move `latest` / `zh`. Follow `browser_docker/RELEASE.md`, `DESIGN.md`, `TESTING.md`.
2. Validate both variants on both architectures with `tests/validate-image.sh`, `tests/validate-running-container.sh` and `tests/validate-restart-recovery.sh`.
   - **Before pushing tags, where practical.** This answers the open decision from autobyteus-596's docs-sync report: build and check each architecture before the push, so no broken tag is published. amd64 runs under emulation on this arm64 host.
   - Then run the guide's after-publishing checks against the published child digests.
   - If a pre-push amd64 run is not practical, record why and fall back to the guide's after-publishing checks with its rollback.
3. Superrepo: bump `autobyteus-server-ts/docker/system-level.json` `baseImages.default` / `baseImages.zh` to the new **index** digests, plus the `Dockerfile.monorepo` `ARG BASE_IMAGE_DIGEST` default and `systemInputsSha256`. Verify with `node scripts/server-package/check-system-level.mjs` and the offline checks the superrepo's `TESTING.md`/`RELEASE.md` name for this area (e.g. `scripts/tests/test_server_package_release.py`). Merge to `origin/personal`.

## Note on the system level (Solution Designer finding, within the direction)

The superrepo `RELEASE.md` ("Server Docker system level", around L624) and `check-system-level.mjs` require **raising `level` (1 → 2)** in the same change whenever the pinned base digests change. The check prints the new hash. So the bump is: digests + `level: 2` + `systemInputsSha256`.

Consequence, to state in the delivery report:
- Server packages built from `personal` after this merge need level 2.
- A node still on a level-1 image refuses them until it is recreated on a server image built from this change (`autobyteus-docker upgrade`).
- That is the normal path by which nodes get the fixed base anyway.

The Solution Designer decided this within the founder's direction and informed him. It is the project's own rule, not a new policy.

## Constraints

- Do **not** cut an AutoByteus beta/stable release tag, and do not re-publish the server image. The server-image rebuild/re-publish and recreating nodes are not part of this Task. Report them as the remaining rollout steps.
- Do **not** touch or recreate `autobyteus-server-0`/`1`/`2`. Throwaway containers only, labelled `chrome-vnc.test=throwaway`, with `--cap-add SYS_ADMIN --security-opt seccomp=unconfined`.
- Never print, log or commit credentials or tokens (Docker Hub login, `gh`).
- Never push over a published `X.Y.Z` tag (RELEASE.md).
- Rollback baselines (from the 1.4.1 release notes):
  - `latest` → `sha256:b2fde77f3bd7c73d412ea59d42e3b65290bae9f39d1ce85b5aaaac5d869596f4`;
  - `zh` → `sha256:19d4c0164e5c7006e38a81c0260611cbf26f871f2d3e749d574016676f4f9a67`.

## Done when

- 1.4.2 / 1.4.2-zh and `latest` / `zh` are published and validated on both variants and architectures, with the digests recorded in the release notes and report.
- The superrepo bump is verified and merged to `origin/personal`.
- Worktrees, temporary branches (local and remote), throwaway images/containers and this release's `/tmp` scratch are cleaned up.
- A record copy is in `/Users/normy/autobyteus_org/autobyteus-delivery-records/`.
- Any follow-ups are recorded.
- Return `Delivery Completed` to the Solution Designer.
