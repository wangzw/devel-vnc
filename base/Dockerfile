FROM rockylinux:9

LABEL maintainer="wangzw"
LABEL description="Base image — Rocky Linux 9 + Node.js 25 + tools"

# ---------- Node.js 25 ----------
RUN <<EOF
set -e
curl -fsSL https://rpm.nodesource.com/setup_25.x | bash -
dnf install -y nodejs
dnf clean all
EOF

# ---------- EPEL + CRB + system utilities + build tools ----------
RUN <<EOF
set -e
dnf install -y epel-release
dnf config-manager --set-enabled crb
dnf install -y --allowerasing \
    procps-ng \
    hostname \
    which \
    findutils \
    curl \
    wget \
    git \
    net-tools \
    gcc \
    gcc-c++ \
    make \
    cmake \
    tmux \
    lsof \
    socat \
    unzip \
    golang \
    poppler-utils \
    tesseract \
    file \
    kernel-headers \
    jq \
    ripgrep \
    python3 \
    python3-pip
dnf clean all
rm -rf /var/cache/dnf
EOF

# ---------- GitHub CLI ----------
RUN <<EOF
set -e
dnf install -y 'dnf-command(config-manager)'
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install -y gh
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- RPM Fusion + ffmpeg ----------
RUN <<EOF
set -e
dnf install -y \
    https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm
dnf install -y ffmpeg
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- 1Password CLI ----------
RUN <<EOF
set -e
rpm --import https://downloads.1password.com/linux/keys/1password.asc
printf '[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc\n' \
    > /etc/yum.repos.d/1password.repo
dnf install -y 1password-cli
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- uv (standalone installer) ----------
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# ---------- Tools via direct binary download ----------
RUN <<EOF
set -e
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then GOARCH=amd64; GLARCH=amd64; HIMARCH=x86_64;
elif [ "$ARCH" = "aarch64" ]; then GOARCH=arm64; GLARCH=arm64; HIMARCH=aarch64; fi

# glab (use GitLab API — no GitHub releases)
GLAB_VER=$(curl -fsSL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases" | jq -r '.[0].tag_name' | sed 's/^v//')
curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VER}/downloads/glab_${GLAB_VER}_linux_${GOARCH}.rpm" -o /tmp/glab.rpm
dnf install -y /tmp/glab.rpm && rm -f /tmp/glab.rpm

# himalaya (asset naming: himalaya.{arch}-linux.tgz)
curl -fsSL "https://github.com/pimalaya/himalaya/releases/latest/download/himalaya.${HIMARCH}-linux.tgz" | tar xz -C /usr/local/bin

# spotify_player (asset naming: spotify_player-{arch}-unknown-linux-gnu.tar.gz)
curl -fsSL "https://github.com/aome510/spotify-player/releases/latest/download/spotify_player-${HIMARCH}-unknown-linux-gnu.tar.gz" | tar xz -C /usr/local/bin
EOF

# ---------- Skill dependencies (Homebrew tap replacements — Go-based) ----------
ENV GOPATH=/opt/go
ENV PATH="${GOPATH}/bin:${PATH}"
RUN <<EOF
set -e
go install github.com/steipete/blucli/cmd/blu@latest
go install github.com/steipete/sonoscli/cmd/sonos@latest
go install github.com/steipete/eightctl/cmd/eightctl@latest
go install github.com/Hyaxia/blogwatcher/cmd/blogwatcher@latest
GOTOOLCHAIN=auto go install github.com/steipete/gogcli/cmd/gog@latest
go install github.com/steipete/gifgrep/cmd/gifgrep@latest
go install github.com/steipete/spogo/cmd/spogo@latest
go install github.com/steipete/goplaces/cmd/goplaces@latest
go install github.com/steipete/ordercli/cmd/ordercli@latest
go install github.com/steipete/wacli/cmd/wacli@latest
rm -rf /opt/go/pkg /opt/go/src
EOF

# ---------- Skill dependencies (npm global) ----------
RUN <<EOF
set -e
npm install -g \
    @playwright/cli@latest \
    mcporter \
    @steipete/oracle \
    @steipete/summarize \
    clawhub \
    @google/gemini-cli
npm cache clean --force
EOF

# ---------- Skill dependencies (Python) ----------
RUN <<EOF
set -e
uv tool install nano-pdf
uv tool install obsidian-cli
ln -sf /root/.local/bin/obsidian /root/.local/bin/obsidian-cli
uv tool install openai-whisper
EOF

# ---------- openhue-cli + xurl (binary downloads) ----------
RUN <<EOF
set -e
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then GOARCH=amd64; OH_ARCH=x86_64;
elif [ "$ARCH" = "aarch64" ]; then GOARCH=arm64; OH_ARCH=arm64; fi

# openhue (asset naming: openhue_Linux_{x86_64|arm64}.tar.gz)
OH_VER=$(curl -fsSL https://api.github.com/repos/openhue/openhue-cli/releases/latest | jq -r .tag_name | sed 's/^v//')
curl -fsSL "https://github.com/openhue/openhue-cli/releases/download/${OH_VER}/openhue_Linux_${OH_ARCH}.tar.gz" | tar xz -C /usr/local/bin openhue

# xurl (asset naming: xurl_Linux_{x86_64|arm64}.tar.gz)
curl -fsSL "https://github.com/xdevplatform/xurl/releases/latest/download/xurl_Linux_${OH_ARCH}.tar.gz" | tar xz -C /usr/local/bin xurl
EOF

# ---------- Common: devel user + sudo ----------
RUN <<EOF
set -e
useradd -m -s /bin/bash devel
mkdir -p /etc/sudoers.d
echo 'devel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devel
chmod 0440 /etc/sudoers.d/devel
EOF

# ---------- Common: fonts + GUI dependencies ----------
RUN <<EOF
set -e
dnf install -y --allowerasing \
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
    chromium
fc-cache -f
dnf clean all
rm -rf /var/cache/dnf
EOF

# ---------- Common: Chromium --no-sandbox + remote debugging ----------
RUN <<EOF
set -e
mv /usr/bin/chromium-browser /usr/bin/chromium-browser.real
printf '#!/bin/bash\nexec /usr/bin/chromium-browser.real --no-sandbox --remote-debugging-port=9222 "$@"\n' \
    > /usr/bin/chromium-browser
chmod +x /usr/bin/chromium-browser
EOF

# ---------- Common: Chromium default homepage ----------
RUN <<EOF
set -e
mkdir -p /etc/chromium/policies/managed
printf '{"HomepageLocation":"about:blank","HomepageIsNewTabPage":false,"RestoreOnStartup":4,"StartupUrls":["about:blank"]}\n' \
    > /etc/chromium/policies/managed/default.json
EOF

# ---------- Common: user-space setup ----------
USER devel
WORKDIR /home/devel

RUN playwright-cli install --skills
RUN curl -fsSL https://claude.ai/install.sh | sh

USER root
