# Follow-Up Ticket Brief: AutoByteus Server Adoption Of New Browser Base

## Status And Ownership

- Candidate package ID: `AUT-SERVER-BROWSER-BASE-ADOPTION-001`
- Status: `Deferred — blocked on verified browser-image publication`
- Owner when activated: A new Requirements Engineering task for the AutoByteus server/all-in-one repository workspace.
- Governing upstream package: `BRD-UBUNTU24-001` (`RER-007`, public Python 3.13 target)
- Activation gate: Upstream AC-011 passes and exact immutable default/`zh` tags, manifest digests, and runtime identities are recorded.
- This brief is intake context only. It is not authorization to change AutoByteus server or all-in-one source during the browser-image ticket.

## Required Upstream Identity At Activation

The later ticket may activate only against the verified BRD-UBUNTU24-001 publication:

- Canonical Ubuntu 24.04 LTS base.
- Immutable tags `autobyteus/chrome-vnc:1.4.0` and `autobyteus/chrome-vnc:1.4.0-zh`, with applicable rolling `latest` and `zh` tags verified against the intended manifests.
- Manifest coverage for `linux/amd64` and `linux/arm64`.
- Public `python3` and `python` developer commands reporting Python 3.13.
- Supervisor 4.3.0 running through the browser image's stable `/usr/local/bin/supervisord` boundary, with websockify and `uv` supplied by the isolated Python 3.13 operational-tools environment.
- Passed browser/VNC/websockify/DevTools, configured-identity, locale/input, profile/recovery, and applicable release checks from AC-001 through AC-011 and AC-013.

Noble's distribution-owned `/usr/bin/python3` may remain Python 3.12 internally by design. It is not the inherited public developer-runtime target and must not be mistaken for an adoption failure.

## User-Requested Sequence

1. Complete, validate, version, and publish the Ubuntu 24.04/public Python 3.13/Supervisor 4.3.0 browser image from the dedicated browser-image ticket.
2. Verify the new default and `zh` Docker Hub manifests for AMD64 and ARM64, record immutable identities, and verify the public runtime/tool identity from the published images.
3. Start a separate AutoByteus server requirements/design/implementation ticket using those verified identities.

## Read-Only Consumer Evidence

| Consumer Surface | Current Behavior | Follow-Up Question / Validation Need |
| --- | --- | --- |
| `autobyteus-server-ts/docker/Dockerfile.monorepo` | Runtime extends `autobyteus/chrome-vnc:${BASE_IMAGE_TAG}` with `BASE_IMAGE_TAG=latest`. | Decide whether the default should pin `1.4.0`/a digest or retain `latest`; build and validate inherited Ubuntu 24.04, public Python 3.13, Supervisor 4.3.0, and full server behavior. |
| `autobyteus-server-ts/docker/build.sh` and `build-multi-arch.sh` | Pass default or variant tags into `BASE_IMAGE_TAG`. | Preserve default/`zh` release behavior while making adoption reproducible. |
| `.github/workflows/release-server-docker.yml` | Multi-arch server release uses the default browser base for normal builds and `BASE_IMAGE_TAG=zh` for Chinese builds. | Ensure the release workflow consumes the approved browser identity and validates both platforms and both inherited variants. |
| `docker/Dockerfile.allinone` | Runtime extends `autobyteus/chrome-vnc:${CHROME_VNC_TAG}` with default `zh`. | Adopt and validate the verified `1.4.0-zh`/digest identity independently of the server-only image. |
| `docker/compose.personal-test.yml` | Defaults `AUTOBYTEUS_CHROME_VNC_TAG` to `zh`. | Confirm the intended local/personal default after the separate pinning decision. |
| `scripts/tests/test_server_docker_browser_bridge.py` | Asserts the server Dockerfile's `latest` default and browser bridge contract. | Update only if the approved follow-up changes the default tag; preserve bridge behavior. |

## Proposed Follow-Up Scope

- Consume the verified `1.4.0` default and `1.4.0-zh` browser-base artifacts, or their approved immutable digests, in server-only and all-in-one Docker builds.
- Decide and document immutable-version/digest pinning versus current moving-tag defaults.
- Rebuild server images for AMD64 and ARM64 with a fresh base pull and verify inherited Ubuntu 24.04, public Python 3.13, and Supervisor 4.3.0 identity.
- Validate server startup, browser/VNC bridge, CLI tooling, persistent volumes, default/`zh` behavior, websockify/DevTools reachability, and release workflow behavior.
- Confirm that server startup does not reproduce the historical Python 3.13 `pkgutil.ImpImporter` Supervisor failure.
- Update affected tests and documentation only as required by the separately approved adoption policy.

## Proposed Non-Goals

- Re-implementing Ubuntu, Python, Supervisor, websockify, or `uv` setup in downstream Dockerfiles.
- Treating Noble's internal `/usr/bin/python3` 3.12 as the downstream public developer runtime.
- Starting server changes before the browser image is available and verified on Docker Hub.
- Combining unrelated server feature work with base-image adoption.
- Using this brief as source-change authorization; the follow-up requires its own approved requirements/design package and dedicated worktree.

## Required Intake Evidence

- Upstream package ID, final delivery result, and approval/review/API-E2E revision identities.
- Exact `autobyteus/chrome-vnc:1.4.0` and `autobyteus/chrome-vnc:1.4.0-zh` manifest digests plus per-platform digests; verified mapping of rolling `latest`/`zh` when applicable.
- Published-image evidence for Ubuntu 24.04, public Python 3.13, Supervisor 4.3.0, isolated websockify/`uv`, and stable operational paths on AMD64 and ARM64.
- Evidence that published images pass browser/VNC/websockify/DevTools, configured-identity, locale/input, and profile/recovery checks.
- Rollback identity for the prior browser image.
- User decision on downstream pinning policy if not already approved in the new ticket.
