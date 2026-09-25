# API/E2E Revision Record

The latest `api-e2e-coverage-investigation.md` and `api-e2e-execution-coverage-report.md` are authoritative. This record only locates each API/E2E validation round.

## Revision Index

| Revision ID | Triggering Role / Report / Round | Related Upstream Revision IDs | Prior Result / Confidence | Current Result / Confidence |
| --- | --- | --- | --- | --- |
| API-REV-001 | `implementation_engineer`, `implementation-handoff.md` (IR-001), round 1 | SR-004 (requirements), SR-005 (design), IR-001; ARCH-REV `N/A`; CRR `N/A`; DR `N/A` | N/A | Pass / 95.1% |

## Revision Entries

### API-REV-001 — Initial baseline: keyring-free image validated on default/zh × arm64/amd64

- Triggering role, report path, and round: `implementation_engineer`, `/Users/normy/autobyteus_org/browser_docker-worktrees/chromium-keyring-prompt/requirements/chromium-keyring-prompt/implementation-handoff.md`, round 1 (direct low-risk route, `Small`/`Low`).
- Triggering finding or scenario IDs: N/A (initial validation); scenarios C01–C13.
- Related revision IDs: architecture design SR-005 (requirements SR-004); implementation IR-001 (source `6d4aa75`); architecture review `N/A — not applicable`; code review `N/A — not applicable`; delivery N/A.
- Why this baseline was recorded: first completed API/E2E validation of BRD-KEYRING-PROMPT-001.
- Coverage decisions or durable test paths changed: None by API/E2E. The implementation's durable assertions in `tests/validate-{source-contract,image,running-container,build-wrapper}.sh` were classified `Still Valid`. They were confirmed by 15/15 source mutations plus the wrapper mutation, and by a 1.4.0 negative control in which every new assertion fails.
- Scenarios added, changed, removed, or rechecked: C01–C13 established:
  - repository contracts and mutations
  - 5 clean builds with an identical 3-package removal
  - image and runtime contracts ×5
  - 1.4.0 negative control
  - 4 launch paths ×4 targets
  - external sites
  - operator view and D-Bus audit
  - real libsecret clients
  - two upgrade chains (1.3.8 → 1.4.0 → fixed; typed keyring → fixed)
  - restart, SIGKILL and mobile-safe lifecycle
  - downstream server-layer readiness
- Commands, environment, fixture, or broader-validation delta: Baseline. Host arm64 (M1 Max, Docker Desktop 29.0.1); amd64 under Rosetta. Built with `--no-cache` from a `git archive` of `6d4aa75`. Broader validation was `Required` and executed. Three harness defects were fixed and their cases rerun (build start, exec bit, cookie commit timing); none was a product result.

#### Prior Failure Resolution

None.

- Canonical artifacts and sections updated: `api-e2e-coverage-investigation.md` (new), `api-e2e-execution-coverage-report.md` (new), `api-e2e-test-case-ledger.md` (new), `evidence/api-e2e-rev001-*` (31 logs, 8 screenshots, `api-e2e-rev001-harness/`).
- Prior result and confidence: `N/A`
- Current result and confidence: `Pass`, 95.1%. No category below 90%; every in-scope critical AC directly proven.
- New or remaining failure IDs: None
- Recommended recipient: `/delivery_engineer`. Proportional test-code review `Not Required — direct low-risk route`.
- Remaining risks, blocked evidence, or untested scope:
  - amd64 validated under Rosetta only (no native host).
  - AC-006 (publish, server re-publish, node upgrade) is delivery-owned.
  - Informational, out of approved scope: `gcr` / `pinentry-gnome3` could still show a GPG passphrase prompt; never observed.
  - Optional durable improvements: extend the D-Bus audit to prompter and portal-Secret activations; add a cold `xdg-open` launch to the runtime script.
