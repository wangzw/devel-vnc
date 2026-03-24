# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker images for remote graphical access, all based on a shared base image (`base/`). Five subdirectories:

- **`base/`** — Shared base image (`ghcr.io/wangzw/devel-base`) on Rocky Linux 9 with Node.js 25, Go, Chromium, playwright-cli, Claude Code
- **`vnc/`** — TigerVNC + noVNC + openbox desktop
- **`chrome/`** — Xpra single Chromium window (no desktop)
- **`xpra/`** — Xpra full desktop (openbox + tint2 + Thunar)
- **`kasmvnc/`** — KasmVNC full desktop (openbox + tint2 + Thunar)

All run as non-root `devel` user. Default password: `devel123`.

## Build & Run

Build base first, then child images:

```bash
docker build -t devel-base base/
docker build -t devel-vnc vnc/
docker build -t devel-chrome chrome/
docker build -t devel-xpra xpra/
docker build -t devel-kasmvnc kasmvnc/
```

### VNC Desktop
```bash
docker run -d -p 5901:5901 -p 6080:6080 devel-vnc
```
- **VNC client**: `localhost:5901` (password: `devel123`)
- **Web browser (noVNC)**: `http://localhost:6080`

### Chrome (Xpra)
```bash
docker run -d -p 10000:10000 -p 10001:10001 -e CHROME_URL=https://example.com devel-chrome
```
- **Web client**: `http://localhost:10000` (password: `devel123`)
- **Native client**: `xpra attach tcp://localhost:10001`

### Xpra Desktop
```bash
docker run -d -p 10000:10000 -p 10001:10001 devel-xpra
```
- **Web client**: `http://localhost:10000` (password: `devel123`)
- **Native client**: `xpra attach tcp://localhost:10001`

### KasmVNC Desktop
```bash
docker run -d -p 6901:6901 devel-kasmvnc
```
- **Web client**: `http://localhost:6901` (user: `devel`, password: `devel123`)

## Architecture

### base/
Rocky Linux 9 + Node.js 25 + EPEL/CRB + Go tools + Python tools + Chromium + playwright-cli + Claude Code + CJK fonts + tini + devel user.

### vnc/
Entrypoint configures VNC credentials and openbox, then launches **supervisord** managing: Xvnc, openbox, noVNC proxy, log aggregator.

### chrome/
Entrypoint configures Xpra password and starts Xpra with Chromium as managed application.

### xpra/
Entrypoint configures Xpra password, openbox autostart, and starts Xpra in `start-desktop` mode with openbox. Includes xpra-html5 web client.

### kasmvnc/
Entrypoint configures KasmVNC password, SSL cert, xstartup with openbox, and starts vncserver.

## Key Environment Variables

### Common
`DISPLAY`, `PLAYWRIGHT_MCP_CDP_ENDPOINT`, `PLAYWRIGHT_MCP_ISOLATED`

### vnc/
`VNC_PW`, `VNC_RESOLUTION`, `VNC_COL_DEPTH`, `VNC_PORT`, `NO_VNC_PORT`

### chrome/
`XPRA_PW`, `CHROME_URL`, `XPRA_PORT`, `XPRA_TCP_PORT`

### xpra/
`XPRA_PW`, `XPRA_PORT`, `XPRA_TCP_PORT`

### kasmvnc/
`KASM_PW`, `KASM_PORT`, `VNC_RESOLUTION`, `VNC_COL_DEPTH`

## CI/CD

GitHub Actions workflow builds multi-arch (amd64 + arm64) images. Base changes trigger rebuild of all child images. Images pushed to `ghcr.io/wangzw/devel-*`.
