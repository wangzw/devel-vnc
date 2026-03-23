#!/bin/bash
set -euo pipefail

DEV_HOME="/home/devel"

echo "[xpra-chrome] Configuring Xpra authentication..."

mkdir -p "${DEV_HOME}/.xpra"
echo "${XPRA_PW}" > "${DEV_HOME}/.xpra/password"
chmod 600 "${DEV_HOME}/.xpra/password"
chown -R devel:devel "${DEV_HOME}/.xpra"

echo "[xpra-chrome] Starting Xpra with Chromium..."
exec sudo -u devel xpra start "${DISPLAY}" \
    --bind-tcp=0.0.0.0:"${XPRA_TCP_PORT}" \
    --bind-ws=0.0.0.0:"${XPRA_PORT}" \
    --html=on \
    --tcp-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --ws-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --start="chromium-browser --start-maximized ${CHROME_URL}" \
    --no-daemon \
    --no-notifications \
    --no-mdns \
    --no-pulseaudio \
    --clipboard=yes \
    --microphone=no \
    --speaker=no \
    --dpi=96
