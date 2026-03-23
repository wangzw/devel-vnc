FROM ghcr.io/wangzw/devel:main

LABEL maintainer="wangzw"
LABEL description="Development VNC environment on Rocky Linux 9 - Xvnc + Chromium + noVNC"

# ---------- System packages (single layer) ----------
RUN dnf install -y --allowerasing \
        dnf-plugins-core \
        tigervnc-server \
        xorg-x11-utils \
        xorg-x11-fonts-Type1 \
        xorg-x11-fonts-misc \
        xorg-x11-fonts-75dpi \
        xorg-x11-fonts-100dpi \
        dbus-x11 \
        openbox \
        tint2 \
        Thunar \
        xterm \
        chromium \
        google-noto-sans-cjk-ttc-fonts \
        langpacks-zh_CN \
        tini \
    && dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo \
    && dnf install -y gh \
    && fc-cache -f \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---------- User setup ----------
RUN useradd -m -s /bin/bash devel \
    && echo 'devel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devel \
    && chmod 0440 /etc/sudoers.d/devel

# ---------- Chromium --no-sandbox wrapper (required in containers) ----------
RUN mv /usr/bin/chromium-browser /usr/bin/chromium-browser.real \
    && printf '#!/bin/bash\nexec /usr/bin/chromium-browser.real --no-sandbox "$@"\n' \
        > /usr/bin/chromium-browser \
    && chmod +x /usr/bin/chromium-browser

# ---------- noVNC (web-based VNC access) ----------
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC \
    && git clone --depth 1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify \
    && rm -rf /opt/noVNC/.git /opt/noVNC/utils/websockify/.git

# ---------- Python / Node global tools (root) ----------
RUN pip3 install --no-cache-dir supervisor \
    && npm install -g @playwright/cli@latest \
    && mkdir -p /etc/supervisor/conf.d /var/log/supervisor \
    && chown devel:devel /var/log/supervisor

# ---------- Config files (COPY late = better cache on code changes) ----------
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
    VNC_PW=devel

EXPOSE 5901 6080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# ---------- User-space setup (single USER switch) ----------
USER devel
WORKDIR /home/devel

RUN playwright-cli install --skills \
    && curl -fsSL https://claude.ai/install.sh | sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
