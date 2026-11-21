# API/E2E Revision Record — autobyteus-596

### API-REV-001 — first validation (IR-001)

- Trigger: implementation engineer, direct route (Small / Low).
- Coverage:
  - source contract with mutations;
  - my own build;
  - the image check;
  - a fresh container;
  - the restart check on the fix and on the 1.4.1 control;
  - the launcher's unusable and missing directory;
  - `xvfb-run` and `supervisorctl restart` takeovers;
  - the duplicate refusal;
  - the server overlay;
  - the README recovery;
  - the build wrapper.
- Result: Pass, 95%. amd64 and `zh` are Accepted Unverified Risk (DEC-003).
- Created: `TESTING.md`.
- Recommended owner: delivery engineer.
