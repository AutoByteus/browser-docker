# Release Deployment Report

## User Verification

User explicitly confirmed finalization after reviewing the solution and validation approach.

## Repository Finalization Plan

| Repository | Target Branch | Ticket Branch | Result |
| --- | --- | --- | --- |
| `browser-docker` | `main` | `codex/chromium-profile-lock-recovery` | Ticket archived; commit pending |

## Release Plan

- Release target: Docker Hub base images
- Release mechanism: documented `build-multi-arch.sh --push`
- Version: `1.3.6`
- Planned tags:
  - `autobyteus/chrome-vnc:1.3.6`
  - `autobyteus/chrome-vnc:latest`
  - `autobyteus/chrome-vnc:1.3.6-zh`
  - `autobyteus/chrome-vnc:zh`

## Downstream Note

`autobyteus/llm-server` uses `FROM autobyteus/chrome-vnc:zh`, so it needs a rebuild/release after the `zh` base tag is published. Existing `autobyteus/llm-server:v1.0.14` will not automatically pick up the new base image.
