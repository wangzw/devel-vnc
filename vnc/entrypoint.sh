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

chown -R devel:devel "${DEV_HOME}"

echo "[devel-vnc] Starting services via supervisord..."
exec sudo -E /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
