# Investigation Notes

## Investigation Meta

- Package identifier: `x11-unix-restart` (Project Task `autobyteus-596`)
- Request / ticket: autobyteus-596, "Docker VNC startup fails after container restart: start-vnc.sh (vncuser) fails `chmod 1777 /tmp/.X11-unix` on root-owned dir"
- Workspace root: `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart`
- Repository mode: `Git` (`browser_docker`, remote `origin` = `autobyteus/chrome-vnc` image source)
- Task worktree / branch: `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart`, branch `codex/x11-unix-restart`
- Resolved base remote / branch / revision: `origin/main` @ `ef63a4670e7441274bcb577b1cab6b6cc140ef88` (fetched 2026-11-21; `VERSION` `1.4.1`)
- Finalization target remote / branch: `origin/main` of `browser_docker`. No superrepo change in this ticket (see Notes For Architecture Design). A superrepo worktree `codex/docker-vnc-restart` was created at bootstrap and removed unused on 2026-11-21.
- Bootstrap result: `Ready`. The user's local checkout `/Users/normy/autobyteus_org/browser_docker` (old branch `codex/python313-supervisor-compatibility`, untracked `.codex/`) was left untouched.
- Bootstrap blocker: None
- Current solution revision ID: `SR-001`
- Authorities read (requirements reading gate; file and date): `references/requirements-engineering.md`, `references/ticket-scope.md`, `references/handoff.md`, `references/project-documents.md` (2026-11-21)
- Investigation status: Complete for requirements and design

## Initial Request And Clarifications

- Original request: Task autobyteus-596 (Project Task Manager, on the founder's word). Observed live on `autobyteus-server-0` (2026-11-21): after a container restart, `tigervnc` is `FATAL` with `chmod: changing permissions of '/tmp/.X11-unix': Operation not permitted`, taking `xfce`, `chrome` and `copyq` down; the Android VNC viewer shows "The node's desktop disconnected…".
- Clarifications received: None needed.
- User-supplied facts and constraints: Do not touch the founder's running `autobyteus-server-0`/`1`/`2` containers; throwaway test containers only. No release or Docker Hub push without the founder's explicit word; report whether a new `browser_docker` base image tag must be published before the AutoByteus server image picks the fix up.
- Initial ambiguity: what makes `/tmp/.X11-unix` root-owned (the Task names root `Xvnc` displays `:102`/`:103` as an example). Resolved by reproduction below.

## Product And Domain Understanding

- Product area: the node desktop of a Docker node: the `autobyteus/chrome-vnc` base image (this repo) that the AutoByteus server image builds on.
- Affected actors or systems: the founder (viewing the node desktop from the app or a VNC viewer), agents that drive the node's Chromium over DevTools, and agents running root X servers for their own tests.
- Existing operational purpose: the desktop (TigerVNC `Xvnc :99`, XFCE, Chromium, CopyQ, websockify) must come up on every container start and recover when Supervisor restarts a program.
- Relevant terminology: X socket directory `/tmp/.X11-unix` (one listening socket `X<n>` per display; must be sticky world-writable, mode 1777, and is conventionally `root:root`); X lock file `/tmp/.X<n>-lock`.

## Source Log

| Date | Source Type | Exact Source / Command / Query | Why Consulted | Relevant Finding | Follow-Up |
| --- | --- | --- | --- | --- | --- |
| 2026-11-21 | Code | `start-vnc.sh` (origin/main) L9-10 | Failing step | `mkdir -p /tmp/.X11-unix; chmod 1777 /tmp/.X11-unix` unconditionally, under `set -euo pipefail`, as `vncuser` (`base.conf` `[program:tigervnc] user=vncuser`). A non-owner `chmod` returns EPERM, so the script exits 1 before `exec Xvnc`. | Design |
| 2026-11-21 | Code | `base.conf` | Supervisor graph | `tigervnc` `autorestart=true startsecs=2 startretries=20`; `xfce` `depends_on=tigervnc,dbus`; `chrome` `depends_on=dbus,tigervnc,fcitx`; `copyq` `depends_on=xfce,dbus`; `websockify` `depends_on=tigervnc`. When tigervnc exhausts its retries, its dependants go `FATAL`. | — |
| 2026-11-21 | Code | `entrypoint.sh` L94-97 (runs as root before `exec supervisord`) | Container-start cleanup | Removes stale `/tmp/.X99-lock` and `/tmp/.X11-unix/X99`; never creates or normalizes `/tmp/.X11-unix`. `set -eo pipefail`. | Design |
| 2026-11-21 | Code | `Dockerfile` L184-189 | Build-time state | Creates `/tmp/.X11-unix` 1777 and `chown -R ${USER_UID}:${USER_GID}`, so a fresh container has it owned by `vncuser`. | Design |
| 2026-11-21 | Code | `tests/validate-running-container.sh`, `tests/validate-image.sh`, `tests/validate-source-contract.sh` | Existing checks | Running-container check waits for all 8 programs `RUNNING` and checks Xvnc/Chromium/VNC/websockify/DevTools; nothing covers a restart or `/tmp/.X11-unix` ownership. | Requirements (AC) |
| 2026-11-21 | Doc | `README.md` "Reliable Recovery After Host/Daemon Restart" (L170-190) | Documented recovery | Documents stale lock/socket recovery and a manual command for older containers; nothing about the socket directory. | Docs sync |
| 2026-11-21 | Code | superrepo `autobyteus-server-ts/docker/Dockerfile.monorepo` L3-6, L73; `system-level.json`; `build.sh` `base_image_digest` | How the server image uses the base | Runtime stage is `FROM autobyteus/chrome-vnc@${BASE_IMAGE_DIGEST}`, pinned by digest: default `sha256:b2fde77f…96f4` (= `1.4.1`), zh `sha256:19d4c016…9a67` (= `1.4.1-zh`), per `tickets/done/chromium-keyring-prompt/release-notes.md`. `check-system-level.mjs` keeps the Dockerfile default equal to `baseImages.default`. | Release instructions |
| 2026-11-21 | Code | superrepo `autobyteus-server-ts/docker/entrypoint.sh`, `supervisor-autobyteus-server.conf` | Server-image overrides | Server entrypoint writes the data `.env`, then `exec /entrypoint.sh` (the base's). It adds the `autobyteus_server` program (`user=root`). It does not override `start-vnc.sh`, `base.conf` or the X setup. | No server change |
| 2026-11-21 | Doc | superrepo `docs/isolated-app-instances.md` L318-320, L409-477; `TESTING.md` L400-414 | Who runs root X servers in a node | The supported recipe for agents in a root-only Linux container runs `xvfb-run -a` (an X server, as root, on the first free display ≥ :99). Agents in a node run as root (`autobyteus_server` `user=root`). | Scenario basis (SCN-002) |
| 2026-11-21 | Code | superrepo `rg` for `Xvnc|Xvfb|vncserver|DISPLAY=:1xx` outside tickets | Code that starts extra X servers | No product code starts `:102`/`:103`; they come from agent activity in the node (root commands), not from the image. | — |
| 2026-11-21 | Runtime | `docker ps` (read-only listing) | Safety | Founder containers `autobyteus-server-0/1/2` (`autobyteus/autobyteus-server:beta`) running; not inspected, exec'd or restarted. | — |

## Relevant Existing Behavior And Supported Product Paths

| Behavior ID | Kind | Supported Trigger Or Governing Contract | Current Supported Product Behavior Path / Lifecycle | Current Outcome / Invariants | Evidence | Confidence / Unknown |
| --- | --- | --- | --- | --- | --- | --- |
| BEH-001 | Operational | Fresh container start | entrypoint (root) → supervisord → start-vnc.sh (vncuser) owns the vncuser-owned dir, chmods, execs `Xvnc :99` → dependants start | All programs `RUNNING` | Probe "fresh start" on beta: `ALL RUNNING` | High |
| BEH-002 | Operational | A root X server runs in the node (agent `xvfb-run`, or `Xvnc :102`) | The X server (xtrans) takes the socket directory over: owner becomes `root:root`, mode stays 1777 | Dir `root:root 1777` from then on; `/tmp` persists across `docker restart` | Reproduced: `ls -ld` before `vncuser vncuser`, after `root root` | High |
| BEH-003 | Operational | Container restart after BEH-002 (`docker restart`, daemon restart, `restart: unless-stopped`) | entrypoint clears `:99` artifacts → start-vnc.sh `chmod` EPERM → exit 1, 20 retries → `tigervnc` BACKOFF/FATAL; `xfce`, `chrome`, `copyq` `FATAL` | Node desktop is down until someone repairs it by hand | Reproduced (control) | High |
| BEH-004 | Operational | Supervisor restarts Xvnc in a running container after BEH-002 (Xvnc crash or `supervisorctl restart tigervnc`) | Same EPERM path, no container restart needed | tigervnc `BACKOFF` | Reproduced (control, "in-life") | High |
| BEH-005 | Operational | Abrupt stop leaves `/tmp/.X99-lock` and `/tmp/.X11-unix/X99` | entrypoint removes both at start; start-vnc.sh removes them when the lock's PID is not a live X server, and refuses to start a duplicate otherwise | Desktop recovers | `entrypoint.sh` L94-97, `start-vnc.sh` L12-22, README | High |

## Relevant Codebase And Technical Facts

| Path / Component / Contract | Current Responsibility Or Behavior | Requirement Implication | Architecture Question / Design Implication |
| --- | --- | --- | --- |
| `entrypoint.sh` | Root container-start preparation of shared runtime state (supervisor dir, XDG dir, Chromium locks, dbus, stale X artifacts) | The one place that runs as root at every start | Owner of the socket directory's container-start state |
| `start-vnc.sh` | vncuser launcher of `Xvnc :99`, also run on every Supervisor restart | Must not fail on a directory it does not own | Keep only what vncuser can do; check usability |
| `Dockerfile` L184-189 | Build-time directory, owned by vncuser | Fresh and restarted containers should have the same state | Align with the container-start state |
| libxtrans (X server socket setup) | Running as root, it sets the socket directory's owner to root when another user owns it; mode 1777 kept | Root ownership is the X convention; a root X server in the node will always produce it | Make root:root 1777 the image's state rather than fight it |

## Structural And Payload Surface Inventory

### Payload Or Content Surfaces

- Files: `start-vnc.sh`, `entrypoint.sh`, `Dockerfile`, `tests/*.sh`, `README.md`, `VERSION`.
- Readers/contracts: Supervisor (`base.conf`) runs `start-vnc.sh`; the server image runs `/entrypoint.sh` via its own entrypoint.

### Structural Surfaces

- Deployment configuration only (container image scripts). No API, persistence, security boundary or ownership-boundary change.

### Potential Structural Impacts To Investigate

- API or external-contract change: Absent.
- Persistence schema or invariant change: Absent (`/tmp` is the container's writable layer, not a volume).
- Security or privacy boundary change: Absent. Ownership root:root 1777 is the standard X setting; it widens nothing (mode 1777 already).
- Concurrency or lifecycle change: Absent beyond container start.
- Deployment change: a new base image version; the server image picks it up only through a digest bump and rebuild (release-gated).

## Runtime, Probe, Or Reproduction Findings

All in throwaway containers labelled `autobyteus-596=throwaway`, removed after use. Image `autobyteus/autobyteus-server:beta` (local, `52db87304cc4`, built on base `1.4.1`; its `start-vnc.sh` and `entrypoint.sh` match origin/main).

| Method / Command | Scenario | Observation | Established | Requirement Implication | Artifact / Evidence Path |
| --- | --- | --- | --- | --- | --- |
| `docker run --rm --entrypoint bash …beta -c 'ls -ld /tmp/.X11-unix'` | Built state | `drwxrwxrwt vncuser vncuser` | Reproduced | — | — |
| `docker exec <c> Xvnc :102 …` as root in a running container | BEH-002 | dir becomes `drwxrwxrwt root root`; `X102` root socket next to `X99` | Reproduced | Root takeover is a normal consequence of any root X server | `probe/x11-takeover-restart-probe.sh` |
| `docker restart <c>` after takeover (no caps flags, first run) | BEH-003 | `supervisord.log`: `chmod: changing permissions of '/tmp/.X11-unix': Operation not permitted`, `exited: tigervnc (exit status 1; not expected)`; tigervnc BACKOFF, xfce/chrome/copyq FATAL | Reproduced | Matches the live incident exactly | — |
| `probe/x11-takeover-restart-probe.sh autobyteus/autobyteus-server:beta x11-596-control` (with `--cap-add SYS_ADMIN --security-opt seccomp=unconfined`) | BEH-003, BEH-004 (control) | fresh start ALL RUNNING; in-life tigervnc `BACKOFF`; after restart tigervnc BACKOFF, xfce/chrome/copyq FATAL; 24 chmod failure lines | Reproduced | Both the restart and in-life paths fail | — |
| Same probe on a prototype overlay image (`FROM beta` + prototype `start-vnc.sh` that chmods only when it owns the dir and checks it is a writable sticky dir, + `entrypoint.sh` that sets `root:root 1777` at start) | Fix feasibility | fresh start ALL RUNNING, dir `root root 1777`; after takeover, in-life restart tigervnc `RUNNING`; after `docker restart` ALL RUNNING; 0 chmod failures | Reproduced | The design is feasible; both paths recover | `/tmp/autobyteus-596/proto/` (scratch; removed at cleanup) |
| Prototype image: takeover, then `pkill -u vncuser -x Xvnc`, wait 40 s | BEH-004 desired | all 9 programs `RUNNING` (xfce, chrome, copyq restarted by Supervisor too) | Reproduced | AC-003 can require the whole desktop | — |
| Prototype image: takeover, `docker kill -s KILL`, `docker start` | BEH-005 after takeover | all programs `RUNNING`; dir `root root 1777`; stale root `X102` socket remains, harmless | Reproduced | AC-004 feasible | — |
| Unfixed beta: takeover, restart (desktop FATAL), then `docker exec <c> sh -c 'chown vncuser:vncuser /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix && supervisorctl restart tigervnc xfce chrome copyq'` | DEC-005 recovery for running older nodes | all programs `RUNNING` within 30 s | Reproduced | The README recovery command works | — |

- Note: Chromium needs `--cap-add SYS_ADMIN --security-opt seccomp=unconfined` (as `run-container.sh` and the server compose file use); without them it fails namespaces independently of this bug. Test containers must use these flags.
- Temporary diagnostics: None in the repo. Scratch prototype in `/tmp/autobyteus-596/` (removed at cleanup), throwaway image `autobyteus-596-proto:local` (removed at cleanup).
- Reproduction for implementation to start from: `tickets/in-progress/x11-unix-restart/probe/x11-takeover-restart-probe.sh IMAGE NAME` and `probe/server-overlay.Dockerfile`.

## Stakeholder And User Evidence

| Source / Actor | Need, Problem, Or Constraint | Evidence Strength | Requirement Implication | Open Question |
| --- | --- | --- | --- | --- |
| Founder (via Task) | Node desktop must survive container restarts | Live incident on `autobyteus-server-0` | REQ-001 | None |
| Founder (via Task) | Throwaway containers only; no push without his word | Explicit | Verification intent, release gate | None |

## External Contracts, Standards, And Dependencies

| Contract / Dependency | Version / Authority | Relevant Behavior Or Constraint | Evidence | Unknown / Risk |
| --- | --- | --- | --- | --- |
| X server socket directory convention (libxtrans) | TigerVNC `Xvnc` in Ubuntu 24.04 | Root X server sets the directory owner to root; any X server needs it sticky world-writable; a non-root server works in a root-owned 1777 directory | Reproduced (takeover; prototype vncuser Xvnc in root dir) | None |
| Linux `chmod(2)` | — | Only the owner (or CAP_FOWNER) may change mode; else EPERM | Reproduced | None |
| Docker `restart` | Docker 29.0.1 | Keeps the container's writable layer, so `/tmp` state persists | Reproduced | None |

## Persisted Data And State Facts

- Affected stored subject: none persisted; `/tmp` in the container's writable layer only. Volumes (Chromium profile, data) untouched.

## Product Design Request Context

- Product Design request in the current input: `Not stated`. N/A.

## Product Design Findings

N/A — not applicable.

## Supplemental Artifact Inventory

| Artifact Path | Owner | Purpose | Scope | Related Requirement / AC IDs | Status | Approval Applicability / State |
| --- | --- | --- | --- | --- | --- | --- |
| `probe/x11-takeover-restart-probe.sh` | Solution Designer | Reproduction and restart proof driver (throwaway containers) | Validation input | AC-002, AC-003, AC-006 | Current | Evidence tool, no approval needed |
| `probe/server-overlay.Dockerfile` | Solution Designer | Throwaway server-composition test image | Validation input | AC-006 | Current | Evidence tool, no approval needed |

## Assumptions, Unknowns, And Risks

| ID | Type | Description | Why It Matters | Resolution / Owner | Status |
| --- | --- | --- | --- | --- | --- |
| RSK-001 | Risk | amd64 not exercised locally (host is arm64) | Release is multi-arch | Changed files are shell scripts with no architecture-specific behavior; DEC-003 | Accepted |
| RSK-002 | Risk | `zh` variant not rebuilt locally | Release ships both variants | Same scripts in both variants; release build validates; DEC-003 | Accepted |
| UNK-001 | Unknown | Exact command that started `:102`/`:103` on `autobyteus-server-0` | Only explains the trigger | Not needed: any root X server produces the state (reproduced); founder containers are off limits | Closed |

## Architecture Investigation Findings

- Entry points and lifecycle: container start → `/entrypoint.sh` (root; the server image's entrypoint hands over to it) → `exec supervisord` (PID 1) → programs by priority; `tigervnc` (priority 100) runs `start-vnc.sh` as vncuser on every (re)start.
- Owners: the base image owns the whole desktop stack, including the X socket directory. The server image adds nothing X-related. So the fix is entirely in `browser_docker`.
- Root cause: two owners disagree about the directory. The image hands it to vncuser and its vncuser launcher insists on changing its mode; the X convention (and every root X server) makes it root's. The launcher's mode change is the only step that needs ownership, and it is unnecessary when the directory is already 1777.
- In-life path (BEH-004) means a container-start fix alone is not enough: `start-vnc.sh` must itself tolerate a root-owned directory.
- Stale socket without a lock: not handled by `start-vnc.sh` today, but the X server replaces a leftover socket of its own display when binding, and the entrypoint clears `X99` at every start; no reproduction of a failure. Not changed (preserved).

## Requirement Implications

- The live failure is fully reproduced in both paths, and the prototype shows the intended outcome is reachable without touching any other program or the server image.
- Verification is feasible locally with real Docker and throwaway containers (Docker Desktop 29.0.1, arm64); no privileged host change, no registry push.

## Notes For Architecture Design

- Make `root:root 1777` the single defined state of `/tmp/.X11-unix` (X convention), established at build and at every container start by root.
- `start-vnc.sh` changes the mode only when it owns the directory; otherwise it checks the directory is writable and sticky and reports a clear error if not.
- Keep the `:99` stale lock/socket handling as is.
- Server image: no source change now. After a founder-approved base release, the superrepo bumps `system-level.json` `baseImages` (both variants), the `Dockerfile.monorepo` default digest and `systemInputsSha256`, then rebuilds/publishes the server image. That is release work, gated on the founder's word.
