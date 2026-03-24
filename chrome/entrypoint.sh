#!/bin/bash
set -euo pipefail

DEV_HOME="/home/devel"

echo "[xpra-chrome] Configuring Xpra..."

# ---------- Xpra password ----------
mkdir -p "${DEV_HOME}/.xpra"
printf '%s' "${XPRA_PW}" > "${DEV_HOME}/.xpra/password"
chmod 600 "${DEV_HOME}/.xpra/password"

# ---------- PipeWire audio ----------
export XDG_RUNTIME_DIR="/tmp/runtime-devel"
mkdir -p "${XDG_RUNTIME_DIR}"
eval "$(dbus-launch --sh-syntax)"
pipewire &
sleep 0.5
pipewire-pulse &
wireplumber &
sleep 1
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"

# ---------- Start Xpra with Chromium ----------
echo "[xpra-chrome] Starting Xpra with Chromium..."
exec xpra start "${DISPLAY}" \
    --bind-tcp=0.0.0.0:"${XPRA_TCP_PORT}" \
    --bind-ws=0.0.0.0:"${XPRA_PORT}" \
    --html=on \
    --tcp-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --ws-auth=file:filename="${DEV_HOME}/.xpra/password" \
    --start-child="chromium-browser --start-maximized ${CHROME_URL}" \
    --exit-with-children \
    --no-daemon \
    --no-notifications \
    --no-mdns \
    --clipboard=yes \
    --speaker=yes \
    --microphone=no \
    --pulseaudio=no \
    --dpi=96 \
    --resize-display=yes \
    --headerbar=no
