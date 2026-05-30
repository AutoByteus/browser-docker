# Future-State Runtime Call Stack Review

## Round 1

Decision: Blocking update required.

Classification: Design Impact.

Finding:

- The live-lock branch is too broad if it preserves `SingletonLock` only because `/proc/<pid>` exists. PID reuse can make an old lock look live even when the process is unrelated to Chromium. The safety boundary should preserve the lock only when the PID exists and the process command appears to be Chromium/Chrome.

Required updates:

- Update `implementation.md` solution sketch to check live Chromium/Chrome process identity, not only PID existence.
- Update `future-state-runtime-call-stack.md` live-lock branch accordingly.

Missing-use-case sweep:

- Requirement coverage: R-002 requires live Chromium ownership, not generic PID liveness.
- Boundary crossings: entrypoint can inspect `/proc`, but must not infer profile ownership from PID alone.
- Fallback/error branches: malformed lock, absent PID, or non-Chromium PID should be treated as stale.
- Design-risk scenarios: PID reuse is the main stale-lock false-positive risk.

## Round 2

Decision: Candidate Go.

Findings:

- No blockers.
- No new use cases discovered.
- No persisted artifact updates required.

Coverage review:

- Stale lock path is covered.
- Live Chromium lock preservation is covered.
- Non-Chromium PID reuse path is covered.
- Malformed/unresolvable lock target falls back to stale cleanup.
- Profile data preservation boundary is explicit.

## Round 3

Decision: Go Confirmed.

Findings:

- No blockers.
- No new use cases discovered.
- No persisted artifact updates required.

Gate result:

Two consecutive clean rounds were completed after the Round 1 design update. Stage 5 is ready to unlock Stage 6 implementation.
