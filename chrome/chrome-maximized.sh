#!/bin/bash
# Launch Chromium maximized, restart if closed, keep fullscreen on resize

while true; do
    chromium-browser --start-maximized --load-extension=/opt/chrome-extensions/keep-last-tab ${CHROME_URL:-about:blank} &
    CHROME_PID=$!

    # Wait for the window to appear, then force maximize
    for i in $(seq 1 30); do
        WID=$(xdotool search --pid "$CHROME_PID" --name "" 2>/dev/null | head -1)
        if [ -n "$WID" ]; then
            xdotool windowsize "$WID" 100% 100%
            xdotool windowmove "$WID" 0 0
            break
        fi
        sleep 0.5
    done

    # Keep window maximized and wait for exit
    while kill -0 "$CHROME_PID" 2>/dev/null; do
        WID=$(xdotool search --pid "$CHROME_PID" --name "" 2>/dev/null | head -1)
        if [ -n "$WID" ]; then
            xdotool windowsize "$WID" 100% 100%
            xdotool windowmove "$WID" 0 0
        fi
        sleep 2
    done

    # Chromium exited — restart after brief pause
    sleep 0.5
done
