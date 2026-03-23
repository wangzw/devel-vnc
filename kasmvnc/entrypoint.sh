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
  rect_encoding_mode:
    min_quality: 7
    max_quality: 10
    consider_lossless_quality: 10
    rectangle_compress_threads: 0
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

echo "[kasmvnc] Starting KasmVNC server..."
exec vncserver "${DISPLAY}" \
    -depth "${VNC_COL_DEPTH}" \
    -geometry "${VNC_RESOLUTION}" \
    -websocketPort "${KASM_PORT}" \
    -interface 0.0.0.0 \
    -BlacklistThreshold=0 \
    -FreeKeyMappings \
    -select-de manual \
    -fg
