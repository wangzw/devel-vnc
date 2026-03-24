FROM ghcr.io/wangzw/devel-base:latest

LABEL description="Xpra-based Chromium browser environment"

# ==========================================================================
#  1. Packages
# ==========================================================================

RUN <<EOF
set -e
dnf install -y xpra
dnf clean all && rm -rf /var/cache/dnf
EOF

# ==========================================================================
#  2. Config files
# ==========================================================================

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=0755 healthcheck.sh /usr/local/bin/healthcheck.sh

# ==========================================================================
#  3. Environment + runtime
# ==========================================================================

ENV DISPLAY=:100 \
    XPRA_PORT=10000 \
    XPRA_TCP_PORT=10001 \
    XPRA_PW=devel123 \
    CHROME_URL=about:blank \
    PLAYWRIGHT_MCP_CDP_ENDPOINT=http://localhost:9222 \
    PLAYWRIGHT_MCP_ISOLATED=false

EXPOSE 10000 10001

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

USER devel
WORKDIR /home/devel
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
