# Docs Sync

## Decision

Pass.

## Updated Docs

- `README.md` now documents automatic stale Chromium profile lock recovery during `/entrypoint.sh` startup.
- `README.md` includes a manual recovery command for already-running older containers that fail with "The profile appears to be in use".

## Truthfulness Checks

| Check | Result | Evidence |
| --- | --- | --- |
| Automatic recovery described | Passed | README states current images clear known stale Chromium lock artifacts before Supervisor launches Chromium. |
| Safety boundary described | Passed | README states locks are preserved when they appear to belong to a live Chromium/Chrome process. |
| Data preservation described | Passed | README states browser profile data is not deleted. |
| Manual fallback documented | Passed | README includes a targeted `rm -f` command for lock artifacts only, followed by `supervisorctl restart chrome`. |
| Ticket artifacts aligned | Passed | Requirements and investigation notes use the same live Chromium/Chrome process safety rule as the implementation. |

## Validation

- `rg -n "Chromium can also leave|profile lock|SingletonLock|The profile appears" README.md tickets/in-progress/chromium-profile-lock-recovery`
- `git diff --check`

No additional long-lived docs outside `README.md` were identified for this base-image startup behavior.
