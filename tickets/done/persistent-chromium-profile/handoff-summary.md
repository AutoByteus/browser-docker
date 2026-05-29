# Handoff Summary

## Engineering Result

Implemented persistent Chromium profile support for browser-docker launch paths.

Changed:

- `docker-compose.yml` mounts a named volume at `/home/vncuser/.config/chromium`.
- `docker-compose.chrome-vnc.yml` mounts a named volume at `/home/vncuser/.config/chromium`, with `CHROME_VNC_PROFILE_VOLUME` override support.
- `run-container.sh` mounts a persistent profile volume by default and supports `--profile-volume`.
- `entrypoint.sh` ensures mounted profile volumes are writable by `vncuser` before Chromium starts.
- `README.md` documents profile persistence, override usage, downstream image requirements, and Google re-auth limitations.

## Validation

- `bash -n run-container.sh && bash -n entrypoint.sh`
- `docker compose -f docker-compose.yml config`
- `docker compose -f docker-compose.chrome-vnc.yml config`
- Stubbed `run-container.sh` execution confirmed the rendered `docker run` command includes `-v test-profile-volume:/home/vncuser/.config/chromium`.

## Residual Risk

Google can still force password or two-factor re-authentication due to account-security policy. This change prevents local Docker profile loss from container recreation.

## Release Notes

Release notes are recorded in `release-notes.md` for the `1.3.5` Docker image release.

## User Verification Hold

Stage 10 remains open. Per workflow rules, the ticket stays in `tickets/in-progress/` until explicit user verification/completion.
