#!/bin/bash
set -euo pipefail

CRONTAB=/etc/supercronic-crontab
CRONTAB_DIR=/etc/supercronic.d

# Assemble crontab from fragments
cat "$CRONTAB_DIR"/*.crontab > "$CRONTAB" 2>/dev/null || truncate -s 0 "$CRONTAB"

exec /usr/local/bin/supercronic "$CRONTAB"
