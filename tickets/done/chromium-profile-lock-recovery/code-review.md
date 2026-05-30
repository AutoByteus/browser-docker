# Code Review

## Decision

Pass.

## Findings

No blocking findings.

## Review Checks

| Check | Result | Notes |
| --- | --- | --- |
| Correct ownership boundary | Pass | `entrypoint.sh` owns startup profile preparation; Supervisor and Chromium ownership remain unchanged. |
| Data-loss risk | Pass | Cleanup removes only known lock artifacts; profile data directories and user files are not touched. |
| Live-lock safety | Pass | Lock is preserved only when PID exists and `/proc` identity appears Chromium/Chrome via `comm` or argv0 basename. |
| PID reuse handling | Pass | Non-Chromium live PID test passed; full cmdline is not scanned, avoiding false positives from shell arguments. |
| Source size | Pass | `entrypoint.sh` effective non-empty lines: 86; `README.md`: 121; both below hard limits. |
| Validation sufficiency | Pass | Shell syntax, extracted-helper behavior cases, Compose rendering, and a real patched-image startup with stale profile locks cover the changed startup behavior. |
| Backward compatibility / legacy retention | Pass | Existing profile path, ports, run scripts, and supervisor process names remain unchanged. |
| Docs truthfulness | Pass | README describes automatic recovery and manual fallback for older containers. |

## Scorecard

Overall: 9.4 / 10, 94 / 100.

| Category | Score | Rationale |
| --- | --- | --- |
| Correctness | 9.5 | Covers stale, non-Chromium live PID, and live Chromium paths. |
| Safety | 9.5 | Does not remove profile data and avoids generic PID liveness assumptions. |
| Scope control | 9.5 | Focused entrypoint/docs change only. |
| Maintainability | 9.0 | Shell helper is small and named around its responsibility. |
| Integration | 9.5 | Fits existing entrypoint startup ordering before Supervisor. |
| Test quality | 9.5 | Direct shell behavior tests cover risky branches, and image-level validation proves entrypoint ordering in a real container. |
| Documentation | 9.0 | README covers user-facing failure and recovery. |
| Simplicity | 9.5 | No new dependencies or profile path migration. |
| File placement | 9.5 | Base-image startup behavior stays in the base-image repo. |
| Release readiness | 9.0 | Requires image rebuild/release for downstream users to inherit the fix. |

## Residual Risk

The local image-level validation used the default variant. The code path is variant-independent, so the `zh` variant should inherit the same entrypoint behavior, but a separate `zh` image build was not run.
