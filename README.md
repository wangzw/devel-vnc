# devel-vnc

Docker image that adds a VNC-accessible desktop environment on top of [ghcr.io/wangzw/devel:main](https://github.com/wangzw/devel). Built for both **x86_64** and **arm64**.

## What's included

| Component | Description |
|-----------|-------------|
| TigerVNC (Xvnc) | VNC server on display `:1` |
| noVNC + websockify | Browser-based VNC client |
| Openbox + tint2 | Lightweight window manager with taskbar |
| Chromium | Web browser (pre-configured with `--no-sandbox`) |
| Thunar | File manager |
| xterm | Terminal emulator |
| CJK fonts | Noto Sans CJK + Chinese langpack |

All development toolchains from the base image (GCC, Clang, Go, Python 3.12, Node.js, etc.) are available.

## Quick start

```bash
docker run -d -p 5901:5901 -p 6080:6080 ghcr.io/wangzw/devel-vnc:latest
```

- **Web browser (noVNC):** http://localhost:6080
- **VNC client:** `localhost:5901` (password: `devel`)

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_PW` | `devel` | VNC password |
| `VNC_RESOLUTION` | `1280x1024` | Desktop resolution |
| `VNC_COL_DEPTH` | `24` | Color depth |
| `VNC_PORT` | `5901` | VNC server port |
| `NO_VNC_PORT` | `6080` | noVNC web port |
| `DISPLAY` | `:1` | X display number |

Example with custom resolution and password:

```bash
docker run -d -p 5901:5901 -p 6080:6080 \
    -e VNC_PW=secret \
    -e VNC_RESOLUTION=1920x1080 \
    ghcr.io/wangzw/devel-vnc:latest
```

## Ports

| Port | Service |
|------|---------|
| 5901 | VNC (native client access) |
| 6080 | noVNC (browser access) |

## Logs

Service logs are written to `/var/log/supervisor/` and also streamed to container stdout/stderr (`docker logs`).

## Building locally

```bash
docker build -t devel-vnc .
```
