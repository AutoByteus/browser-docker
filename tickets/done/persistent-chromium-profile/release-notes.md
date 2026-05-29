# Release Notes

## 1.3.5

- Persist Chromium browser profile data in Docker volumes for the provided Compose files and run script.
- Add `run-container.sh --profile-volume` for selecting a long-lived Chromium profile volume.
- Normalize Chromium profile volume ownership at startup so the browser user can write to fresh mounted volumes.
- Document the remaining possibility that Google may still require re-authentication for account-security reasons.

