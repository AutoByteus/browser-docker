# Delivery Revision Record

## Revision Index

| Revision ID | Entry Point / Trigger | Prior Result | Current Result | Affected Canonical Artifacts |
| --- | --- | --- | --- | --- |
| DR-001 | Release Requested (Solution Designer, the founder's word, 2026-11-21) | N/A | Delivery Completed: chrome-vnc 1.4.2 / 1.4.2-zh published and checked before and after the push; server base pins at level 2 merged to `personal` | `release-deployment-report.md`, `tickets/done/x11-unix-restart/release-notes.md`, `RELEASE.md`, superrepo `tickets/done/chrome-vnc-1.4.2-digests/` |

## Revision Entries

### DR-001 — chrome-vnc 1.4.2 released; server pins bumped

- Delivery round and trigger: release request autobyteus-598.
- Prior authoritative result: N/A
- Current authoritative result:
  - published `1.4.2`/`latest` (`sha256:86b7891d…6a50b`) and `1.4.2-zh`/`zh` (`sha256:c381f2e8…68783`);
  - 12 of 12 checks before the push and 12 of 12 on the published child digests;
  - superrepo `81f6aa8be4` on `personal` (level 2);
  - `RELEASE.md` gains "Checks Before Publishing".
- Release/publication/deployment report: `release-deployment-report.md`
- Terminal return to the Solution Designer: `Sent`
- Next recipient/action: the Solution Designer verifies the package. The server-image rebuild and recreating the nodes are the remaining rollout steps, on the founder's word.
- Remaining blockers, rollback concerns, or untested scope: none blocking. Nodes on level-1 images refuse level-2 packages until they are recreated.
