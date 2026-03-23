FROM ghcr.io/wangzw/devel:main

LABEL maintainer="wangzw"
LABEL description="Development VNC environment on Rocky Linux 9 - Xvnc + Chromium + noVNC"

# ---------- X11, VNC, desktop, Chromium, CJK fonts ----------
RUN dnf install -y --allowerasing \
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
    && fc-cache -f \
    && dnf clean all

# ---------- GitHub CLI ----------
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf install -y gh && \
    dnf clean all

RUN useradd -m -s /bin/bash devel

# --no-sandbox is required for Chromium in containers
RUN mv /usr/bin/chromium-browser /usr/bin/chromium-browser.real && \
    printf '#!/bin/bash\nexec /usr/bin/chromium-browser.real --no-sandbox "$@"\n' \
        > /usr/bin/chromium-browser && \
    chmod +x /usr/bin/chromium-browser

# ---------- noVNC (web-based VNC access) ----------
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify && \
    rm -rf /opt/noVNC/.git /opt/noVNC/utils/websockify/.git
COPY index.html /opt/noVNC/index.html

# ---------- Playwright CLI ----------
RUN npm install -g @playwright/cli@latest

USER devel
RUN playwright-cli install --skills
USER root

RUN pip3 install --no-cache-dir supervisor && \
    mkdir -p /etc/supervisor/conf.d /var/log/supervisor && \
    chown devel:devel /var/log/supervisor

ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6080
ENV VNC_RESOLUTION=1280x1024
ENV VNC_COL_DEPTH=24
ENV VNC_PW=devel

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

EXPOSE 5901
EXPOSE 6080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
