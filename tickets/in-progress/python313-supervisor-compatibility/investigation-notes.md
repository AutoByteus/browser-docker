# Investigation Notes

## Root Cause

The server restart loop occurs before the Node.js server starts. The server entrypoint delegates to the browser base entrypoint, which launches Ubuntu 22.04's `/usr/bin/supervisord` from `supervisor==4.2.1`. That Supervisor version imports the Ubuntu `pkg_resources` implementation and accesses `pkgutil.ImpImporter`, which is unavailable in Python 3.13.

Evidence:

- `docker logs autobyteus-server-0` ends with `AttributeError: module 'pkgutil' has no attribute 'ImpImporter'`.
- `autobyteus/chrome-vnc:1.3.6` (Python 3.11) runs `/usr/bin/supervisord --version` successfully as `4.2.1`.
- `autobyteus/chrome-vnc:latest` (Python 3.13) fails the same command with the traceback above.
- Installing `supervisor==4.3.0` in a disposable Python 3.13 container and launching the real `/etc/supervisor/supervisord.conf` kept Supervisor running; only the expected test-container Chromium namespace restriction appeared.

## Decision

Keep Python 3.13, install `supervisor==4.3.0` with pip, and launch `/usr/local/bin/supervisord` explicitly. Reverting Python to 3.11 is unnecessary for this failure.
