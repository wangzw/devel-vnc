FROM ghcr.io/wangzw/devel-base:latest

LABEL description="Xpra-based full desktop environment - openbox + Chromium + audio"

# ---------- Xpra + desktop packages ----------
RUN dnf install -y xpra openbox tint2 Thunar xterm \
    && dnf clean all && rm -rf /var/cache/dnf

# ---------- Xpra HTML5 client ----------
RUN git clone --depth 1 https://github.com/Xpra-org/xpra-html5.git /tmp/xpra-html5 \
    && cd /tmp/xpra-html5 && python3 setup.py install /usr/share/xpra/www \
    && rm -rf /tmp/xpra-html5

# ---------- Config files ----------
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

# ---------- Environment ----------
ENV DISPLAY=:100 \
    XPRA_PORT=10000 \
    XPRA_TCP_PORT=10001 \
    XPRA_PW=devel123 \
    PLAYWRIGHT_MCP_CDP_ENDPOINT=http://localhost:9222 \
    PLAYWRIGHT_MCP_ISOLATED=false

EXPOSE 10000 10001

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

USER devel
WORKDIR /home/devel
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
