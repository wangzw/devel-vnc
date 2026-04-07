FROM rockylinux:9

LABEL maintainer="wangzw"
LABEL description="Base image — Rocky Linux 9 + Node.js 25 + tools"

# ==========================================================================
#  1. System repositories & core packages
# ==========================================================================

# ---------- Node.js 25 repo ----------
RUN curl -fsSL https://rpm.nodesource.com/setup_25.x | bash -

# ---------- EPEL + CRB ----------
RUN <<EOF
set -e
dnf install -y epel-release
dnf config-manager --set-enabled crb
EOF

# ---------- Core system packages ----------
RUN <<EOF
set -e
dnf install -y --allowerasing \
    bash-completion \
    bind-utils \
    cmake \
    curl \
    diffutils \
    file \
    findutils \
    gcc \
    gcc-c++ \
    git \
    hostname \
    htop \
    iputils \
    iproute \
    jq \
    kernel-headers \
    less \
    lsof \
    make \
    net-tools \
    nodejs \
    openssh-clients \
    patch \
    poppler-utils \
    procps-ng \
    python3.12 \
    python3.12-pip \
    ripgrep \
    rsync \
    socat \
    strace \
    sudo \
    tesseract \
    tmux \
    tree \
    unzip \
    vim-enhanced \
    wget \
    which \
    zip
dnf update -y ca-certificates
update-ca-trust
rm -f /etc/yum.repos.d/nodesource*.repo
dnf clean all && rm -rf /var/cache/dnf
alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
alternatives --set python3 /usr/bin/python3.12
ln -sf /usr/bin/pip3.12 /usr/bin/pip3
ln -sf /usr/bin/python3 /usr/bin/python
ln -sf /usr/bin/pip3 /usr/bin/pip
EOF

# ---------- Go 1.26.1 ----------
RUN <<EOF
set -e
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then GOARCH=amd64;
elif [ "$ARCH" = "aarch64" ]; then GOARCH=arm64; fi
curl -fsSL "https://go.dev/dl/go1.26.1.linux-${GOARCH}.tar.gz" | tar xz -C /usr/local
EOF
ENV PATH="/usr/local/go/bin:${PATH}"

# ==========================================================================
#  2. Third-party repositories & CLIs
# ==========================================================================

# ---------- GitHub CLI ----------
RUN <<EOF
set -e
dnf install -y 'dnf-command(config-manager)'
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf install -y gh
rm -f /etc/yum.repos.d/gh-cli.repo
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- 1Password CLI ----------
RUN <<EOF
set -e
rpm --import https://downloads.1password.com/linux/keys/1password.asc
printf '[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc\n' \
    > /etc/yum.repos.d/1password.repo
dnf install -y 1password-cli
rm -f /etc/yum.repos.d/1password.repo
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- RPM Fusion + ffmpeg ----------
RUN <<EOF
set -e
dnf install -y \
    https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-9.noarch.rpm
dnf install -y ffmpeg
rm -f /etc/yum.repos.d/rpmfusion*.repo
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- Docker CE ----------
RUN <<EOF
set -e
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
rm -f /etc/yum.repos.d/docker-ce.repo
dnf clean all && rm -rf /var/cache/dnf
EOF

# ==========================================================================
#  3. Standalone binary tools
# ==========================================================================

# ---------- uv (Python package manager) ----------
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# ---------- Supervisord ----------
RUN <<EOF
set -e
pip3 install --no-cache-dir supervisor
mkdir -p /etc/supervisor/conf.d /var/log/supervisor
EOF

# ---------- Supercronic (cron for containers) ----------
RUN <<EOF
set -e
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then SC_ARCH=amd64;
elif [ "$ARCH" = "aarch64" ]; then SC_ARCH=arm64; fi
SC_VER=$(curl -fsSL https://api.github.com/repos/aptible/supercronic/releases/latest | jq -r .tag_name)
curl -fsSL "https://github.com/aptible/supercronic/releases/download/${SC_VER}/supercronic-linux-${SC_ARCH}" -o /usr/local/bin/supercronic
chmod +x /usr/local/bin/supercronic
mkdir -p /etc/supercronic.d
touch /etc/supercronic-crontab
EOF
COPY --chmod=0755 supercronic-launcher.sh /usr/local/bin/supercronic-launcher

# ---------- Direct binary downloads ----------
RUN <<EOF
set -e
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then GOARCH=amd64; UARCH=x86_64;
elif [ "$ARCH" = "aarch64" ]; then GOARCH=arm64; UARCH=aarch64; fi

# glab
GLAB_VER=$(curl -fsSL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases" | jq -r '.[0].tag_name' | sed 's/^v//')
curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VER}/downloads/glab_${GLAB_VER}_linux_${GOARCH}.rpm" -o /tmp/glab.rpm
dnf install -y /tmp/glab.rpm && rm -f /tmp/glab.rpm

# himalaya
curl -fsSL "https://github.com/pimalaya/himalaya/releases/latest/download/himalaya.${UARCH}-linux.tgz" | tar xz -C /usr/local/bin

# spotify_player (x86_64 only — no Linux arm64 release available)
if [ "$ARCH" = "x86_64" ]; then
  curl -fsSL "https://github.com/aome510/spotify-player/releases/latest/download/spotify_player-${UARCH}-unknown-linux-gnu.tar.gz" | tar xz -C /usr/local/bin
fi

# openhue (asset naming: openhue_Linux_{x86_64|arm64}.tar.gz)
if [ "$ARCH" = "x86_64" ]; then OH_ARCH=x86_64; else OH_ARCH=arm64; fi
OH_VER=$(curl -fsSL https://api.github.com/repos/openhue/openhue-cli/releases/latest | jq -r .tag_name | sed 's/^v//')
curl -fsSL "https://github.com/openhue/openhue-cli/releases/download/${OH_VER}/openhue_Linux_${OH_ARCH}.tar.gz" | tar xz -C /usr/local/bin openhue

# xurl (asset naming: xurl_Linux_{x86_64|arm64}.tar.gz)
curl -fsSL "https://github.com/xdevplatform/xurl/releases/latest/download/xurl_Linux_${OH_ARCH}.tar.gz" | tar xz -C /usr/local/bin xurl
EOF

# ==========================================================================
#  4. Language-specific tools (Go, npm, Python)
# ==========================================================================

# ---------- Go tools ----------
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
go install github.com/swaggo/swag/cmd/swag@latest
rm -rf /opt/go/pkg /opt/go/src
EOF

# ---------- npm global tools ----------
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

# ---------- Python tools (via uv) ----------
RUN <<EOF
set -e
uv tool install nano-pdf
uv tool install obsidian-cli
ln -sf /root/.local/bin/obsidian /root/.local/bin/obsidian-cli
uv tool install openai-whisper
EOF

# ==========================================================================
#  5. GUI, fonts & Chromium
# ==========================================================================

# ---------- Fonts + GUI dependencies ----------
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
    tini \
    chromium
fc-cache -f
dnf clean all && rm -rf /var/cache/dnf
EOF

# ---------- Chromium: --no-sandbox + remote debugging wrapper ----------
RUN <<EOF
set -e
mv /usr/bin/chromium-browser /usr/bin/chromium-browser.real
printf '#!/bin/bash\nexec /usr/bin/chromium-browser.real --no-sandbox --remote-debugging-port=9222 "$@"\n' \
    > /usr/bin/chromium-browser
chmod +x /usr/bin/chromium-browser
EOF

# ---------- Chromium: default homepage policy ----------
RUN <<EOF
set -e
mkdir -p /etc/chromium/policies/managed
printf '{"HomepageIsNewTabPage":true,"RestoreOnStartup":1,"ExtensionInstallForcelist":["medapdbncneneejhbgcjceippjlfkmkg;https://clients2.google.com/service/update2/crx"]}\n' \
    > /etc/chromium/policies/managed/default.json
EOF

# ==========================================================================
#  6. User setup
# ==========================================================================

RUN <<EOF
set -e
useradd -m -s /bin/bash devel
echo 'devel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devel
chmod 0440 /etc/sudoers.d/devel
chown -R devel:devel /opt/go
chown devel:devel /var/log/supervisor /etc/supervisor/conf.d
chown devel:devel /etc/supercronic-crontab /etc/supercronic.d
usermod -aG docker devel
EOF

USER devel
WORKDIR /home/devel

RUN playwright-cli install --skills
RUN curl -fsSL https://claude.ai/install.sh | sh

USER root
