#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PORT=6744
echo "Ripples website → http://localhost:${PORT}"
exec python3 -m http.server "${PORT}" --bind 0.0.0.0
