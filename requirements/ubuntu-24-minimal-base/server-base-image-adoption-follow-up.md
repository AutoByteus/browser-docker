# Follow-Up Ticket Brief: AutoByteus Server Adoption Of New Browser Base

## Status And Ownership

- Candidate package ID: `AUT-SERVER-BROWSER-BASE-ADOPTION-001`
- Status: `Deferred — blocked on verified browser-image publication`
- Owner when activated: A new Requirements Engineering task for `/home/autobyteus/workspace/autobyteus-workspace`
- Governing upstream package: `BRD-UBUNTU24-001`
- Activation gate: Upstream AC-011 passes and exact immutable default/`zh` tags and manifest digests are recorded.
- This brief is not authorization to change AutoByteus server source during the browser-image ticket.

## User-Requested Sequence

1. Complete, validate, version, and publish the Ubuntu 24.04/Python 3.12 browser image from `/home/autobyteus/workspace/browser-docker`.
2. Verify the new default and `zh` Docker Hub manifests for AMD64 and ARM64 and record immutable identities.
3. Start a separate AutoByteus server requirements/implementation ticket using those verified identities.

## Read-Only Consumer Evidence

| Consumer Surface | Current Behavior | Follow-Up Question / Validation Need |
| --- | --- | --- |
| `/home/autobyteus/workspace/autobyteus-workspace/autobyteus-server-ts/docker/Dockerfile.monorepo` | Runtime extends `autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` with `BASE_IMAGE_TAG=latest`. | Decide whether the default should pin the new immutable browser version or retain `latest`; build and validate inherited Ubuntu/Python identity and full server behavior. |
| `autobyteus-server-ts/docker/build.sh` and `build-multi-arch.sh` | Pass default or variant tags into `BASE_IMAGE_TAG`. | Preserve default/`zh` release behavior while making adoption reproducible. |
| `.github/workflows/release-server-docker.yml` | Multi-arch server release uses default base for normal builds and `BASE_IMAGE_TAG=zh` for Chinese builds. | Ensure the release workflow consumes the approved browser identity and validates both platforms. |
| `/home/autobyteus/workspace/autobyteus-workspace/docker/Dockerfile.allinone` | Runtime extends `autobyteus/chrome-vnc:${CHROME_VNC_TAG}` with default `zh`. | Adopt and validate the new `zh` base independently of the server-only image. |
| `docker/compose.personal-test.yml` | Defaults `AUTOBYTEUS_CHROME_VNC_TAG` to `zh`. | Confirm the intended local/personal default after the pinning decision. |
| `scripts/tests/test_server_docker_browser_bridge.py` | Asserts the server Dockerfile's `latest` default and browser bridge contract. | Update only if the approved follow-up changes the default tag; preserve bridge behavior. |

## Proposed Follow-Up Scope

- Consume the verified new default and `zh` browser-base artifacts in server-only and all-in-one Docker builds.
- Decide and document immutable-version/digest pinning versus current moving-tag defaults.
- Rebuild server images for AMD64 and ARM64 with a fresh base pull and verify inherited Ubuntu 24.04/Python 3.12 identity.
- Validate server startup, browser/VNC bridge, CLI tooling, persistent volumes, default/`zh` behavior, and release workflow behavior.
- Update affected tests and documentation only as required by the approved adoption policy.

## Proposed Non-Goals

- Re-implementing Ubuntu or Python setup in downstream Dockerfiles.
- Starting server changes before the browser image is available and verified on Docker Hub.
- Combining unrelated server feature work with base-image adoption.

## Required Intake Evidence

- Upstream package ID and delivery result.
- Exact `autobyteus/chrome-vnc` immutable tags and per-platform digests for default and `zh`.
- Evidence that published images pass Ubuntu/Python identity and browser/VNC/runtime checks.
- Rollback identity for the prior browser image.
- User decision on downstream pinning policy if not already approved.
