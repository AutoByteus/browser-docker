# Executable Validation

## Checks

- `bash -n entrypoint.sh start-chrome.sh start-vnc.sh build-multi-arch.sh` — passed.
- `git diff --check` — passed.
- Built the actual modified Dockerfile for `linux/arm64` as `autobyteus/chrome-vnc:1.3.8-test` — passed.
- Inside the built image: Python `3.13.14`, `gh 2.4.0`, and Supervisor `4.3.0` — passed.
- Started the actual `/entrypoint.sh` from the built image — passed. Supervisor initialized its RPC interface, remained running, and brought up the configured services. No `pkgutil.ImpImporter` traceback occurred.

The smoke test did not use the production server image; it exercised the exact browser base entrypoint and supervisor configuration that the server delegates to.
