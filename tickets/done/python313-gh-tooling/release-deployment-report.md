# Release Deployment Report

## Release Result

Version `1.3.7` was committed to `main` as `6aa8421` and published to Docker Hub.

| Tag | Manifest digest | Platforms |
| --- | --- | --- |
| `autobyteus/chrome-vnc:1.3.7` | `sha256:a8c17115473bfe0e14c4363e75e88fcb9240e2e71928e03c109e8aea19bcd6cc` | `linux/amd64`, `linux/arm64` |
| `autobyteus/chrome-vnc:latest` | `sha256:a8c17115473bfe0e14c4363e75e88fcb9240e2e71928e03c109e8aea19bcd6cc` | `linux/amd64`, `linux/arm64` |
| `autobyteus/chrome-vnc:1.3.7-zh` | `sha256:946fe61a065ce692d2805a3207cfad4a600d5a1d79ef256beac19ef57285f976` | `linux/amd64`, `linux/arm64` |
| `autobyteus/chrome-vnc:zh` | `sha256:946fe61a065ce692d2805a3207cfad4a600d5a1d79ef256beac19ef57285f976` | `linux/amd64`, `linux/arm64` |

Remote manifests were verified with `docker buildx imagetools inspect`. Both default image architectures were also run to verify Python `3.13.14`, `gh`, and the Python 3.13 `websockify` installation.
