# API/E2E + Executable Validation

## Scenarios

| ID | Covers | Command / Method | Result | Evidence |
| --- | --- | --- | --- | --- |
| AV-001 | AC-001, AC-003 | `bash -n entrypoint.sh` | Passed | Entrypoint shell syntax is valid |
| AV-002 | AC-001, AC-003, AC-006 | Extracted `entrypoint.sh` helper into a shell test with a stale `SingletonLock` pointing at missing PID | Passed | Known lock artifacts removed; `Default/keep.txt` remained |
| AV-003 | AC-002, AC-006 | Extracted helper with `SingletonLock` pointing at current non-Chromium shell PID | Passed | Lock artifacts removed because argv0/comm were not Chromium/Chrome |
| AV-004 | AC-002, AC-006 | Extracted helper with `SingletonLock` pointing at simulated live Chromium argv0 | Passed | Lock artifacts preserved |
| AV-005 | AC-003 | `docker compose -f docker-compose.yml config` | Passed | Existing Compose rendering still succeeds; Docker emitted the existing obsolete `version` warning |
| AV-006 | AC-003 | `docker compose -f docker-compose.chrome-vnc.yml config` | Passed | Existing Chrome-VNC Compose rendering still succeeds |
| AV-007 | AC-001, AC-003, AC-005, AC-006 | Built `autobyteus/chrome-vnc:profile-lock-recovery-test`, mounted a throwaway profile volume seeded with stale Chromium lock artifacts, and started a real container from the patched image | Passed | Entrypoint logged stale lock cleanup; `chrome`, `tigervnc`, `xfce`, and `websockify` reached RUNNING |
| AV-008 | AC-001, AC-002, AC-006 | Inspected the running AV-007 container profile after Chromium startup | Passed | `SingletonLock` no longer pointed at `old-container-999999`; it pointed at live local `chromium` PID; `Default/keep.txt` survived; stale `.org.chromium.Chromium.test` was removed |

## Acceptance Criteria Closure

| Acceptance Criterion | Status | Evidence |
| --- | --- | --- |
| AC-001 | Passed | AV-002, AV-007, AV-008 |
| AC-002 | Passed | AV-003, AV-004 |
| AC-003 | Passed | AV-001, AV-005, AV-006, AV-007 |
| AC-004 | Passed | `README.md` updated; Stage 9 will re-check docs truthfulness |
| AC-005 | Passed | `entrypoint.sh` runs helper before Supervisor; AV-007 image-level startup proved the ordering |
| AC-006 | Passed | AV-002, AV-003, AV-004, AV-007, AV-008 |

## Notes

The image-level validation used a throwaway container, Docker volume, and local image tag. All three were removed after verification.
