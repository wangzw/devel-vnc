#!/bin/bash
set -euo pipefail

DEV_HOME="/home/devel"

echo "[xpra-desktop] Configuring Xpra..."

# ---------- Xpra password ----------
mkdir -p "${DEV_HOME}/.xpra"
printf '%s' "${XPRA_PW}" > "${DEV_HOME}/.xpra/password"
chmod 600 "${DEV_HOME}/.xpra/password"

# ---------- Openbox autostart ----------
mkdir -p "${DEV_HOME}/.config/openbox"
cat > "${DEV_HOME}/.config/openbox/autostart" << 'AUTOSTART'
tint2 &
thunar --daemon &
AUTOSTART

cat > "${DEV_HOME}/.config/openbox/menu.xml" << 'MENU'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Desktop">
    <item label="Terminal"><action name="Execute"><command>xterm</command></action></item>
    <item label="File Manager"><action name="Execute"><command>thunar</command></action></item>
    <item label="Chromium"><action name="Execute"><command>chromium-browser --no-sandbox</command></action></item>
    <separator />
    <item label="Reconfigure"><action name="Reconfigure" /></item>
  </menu>
</openbox_menu>
MENU

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

# ---------- Start services via supervisord ----------
echo "[xpra-desktop] Starting services via supervisord..."
exec sudo -E /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
