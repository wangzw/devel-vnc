FROM rockylinux:9

LABEL maintainer="wangzw"
LABEL description="Base image — Rocky Linux 9 + Homebrew + tools"

# ---------- Minimal system packages (required before Homebrew) ----------
RUN dnf install -y epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf install -y --allowerasing \
        procps-ng \
        hostname \
        which \
        findutils \
        curl \
        git \
        net-tools \
        gcc \
        gcc-c++ \
        make \
        file \
        kernel-headers \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---------- Homebrew ----------
RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
USER root
RUN ln -sf /home/linuxbrew/.linuxbrew/bin/python3 /usr/bin/python3
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"

# ---------- Homebrew packages (dev tools + skill dependencies) ----------
ENV HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1
USER linuxbrew
RUN brew install \
        node \
        go \
        cmake \
        tmux \
        wget \
        socat \
        unzip \
        lsof \
        poppler \
        tesseract \
        gh \
        glab \
        jq \
        ripgrep \
        ffmpeg \
        uv \
        himalaya \
        gemini-cli \
        openai-whisper \
        spotify_player \
        1password-cli \
    && brew install steipete/tap/gogcli \
    && brew install steipete/tap/gifgrep \
    && brew install steipete/tap/songsee \
    && brew install steipete/tap/spogo \
    && brew install steipete/tap/goplaces \
    && brew install steipete/tap/ordercli \
    && brew install steipete/tap/wacli \
    && brew install openhue/cli/openhue-cli \
    && brew install xdevplatform/tap/xurl \
    && brew cleanup --prune=all

# ---------- Skill dependencies (npm global — as linuxbrew for Homebrew's node) ----------
RUN npm install -g \
        @playwright/cli@latest \
        mcporter \
        @steipete/oracle \
        @steipete/summarize \
        clawhub \
    && npm cache clean --force
USER root

# ---------- Skill dependencies (Go) ----------
ENV GOPATH=/opt/go
ENV PATH="${GOPATH}/bin:${PATH}"
RUN mkdir -p /opt/go && chown linuxbrew:linuxbrew /opt/go
USER linuxbrew
RUN go install github.com/steipete/blucli/cmd/blu@latest && \
    go install github.com/steipete/sonoscli/cmd/sonos@latest && \
    go install github.com/steipete/eightctl/cmd/eightctl@latest && \
    go install github.com/Hyaxia/blogwatcher/cmd/blogwatcher@latest && \
    rm -rf /opt/go/pkg /opt/go/src
USER root

# ---------- Skill dependencies (Python) ----------
ENV PATH="/usr/local/bin:/root/.local/bin:${PATH}"
RUN uv tool install nano-pdf && \
    uv tool install obsidian-cli && \
    ln -sf /root/.local/bin/obsidian /root/.local/bin/obsidian-cli

# ---------- Common: devel user + sudo ----------
RUN useradd -m -s /bin/bash devel \
    && echo 'devel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devel \
    && chmod 0440 /etc/sudoers.d/devel

# ---------- Common: fonts + GUI dependencies (dnf only — not in Homebrew) ----------
RUN dnf install -y --allowerasing \
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
        chromium \
    && fc-cache -f \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ---------- Common: Chromium --no-sandbox + remote debugging ----------
RUN mv /usr/bin/chromium-browser /usr/bin/chromium-browser.real \
    && printf '#!/bin/bash\nexec /usr/bin/chromium-browser.real --no-sandbox --remote-debugging-port=9222 "$@"\n' \
        > /usr/bin/chromium-browser \
    && chmod +x /usr/bin/chromium-browser

# ---------- Common: Chromium default homepage ----------
RUN mkdir -p /etc/chromium/policies/managed \
    && printf '{"HomepageLocation":"about:blank","HomepageIsNewTabPage":false,"RestoreOnStartup":4,"StartupUrls":["about:blank"]}\n' \
        > /etc/chromium/policies/managed/default.json

# ---------- Common: user-space setup ----------
USER devel
WORKDIR /home/devel

RUN playwright-cli install --skills
RUN curl -fsSL https://claude.ai/install.sh | sh

USER root
