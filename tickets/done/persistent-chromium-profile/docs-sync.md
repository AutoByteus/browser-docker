# Docs Sync

## Result

Status: Pass

Updated:

- `README.md`

Coverage:

- Documents that the Chromium profile is persisted in a Docker volume mounted at `/home/vncuser/.config/chromium`.
- Documents `run-container.sh --profile-volume`.
- Documents the residual risk that Google may still require re-authentication.
- Documents that downstream images based on this image need to mount the same path or equivalent persistent browser profile storage.

No separate `docs/` directory exists in this repository, so no additional docs sync is required.

