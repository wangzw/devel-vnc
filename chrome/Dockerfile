FROM rockylinux:9

LABEL maintainer="wangzw"
LABEL description="Xpra-based Chromium browser environment on Rocky Linux 9"

# ---------- Xpra repo + system packages (single layer) ----------
RUN dnf install -y epel-release \
    && dnf install -y --allowerasing \
        xpra \
        chromium \
        xorg-x11-fonts-Type1 \
        xorg-x11-fonts-misc \
        xorg-x11-fonts-75dpi \
        xorg-x11-fonts-100dpi \
        google-noto-sans-cjk-ttc-fonts \
        langpacks-zh_CN \
        dbus-x11 \
        sudo \
        tini \
    && fc-cache -f \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---------- User setup ----------
RUN useradd -m -s /bin/bash devel \
    && echo 'devel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devel \
    && chmod 0440 /etc/sudoers.d/devel

# ---------- Chromium --no-sandbox wrapper (required in containers) ----------
RUN mv /usr/bin/chromium-browser /usr/bin/chromium-browser.real \
    && printf '#!/bin/bash\nexec /usr/bin/chromium-browser.real --no-sandbox --remote-debugging-port=9222 "$@"\n' \
        > /usr/bin/chromium-browser \
    && chmod +x /usr/bin/chromium-browser

# ---------- Node.js + tools ----------
RUN dnf module enable -y nodejs:22 \
    && dnf install -y nodejs \
    && npm install -g @playwright/cli@latest \
    && dnf clean all && rm -rf /var/cache/dnf

# ---------- Config files ----------
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

# ---------- Environment ----------
ENV DISPLAY=:100 \
    XPRA_PORT=10000 \
    XPRA_TCP_PORT=10001 \
    XPRA_PW=devel \
    CHROME_URL=about:blank \
    PLAYWRIGHT_MCP_CDP_ENDPOINT=http://localhost:9222

EXPOSE 10000 10001

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# ---------- User-space setup ----------
USER devel
WORKDIR /home/devel

RUN playwright-cli install --skills \
    && curl -fsSL https://claude.ai/install.sh | sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
