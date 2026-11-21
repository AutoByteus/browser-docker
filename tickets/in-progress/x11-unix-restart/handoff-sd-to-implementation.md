# Handoff: Solution Designer → Implementation Engineer

- Result: `Architecture Design Complete`, `task_size=Small`, `architectural_risk=Low`. Direct implementation route (handoff rule: Small/Medium and Low → `/implementation_engineer`). Architecture review not selected.
- Task: Project Task `autobyteus-596` (Project `project_a1377344-25db-482a-97cc-ecfdb0fb495a`), from `/project_task_manager`.
- Repository: `browser_docker` (the `autobyteus/chrome-vnc` base image). There is no superrepo change in this ticket (DEC-004).
- Worktree: `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart`
- Branch: `codex/x11-unix-restart`. It currently tracks `origin/main`; push to `origin codex/x11-unix-restart` explicitly, never to main.
- Base: `origin/main` @ `ef63a4670e7441274bcb577b1cab6b6cc140ef88`. Finalization target: `origin/main`.
- Ticket folder: `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart/tickets/in-progress/x11-unix-restart/`

## Read

- `requirements-doc.md` (Approved, SR-001): REQ-001..REQ-007, AC-001..AC-009, DEC-001..DEC-006.
- `design-spec.md`: exact changes per file (Target Subsystem / Folder / File Mapping), the launcher block (Concrete Examples), and the change sequence.
- `investigation-notes.md`: reproduction, prototype results, and the tested README recovery command.
- `solution-revision-record.md`, `follow-ups.md` (FU-001, not for this ticket).
- `/Users/normy/autobyteus_org/autobyteus-worktrees/browser-docker-x11-restart/DESIGN.md`: created in this ticket, committed with the solution documents (commit below).

## The change in short

1. `entrypoint.sh`: at every start, as root, put `/tmp/.X11-unix` in the `root:root 1777` state, before the stale `:99` cleanup.
2. `start-vnc.sh`: replace the unconditional `chmod`. Create the directory if it is missing, change its mode only when vncuser owns it, otherwise check it is writable and sticky, or exit 1 with the message.
3. `Dockerfile`: stop chowning `/tmp/.X11-unix` to vncuser.
4. Tests:
   - new `tests/validate-restart-recovery.sh` (label-guarded; takeover → in-life → restart → kill/start, reusing `validate-running-container.sh`);
   - additions to `validate-image.sh` and `validate-source-contract.sh`.
5. README recovery section, including the older-image recovery command; `VERSION` `1.4.2`.

## Hard constraints

- **Never touch `autobyteus-server-0`, `-1`, `-2`.** Throwaway containers only, labelled `chrome-vnc.test=throwaway`, run with `--cap-add SYS_ADMIN --security-opt seccomp=unconfined`.
- **No push to Docker Hub** and no `--push` builds. Release only on the founder's word.
- Reproduction to turn green: `probe/x11-takeover-restart-probe.sh IMAGE NAME` (with `probe/server-overlay.Dockerfile` for the server composition, AC-006).
- Control image available locally: unfixed base `autobyteus/chrome-vnc@sha256:b2fde77f3bd7c73d412ea59d42e3b65290bae9f39d1ce85b5aaaac5d869596f4` (1.4.1); server image `autobyteus/autobyteus-server:beta`.
- The repository has no `TESTING.md` or `RELEASE.md`: API/E2E creates `TESTING.md`, delivery creates `RELEASE.md` (team project-documents rule).
- Scratch left by the Solution Designer, to remove at ticket cleanup:
  - `/tmp/autobyteus-596/` (prototype);
  - image `autobyteus-596-proto:local`;
  - pulled base `autobyteus/chrome-vnc@sha256:b2fde77f…` (keep it until the AC-007 control has run).
