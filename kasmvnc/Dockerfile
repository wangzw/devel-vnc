FROM ghcr.io/wangzw/devel-base:latest

LABEL description="KasmVNC-based full desktop environment - openbox + Chromium + audio"

# ==========================================================================
#  1. Desktop packages
# ==========================================================================

RUN <<EOF
set -e
dnf install -y --allowerasing openbox tint2 Thunar xterm openssl mesa-dri-drivers \
    pipewire-pulseaudio pipewire-utils wireplumber
dnf clean all && rm -rf /var/cache/dnf
EOF

# ==========================================================================
#  2. KasmVNC (Oracle 9 RPM, binary-compatible with Rocky 9)
# ==========================================================================

RUN <<EOF
set -e
ARCH=$(uname -m)
dnf install -y \
    "https://github.com/kasmtech/KasmVNC/releases/download/v1.4.0/kasmvncserver_oracle_9_1.4.0_${ARCH}.rpm"
dnf clean all && rm -rf /var/cache/dnf
EOF

RUN usermod -a -G kasmvnc-cert devel

# ==========================================================================
#  3. Config files
# ==========================================================================

RUN sed -i 's|https://fedoraproject.org/start|about:blank|g' /etc/chromium/master_preferences

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

# ==========================================================================
#  4. Environment + runtime
# ==========================================================================

ENV DISPLAY=:1 \
    KASM_PORT=6901 \
    KASM_PW=devel123 \
    VNC_RESOLUTION=1920x1080 \
    VNC_COL_DEPTH=24 \
    PLAYWRIGHT_MCP_CDP_ENDPOINT=http://localhost:9222 \
    PLAYWRIGHT_MCP_ISOLATED=false

EXPOSE 6901

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

USER devel
WORKDIR /home/devel
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
