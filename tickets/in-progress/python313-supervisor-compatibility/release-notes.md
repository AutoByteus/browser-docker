# Release Notes

## 1.3.8

- Keep Python 3.13 and add Python 3.13-compatible Supervisor 4.3.0.
- Launch the pip-installed Supervisor executable instead of Ubuntu's incompatible 4.2.1 executable.

### Published images

- `autobyteus/chrome-vnc:1.3.8` and `latest`: multi-architecture images for `linux/amd64` and `linux/arm64`.
  Manifest digest: `sha256:f5a12a4fc553d40158b6d6c5f87e3ea0a2bcfbc71e3cb8153f7a3aa310241029`.
- `autobyteus/chrome-vnc:1.3.8-zh` and `zh`: multi-architecture images for `linux/amd64` and `linux/arm64`.
  Manifest digest: `sha256:24ca92cb4a274be088901f679ae9bb31317d2b73c3ab954d2fc8f631e6713071`.

Both variants were smoke-tested with Python 3.13, `gh`, Supervisor 4.3.0, and the actual container entrypoint. Supervisor initialized its RPC interface and entered the running state without the Python 3.13 `pkgutil.ImpImporter` failure.
