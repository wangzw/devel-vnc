FROM ghcr.io/wangzw/devel-base:latest

LABEL description="VNC desktop environment - Xvnc + openbox + Chromium + noVNC"

# ---------- VNC + desktop packages ----------
RUN <<EOF
set -e
dnf install -y --allowerasing \
    tigervnc-server \
    xorg-x11-utils \
    openbox \
    tint2 \
    Thunar \
    xterm
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- noVNC (web-based VNC access) ----------
RUN <<EOF
set -e
git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC
git clone --depth 1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify
rm -rf /opt/noVNC/.git /opt/noVNC/utils/websockify/.git
EOF

# ---------- Supervisord ----------
RUN <<EOF
set -e
pip3 install --no-cache-dir supervisor
mkdir -p /etc/supervisor/conf.d /var/log/supervisor
chown devel:devel /var/log/supervisor
EOF

# ---------- Config files ----------
COPY index.html /opt/noVNC/index.html
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

# ---------- Environment ----------
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6080 \
    VNC_RESOLUTION=1920x1080 \
    VNC_COL_DEPTH=24 \
    VNC_PW=devel123 \
    PLAYWRIGHT_MCP_CDP_ENDPOINT=http://localhost:9222 \
    PLAYWRIGHT_MCP_ISOLATED=false

EXPOSE 5901 6080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

USER devel
WORKDIR /home/devel
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
