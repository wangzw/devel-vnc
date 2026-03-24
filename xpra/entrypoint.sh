#!/bin/bash
set -euo pipefail

DEV_HOME="/home/devel"

echo "[xpra-desktop] Configuring Xpra authentication..."

mkdir -p "${DEV_HOME}/.xpra"
printf '%s' "${XPRA_PW}" > "${DEV_HOME}/.xpra/password"
chmod 600 "${DEV_HOME}/.xpra/password"

# ---------- openbox autostart ----------
mkdir -p "${DEV_HOME}/.config/openbox"
cat > "${DEV_HOME}/.config/openbox/autostart" << 'AUTOSTART'
tint2 &
thunar --daemon &
AUTOSTART

echo "[xpra-desktop] Starting Xpra desktop with openbox..."
exec xpra start-desktop "${DISPLAY}" \
    --bind-tcp=0.0.0.0:"${XPRA_TCP_PORT}" \
    --bind-ws=0.0.0.0:"${XPRA_PORT}" \
    --html=on \
    --tcp-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --ws-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --start-child="chromium-browser" \
    --no-daemon \
    --no-notifications \
    --no-mdns \
    --clipboard=yes \
    --speaker=yes \
    --microphone=no \
    --dpi=96
