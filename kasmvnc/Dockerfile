FROM rockylinux:9

LABEL maintainer="wangzw"
LABEL description="KasmVNC-based full desktop environment on Rocky Linux 9 - openbox + Chromium + audio"

# ---------- System packages ----------
RUN dnf install -y epel-release \
    && dnf install -y --allowerasing \
        chromium \
        openbox \
        tint2 \
        Thunar \
        xterm \
        xorg-x11-fonts-Type1 \
        xorg-x11-fonts-misc \
        xorg-x11-fonts-75dpi \
        xorg-x11-fonts-100dpi \
        google-noto-sans-cjk-ttc-fonts \
        langpacks-zh_CN \
        dbus-x11 \
        pipewire-pulseaudio \
        sudo \
        tini \
        openssl \
        mesa-dri-drivers \
    && fc-cache -f \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---------- KasmVNC (Oracle 9 RPM, binary-compatible with Rocky 9) ----------
RUN dnf install -y dnf-plugins-core \
    && dnf config-manager --set-enabled crb \
    && ARCH=$(uname -m) \
    && dnf install -y \
        "https://github.com/kasmtech/KasmVNC/releases/download/v1.4.0/kasmvncserver_oracle_9_1.4.0_${ARCH}.rpm" \
    && dnf clean all && rm -rf /var/cache/dnf

# ---------- User setup ----------
RUN useradd -m -s /bin/bash devel \
    && echo 'devel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devel \
    && chmod 0440 /etc/sudoers.d/devel \
    && usermod -a -G kasmvnc-cert devel

# ---------- Chromium --no-sandbox wrapper (required in containers) ----------
RUN mv /usr/bin/chromium-browser /usr/bin/chromium-browser.real \
    && printf '#!/bin/bash\nexec /usr/bin/chromium-browser.real --no-sandbox --remote-debugging-port=9222 "$@"\n' \
        > /usr/bin/chromium-browser \
    && chmod +x /usr/bin/chromium-browser

# ---------- Node.js + tools ----------
RUN dnf module enable -y nodejs:22 \
    && dnf install -y nodejs npm \
    && npm install -g @playwright/cli@latest \
    && dnf clean all && rm -rf /var/cache/dnf

# ---------- Config files ----------
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

# ---------- Environment ----------
ENV DISPLAY=:1 \
    KASM_PORT=6901 \
    KASM_PW=devel \
    VNC_RESOLUTION=1920x1080 \
    VNC_COL_DEPTH=24 \
    PLAYWRIGHT_MCP_CDP_ENDPOINT=http://localhost:9222 \
    PLAYWRIGHT_MCP_ISOLATED=false

EXPOSE 6901

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# ---------- User-space setup ----------
USER devel
WORKDIR /home/devel

RUN playwright-cli install --skills
RUN curl -fsSL https://claude.ai/install.sh | sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
