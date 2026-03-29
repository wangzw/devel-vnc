#!/bin/bash
set -euo pipefail

DEV_HOME="/home/devel"

echo "[kasmvnc] Configuring KasmVNC..."

# ---------- VNC password ----------
mkdir -p "${DEV_HOME}/.vnc"
echo -e "${KASM_PW}\n${KASM_PW}\n" | kasmvncpasswd -u devel -wo
chmod 600 "${DEV_HOME}/.kasmpasswd"

# ---------- Self-signed SSL cert ----------
if [ ! -f "${DEV_HOME}/.vnc/self.pem" ]; then
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout "${DEV_HOME}/.vnc/self.pem" \
        -out "${DEV_HOME}/.vnc/self.pem" \
        -subj "/C=US/ST=VA/L=None/O=None/OU=None/CN=kasmvnc" 2>/dev/null
fi

# ---------- KasmVNC config ----------
cat > "${DEV_HOME}/.vnc/kasmvnc.yaml" << 'EOF'
network:
  protocol: http
  ssl:
    pem_certificate: ${HOME}/.vnc/self.pem
    pem_key: ${HOME}/.vnc/self.pem
    require_ssl: false
  websocket_port: auto
  udp:
    public_ip: auto
desktop:
  resolution:
    width: 1920
    height: 1080
  allow_resize: true
  pixel_depth: 24
encoding:
  max_frame_rate: 60
EOF

# ---------- xstartup ----------
cat > "${DEV_HOME}/.vnc/xstartup" << 'XSTARTUP'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
tint2 &
thunar --daemon &
exec openbox-session
XSTARTUP
chmod +x "${DEV_HOME}/.vnc/xstartup"

# ---------- Openbox menu (avoid broken pipe-menu) ----------
mkdir -p "${DEV_HOME}/.config/openbox"
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

# ---------- Start services via supervisord ----------
echo "[kasmvnc] Starting services via supervisord..."
exec sudo -E /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
