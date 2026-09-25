# Handoff — Architecture Design Complete

- Result classification: `Architecture Design Complete`
- Package identifier: `BRD-KEYRING-PROMPT-001`
- Current solution revision: `SR-005` (requirements approved at `SR-004`)
- task_size: `Small`
- architectural_risk: `Low`
- Selected route (per handoff rules): direct implementation → `/implementation_engineer` (independent architecture review not required for Small/Low; implementation self-checks and executable validation still apply).
- Date: 2026-09-25

## Original Request And Goal

User (2026-09-24): in AutoByteus server Docker nodes a GNOME "Choose password for new keyring" dialog appears when Chromium opens a website — analyse and disable it. Clarified goal: nodes are agent-operated; nothing may block on an interactive keyring dialog.

## Approved Solution (user "approve.", 2026-09-25)

1. Base image stops shipping the interactive keyring provider: purge `gnome-keyring` and `libpam-gnome-keyring` (removes `evolution-data-server` too — expected, verified default + zh).
2. Every Chromium launch uses `--password-store=basic` via one drop-in `/etc/chromium.d/autobyteus-password-store` (sourced by `/usr/bin/chromium` for supervisor, `xdg-open`/server bridge and desktop launches).
3. Validation assertions in the existing `tests/validate-*.sh`; README; `VERSION` 1.4.1.
4. Release (delivery-owned, DEC-005): publish `autobyteus/chrome-vnc` `1.4.1`/`latest` and `1.4.1-zh`/`zh` (amd64 + arm64) → re-publish the unchanged AutoByteus server images via manual `Server Docker Release` workflow_dispatch for the latest `v*` tag (default, then `publish_zh=true`), no new `v*` tag → `autobyteus-docker upgrade --all` for local nodes.
- Approved acceptable loss: one-time re-login for sites whose cookies were encrypted with a keyring key (only nodes where an operator typed a keyring password, e.g. `autobyteus-server-0`).
- Out of scope: "Restore pages?" bubble (separate ticket), global `--no-install-recommends`, server source changes, base-image pinning.

## Workspace / Base / Finalization

- Repository: `browser_docker`
- Task worktree / branch: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt` / `codex/chromium-keyring-prompt`
- Base: `origin/main` @ `4d03f29a46d6d7cf96649718731efe25bef335ab` (VERSION 1.4.0)
- Finalization target: `origin/main`
- Downstream consumer (no source change): `/Users/normy/autobyteus_org/autobyteus-workspace-superrepo` (`autobyteus-server-ts/docker/Dockerfile.monorepo`, `.github/workflows/release-server-docker.yml`, `scripts/public/docker/autobyteus-docker.sh`)
- The user's primary checkout `/Users/normy/autobyteus_org/browser_docker` (branch `codex/python313-supervisor-compatibility`) must not be modified.

## Artifacts (absolute paths)

- Requirements (Approved, SR-004): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/requirements-doc.md`
- Investigation notes: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/investigation-notes.md`
- Design spec (Ready, SR-005): `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/design-spec.md`
- Solution revision record: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/solution-revision-record.md`
- Evidence: `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/evidence/` (user report screenshot; probe A/B/C screenshots; probe drop-in)
- Architecture review artifacts: `N/A — not applicable` (Small/Low direct route)
- Product Design artifacts: `N/A — not applicable`

## Classification Evidence

- Small: one repository; `Dockerfile` (purge + COPY + dos2unix/chmod), one new drop-in file, `VERSION`, `README.md`, assertions in three existing test scripts; no new runtime owner.
- Low: restores the probed known-good 1.3.x state with Chromium's documented switch and the distribution's drop-in mechanism; mechanisms verified on the real 1.4.0-based image (RUN-004, RUN-007..010); no API/schema/concurrency/ownership change; security/persistence effects user-approved.
- Escalation triggers (return `Design Impact`): purge removes packages beyond the three named; any preserved `tests/validate-*.sh` check fails; Chromium still activates `org.freedesktop.secrets`/portal Secret with the flag; wrapper no longer sources `/etc/chromium.d`.

## Expected Output From Implementation

Implementation per `design-spec.md` "Change / Refactor Sequence" steps 1–3 (source, tests, local validation incl. negative control against 1.4.0), with `implementation-handoff.md` and evidence logs under `requirements/chromium-keyring-prompt/evidence/`. Release steps (4a–4c) remain delivery-owned.

## Open Risks

RSK-001 (built-in cookie key; accepted), RSK-002 (low), RSK-004 (stale local base on local server builds — delivery guidance), RSK-005 (future hard dependency — caught by image checks).

## Route Record

- `get_handoff_rules` (2026-09-25) → matching rule: "Architecture Design Complete with task_size=Small or Medium and architectural_risk=Low" → recipient `/implementation_engineer`.
