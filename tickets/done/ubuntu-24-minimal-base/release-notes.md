# Release Notes

- Release version: `1.4.0` / `1.4.0-zh`
- Planned rolling tags: `latest` / `zh`
- Publication status: Explicitly authorized by the user on 2026-09-02; repository finalization and Docker Hub publication are in progress.
- Upgrade the image base from Ubuntu 22.04 to Canonical's official minimal Ubuntu 24.04 LTS OCI image.
- Expose Python 3.13 as the supported public developer runtime while preserving Noble's distribution-owned Python 3.12 for operating-system tools.
- Run Supervisor 4.3.0, websockify, and `uv` from one isolated Python 3.13 environment under `/opt/browser-tools` with stable `/usr/local` command and asset paths.
- Preserve AMD64/ARM64, default/`zh`, configured UID/GID, Chromium/XFCE/TigerVNC, websockify, remote-debugging, GitHub CLI, Node.js 22, Yarn, locale/input, mobile-safe startup, and persistent-profile/recovery behavior.
- Recognize both `arm64` and `aarch64` Apple Silicon host spellings in the supported local build wrapper.
- Keep AutoByteus server-image adoption out of this release; that work starts only after the browser-image manifests and published runtime identities are verified.
