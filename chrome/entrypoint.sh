#!/bin/bash
set -euo pipefail

DEV_HOME="/home/devel"

echo "[xpra-chrome] Configuring Xpra authentication..."

mkdir -p "${DEV_HOME}/.xpra"
printf '%s' "${XPRA_PW}" > "${DEV_HOME}/.xpra/password"
chmod 600 "${DEV_HOME}/.xpra/password"

echo "[xpra-chrome] Starting Xpra with Chromium..."
exec xpra start "${DISPLAY}" \
    --bind-tcp=0.0.0.0:"${XPRA_TCP_PORT}" \
    --bind-ws=0.0.0.0:"${XPRA_PORT}" \
    --html=on \
    --tcp-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --ws-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --start="chromium-browser --start-maximized ${CHROME_URL}" \
    --no-daemon \
    --no-notifications \
    --no-mdns \
    --clipboard=yes \
    --speaker=yes \
    --microphone=no \
    --dpi=96 \
    --resize-display=1920x1080 \
    --desktop-scaling=auto
