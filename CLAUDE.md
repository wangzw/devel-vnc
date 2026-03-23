# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Two Docker images for remote graphical access, each in its own subdirectory:

- **`vnc/`** — Full VNC desktop environment (Xvnc + openbox + noVNC + Chromium) on `ghcr.io/wangzw/devel:main` (Rocky Linux 9 with dev toolchains)
- **`chrome/`** — Xpra-based single Chromium window on Rocky Linux 9 (no desktop, browser only)

Both run as non-root `devel` user.

## Build & Run

### VNC Desktop

```bash
docker build -t devel-vnc vnc/
docker run -d -p 5901:5901 -p 6080:6080 devel-vnc
```

- **VNC client**: `localhost:5901` (password: `devel`)
- **Web browser (noVNC)**: `http://localhost:6080`

### Chrome (Xpra)

```bash
docker build -t devel-chrome chrome/
docker run -d -p 10000:10000 -e CHROME_URL=https://example.com devel-chrome
```

- **Web client**: `http://localhost:10000` (password: `devel`)
- **Native client**: `xpra attach tcp://localhost:10000`

## Architecture

### vnc/

The entrypoint (`entrypoint.sh`) configures VNC credentials and the openbox desktop, then launches **supervisord** which manages all services defined in `supervisord.conf`:

| Service  | Purpose                         | Priority |
|----------|---------------------------------|----------|
| xvnc     | TigerVNC X server on `:1`      | 10       |
| openbox  | Window manager + tint2 taskbar  | 20       |
| novnc    | WebSocket proxy for browser VNC | 30       |
| log-tail | Aggregates all logs to stdout   | 50       |

`index.html` is a custom noVNC landing page with clipboard sync and quality controls.

### chrome/

The entrypoint (`entrypoint.sh`) configures Xpra password and starts Xpra with Chromium as the managed application. Xpra handles X server, window forwarding, clipboard sync, and HTML5 web client — no supervisord needed.

## Key Environment Variables

### vnc/
`VNC_PW`, `VNC_RESOLUTION`, `VNC_COL_DEPTH`, `VNC_PORT`, `NO_VNC_PORT`, `DISPLAY`

### chrome/
`XPRA_PW`, `CHROME_URL`, `XPRA_PORT`, `DISPLAY`

## Base Images

- **vnc/**: `ghcr.io/wangzw/devel:main` — Python 3.12, Node.js, Go, GCC/Clang, git, socat, and standard dev tools
- **chrome/**: `rockylinux:9` — minimal base
