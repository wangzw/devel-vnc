# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker image that adds a VNC-accessible desktop environment (Xvnc + openbox + noVNC + Chromium) on top of the `ghcr.io/wangzw/devel:main` base image (Rocky Linux 9 with dev toolchains). The container runs as a non-root `devel` user.

## Build & Run

```bash
docker build -t devel-vnc .
docker run -d -p 5901:5901 -p 6080:6080 devel-vnc
```

- **VNC client**: `localhost:5901` (password: `devel`)
- **Web browser (noVNC)**: `http://localhost:6080`

## Architecture

The entrypoint (`entrypoint.sh`) configures VNC credentials and the openbox desktop, then launches **supervisord** which manages all services defined in `supervisord.conf`:

| Service  | Purpose                         | Priority |
|----------|---------------------------------|----------|
| xvnc     | TigerVNC X server on `:1`      | 10       |
| openbox  | Window manager + tint2 taskbar  | 20       |
| novnc    | WebSocket proxy for browser VNC | 30       |
| log-tail | Aggregates all logs to stdout   | 50       |

`index.html` is a custom noVNC landing page copied into `/opt/noVNC/`.

## Key Environment Variables

`VNC_PW`, `VNC_RESOLUTION`, `VNC_COL_DEPTH`, `VNC_PORT`, `NO_VNC_PORT`, `DISPLAY` — all configurable at runtime.

## Base Image

`ghcr.io/wangzw/devel:main` already provides: Python 3.12, Node.js, Go, GCC/Clang, git, socat, and standard dev tools. No need to reinstall these.
