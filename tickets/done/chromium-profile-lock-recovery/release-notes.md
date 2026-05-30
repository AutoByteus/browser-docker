# Release Notes

- Release version: `1.3.6`
- Recover automatically from stale Chromium profile lock files when a container is recreated with the same persistent profile volume.
- Preserve active Chromium/Chrome profile locks when they belong to a live local browser process.
- Keep browser profile data intact; only known Chromium lock artifacts are removed when stale.
- Document manual lock cleanup for older already-running containers.
