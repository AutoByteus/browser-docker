# Release Notes

- Release version: `1.4.0` / `1.4.0-zh`
- Rolling tags: `latest` / `zh`
- Publication status: `Completed and remotely verified` on 2026-09-02.
- Source/release input commit: `18bb92e2c9784a4222ff734ffd47d89d877b5c59`.
- Default index (`1.4.0`, `latest`): `sha256:cb49a54d8e745a45351ecab1e5f47db0eee71b30ab2e15e8c3745b91f2941af1`.
  - `linux/amd64`: `sha256:9cf057cce95cf6624eff5142424754135aac2298af3a70146807f941ed0b4ba1`
  - `linux/arm64`: `sha256:2ee3f7665f8bc663f29474e1c211fd9080149f83e56a071a7a03d7578685a345`
- `zh` index (`1.4.0-zh`, `zh`): `sha256:597c8702e0a2418078aca64a7f4bc19e2a26af277af119a893d51a9215837c48`.
  - `linux/amd64`: `sha256:7e35ac854ea8609a033222ce552a4ebe956a781926af2f1fd50c77acfd972e4f`
  - `linux/arm64`: `sha256:7cba7bf2be52a4c613c74237a1774244c7feced9637785882025975fd83d38f6`
- Upgrade the image base from Ubuntu 22.04 to Canonical's official minimal Ubuntu 24.04 LTS OCI image.
- Expose Python 3.13 as the supported public developer runtime while preserving Noble's distribution-owned Python 3.12 for operating-system tools.
- Run Supervisor 4.3.0, websockify, and `uv` from one isolated Python 3.13 environment under `/opt/browser-tools` with stable `/usr/local` command and asset paths.
- Preserve AMD64/ARM64, default/`zh`, configured UID/GID, Chromium/XFCE/TigerVNC, websockify, remote debugging, GitHub CLI, Node.js 22, Yarn, locale/input, mobile-safe startup, and persistent-profile/recovery behavior.
- Recognize both `arm64` and `aarch64` Apple Silicon host spellings in the supported local build wrapper.
- Published runtime identity passed for all four exact platform/variant child digests: Ubuntu 24.04, public Python 3.13.15, Noble OS Python 3.12.3, and Supervisor 4.3.0.
- AutoByteus server-image adoption is intentionally separate and may now use the immutable identities above as its dependency input.
