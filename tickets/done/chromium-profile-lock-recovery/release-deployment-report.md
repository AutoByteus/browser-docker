# Release Deployment Report

## User Verification

User explicitly confirmed finalization after reviewing the solution and validation approach.

## Repository Finalization Plan

| Repository | Target Branch | Ticket Branch | Result |
| --- | --- | --- | --- |
| `browser-docker` | `main` | `codex/chromium-profile-lock-recovery` | Committed as `3951af5`, pushed to ticket branch, fast-forward merged to `origin/main`, and local ticket worktree/branch cleaned up |

## Release Plan

- Release target: Docker Hub base images
- Release mechanism: documented `build-multi-arch.sh --push`
- Version: `1.3.6`
- Planned tags:
  - `autobyteus/chrome-vnc:1.3.6`
  - `autobyteus/chrome-vnc:latest`
  - `autobyteus/chrome-vnc:1.3.6-zh`
  - `autobyteus/chrome-vnc:zh`

## Release Result

Published Docker Hub images with `./build-multi-arch.sh --push` and `./build-multi-arch.sh --variant zh --push`.

The first `zh` publish attempt finished the build/export step but then hung before the version tag appeared in Docker Hub. It was cancelled after confirming the Docker/BuildKit process was idle and `autobyteus/chrome-vnc:1.3.6-zh` was not published. A cache-backed rerun completed successfully and published both `zh` tags.

| Tag | Manifest Digest | Platforms Verified |
| --- | --- | --- |
| `autobyteus/chrome-vnc:1.3.6` | `sha256:dbd749ca4bcbdab7fefc48b2f2fa2741e24e5919b6078596ec59b41ab77f1daa` | `linux/amd64`, `linux/arm64` |
| `autobyteus/chrome-vnc:latest` | `sha256:dbd749ca4bcbdab7fefc48b2f2fa2741e24e5919b6078596ec59b41ab77f1daa` | `linux/amd64`, `linux/arm64` |
| `autobyteus/chrome-vnc:1.3.6-zh` | `sha256:1e1e1fcd71775fdbf7c682b47a98bb78548f4d78db0dc50ffdd2fd2c9ec2f850` | `linux/amd64`, `linux/arm64` |
| `autobyteus/chrome-vnc:zh` | `sha256:1e1e1fcd71775fdbf7c682b47a98bb78548f4d78db0dc50ffdd2fd2c9ec2f850` | `linux/amd64`, `linux/arm64` |

Remote manifest verification used `docker buildx imagetools inspect` for all four tags after publication.

## Downstream Note

`autobyteus/llm-server` uses `FROM autobyteus/chrome-vnc:zh`, so it needs a rebuild/release after the `zh` base tag is published. Existing `autobyteus/llm-server:v1.0.14` will not automatically pick up the new base image.
