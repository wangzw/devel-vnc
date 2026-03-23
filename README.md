# devel-vnc

Docker images for remote graphical desktop access, built on a shared base image with development tools. All images support **x86_64** and **arm64**.

## Images

| Image | Display Server | Web Client | Audio | Port |
|-------|---------------|------------|-------|------|
| `ghcr.io/wangzw/devel-vnc` | TigerVNC + noVNC | http://localhost:6080 | No | 5901, 6080 |
| `ghcr.io/wangzw/devel-chrome` | Xpra (single window) | http://localhost:10000 | Yes | 10000, 10001 |
| `ghcr.io/wangzw/devel-xpra` | Xpra (full desktop) | http://localhost:10000 | Yes | 10000, 10001 |
| `ghcr.io/wangzw/devel-kasmvnc` | KasmVNC | http://localhost:6901 | Yes (WebRTC) | 6901 |

All images share `ghcr.io/wangzw/devel-base` which includes Node.js 25, Go, GCC, Homebrew, playwright-cli, Claude Code, Chromium, CJK fonts, and more.

## Quick Start

### VNC Desktop (TigerVNC + noVNC)

```bash
docker run -d -p 5901:5901 -p 6080:6080 ghcr.io/wangzw/devel-vnc:latest
```

- **Web browser (noVNC):** http://localhost:6080
- **VNC client:** `localhost:5901` (password: `devel123`)

### Chrome (Xpra single window)

```bash
docker run -d -p 10000:10000 -p 10001:10001 \
    -e CHROME_URL=https://example.com \
    ghcr.io/wangzw/devel-chrome:latest
```

- **Web client:** http://localhost:10000 (password: `devel123`)
- **Native client:** `xpra attach tcp://localhost:10001`

### Xpra Desktop (full desktop)

```bash
docker run -d -p 10000:10000 -p 10001:10001 ghcr.io/wangzw/devel-xpra:latest
```

- **Web client:** http://localhost:10000 (password: `devel123`)
- **Native client:** `xpra attach tcp://localhost:10001`

### KasmVNC Desktop

```bash
docker run -d -p 6901:6901 ghcr.io/wangzw/devel-kasmvnc:latest
```

- **Web client:** http://localhost:6901 (user: `devel`, password: `devel123`)

## Environment Variables

### Common (all images)

| Variable | Default | Description |
|----------|---------|-------------|
| `DISPLAY` | `:1` or `:100` | X display number |
| `PLAYWRIGHT_MCP_CDP_ENDPOINT` | `http://localhost:9222` | Playwright CDP endpoint for browser reuse |
| `PLAYWRIGHT_MCP_ISOLATED` | `false` | Disable Playwright isolated mode |

### VNC

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_PW` | `devel123` | VNC password |
| `VNC_RESOLUTION` | `1920x1080` | Desktop resolution |
| `VNC_COL_DEPTH` | `24` | Color depth |
| `VNC_PORT` | `5901` | VNC server port |
| `NO_VNC_PORT` | `6080` | noVNC web port |

### Chrome / Xpra

| Variable | Default | Description |
|----------|---------|-------------|
| `XPRA_PW` | `devel123` | Xpra password |
| `XPRA_PORT` | `10000` | WebSocket port (web client) |
| `XPRA_TCP_PORT` | `10001` | TCP port (native client) |
| `CHROME_URL` | `about:blank` | Initial URL (chrome image only) |

### KasmVNC

| Variable | Default | Description |
|----------|---------|-------------|
| `KASM_PW` | `devel123` | KasmVNC password |
| `KASM_PORT` | `6901` | Web client port |
| `VNC_RESOLUTION` | `1920x1080` | Desktop resolution |
| `VNC_COL_DEPTH` | `24` | Color depth |

## Architecture

### base/

Shared base image (`ghcr.io/wangzw/devel-base`) built on Rocky Linux 9. Includes:
- Node.js 25, Go, GCC/G++, CMake, Git
- Homebrew with gh, jq, ripgrep, ffmpeg, uv, and more
- Chromium (with `--no-sandbox` and `--remote-debugging-port=9222`)
- @playwright/cli + Claude Code
- CJK fonts, pipewire-pulseaudio, tini
- `devel` user with passwordless sudo

### vnc/

TigerVNC + noVNC + supervisord. Services: Xvnc, openbox, noVNC proxy, log aggregator.

### chrome/

Xpra single-window mode. Manages one Chromium window with clipboard sync and audio forwarding.

### xpra/

Xpra full desktop mode (`start-desktop`). Runs openbox + tint2 + Thunar as a complete desktop. Includes xpra-html5 web client.

### kasmvnc/

KasmVNC v1.4.0 (Oracle 9 RPM). Built-in HTML5 client with WebP encoding, up to 60fps, WebRTC audio, dynamic resolution.

## Building Locally

```bash
# Build base first
docker build -t devel-base base/

# Then build any child image
docker build -t devel-vnc vnc/
docker build -t devel-chrome chrome/
docker build -t devel-xpra xpra/
docker build -t devel-kasmvnc kasmvnc/
```

## CI/CD

GitHub Actions workflow builds multi-arch images (amd64 + arm64) and pushes to GHCR. Base image changes trigger rebuild of all child images.
