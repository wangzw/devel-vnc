#!/bin/bash
set -euo pipefail

DEV_HOME="/home/devel"

echo "[devel-vnc] Configuring VNC for user devel..."

mkdir -p "${DEV_HOME}/.vnc"
echo "${VNC_PW}" | vncpasswd -f > "${DEV_HOME}/.vnc/passwd"
chmod 600 "${DEV_HOME}/.vnc/passwd"

cat > "${DEV_HOME}/.vnc/xstartup" << 'XSTARTUP'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec openbox-session
XSTARTUP
chmod +x "${DEV_HOME}/.vnc/xstartup"

mkdir -p "${DEV_HOME}/.config/openbox"
cat > "${DEV_HOME}/.config/openbox/autostart" << 'AUTOSTART'
tint2 &
thunar --daemon &
AUTOSTART

chown -R devel:devel "${DEV_HOME}"

echo "[devel-vnc] Starting services via supervisord..."
exec /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
