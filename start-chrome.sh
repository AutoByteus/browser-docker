#!/usr/bin/env bash
set -euo pipefail

chrome_args=(
  --no-first-run
  --disable-gpu
  --disable-dev-shm-usage
  --remote-debugging-port=9222
)

if [[ "${AUTOBYTEUS_NODE_PROFILE:-}" == "mobile-safe" ]]; then
  chrome_args=(--no-sandbox "${chrome_args[@]}")
fi

exec /usr/bin/chromium "${chrome_args[@]}"
