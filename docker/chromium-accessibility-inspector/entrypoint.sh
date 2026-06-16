#!/usr/bin/env bash
set -euo pipefail

DISPLAY_SIZE="${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH}"
USER_DATA_DIR="${CHROMIUM_USER_DATA_DIR:-/profile}"
CRASH_DUMPS_DIR="${USER_DATA_DIR}/Crash Reports"
CHROME_DEBUG_PORT="${CHROME_DEBUG_PORT:-9223}"
DEBUG_FORWARD_PORT="${DEBUG_FORWARD_PORT:-9222}"

mkdir -p "${USER_DATA_DIR}"
mkdir -p "${CRASH_DUMPS_DIR}"
rm -f "${USER_DATA_DIR}"/SingletonLock "${USER_DATA_DIR}"/SingletonSocket "${USER_DATA_DIR}"/SingletonCookie

Xvfb "${DISPLAY}" -screen 0 "${DISPLAY_SIZE}" -ac +extension RANDR &
XVFB_PID=$!

fluxbox >/tmp/fluxbox.log 2>&1 &
FLUXBOX_PID=$!

x11vnc -display "${DISPLAY}" -forever -shared -nopw -rfbport 5900 >/tmp/x11vnc.log 2>&1 &
X11VNC_PID=$!

websockify --web=/usr/share/novnc 6080 localhost:5900 >/tmp/novnc.log 2>&1 &
NOVNC_PID=$!

node -e '
const net = require("net");
const listenPort = Number(process.env.DEBUG_FORWARD_PORT || 9222);
const targetPort = Number(process.env.CHROME_DEBUG_PORT || 9223);
net.createServer((client) => {
  const upstream = net.connect(targetPort, "127.0.0.1");
  client.pipe(upstream);
  upstream.pipe(client);
  client.on("error", () => upstream.destroy());
  upstream.on("error", () => client.destroy());
}).listen(listenPort, "0.0.0.0");
' >/tmp/debug-forwarder.log 2>&1 &
DEBUG_FORWARD_PID=$!

cleanup() {
  kill "${DEBUG_FORWARD_PID}" "${NOVNC_PID}" "${X11VNC_PID}" "${FLUXBOX_PID}" "${XVFB_PID}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

chromium \
  --user-data-dir="${USER_DATA_DIR}" \
  --no-sandbox \
  --no-first-run \
  --no-default-browser-check \
  --disable-dev-shm-usage \
  --disable-breakpad \
  --disable-crash-reporter \
  --disable-crashpad \
  --crash-dumps-dir="${CRASH_DUMPS_DIR}" \
  --remote-debugging-address=127.0.0.1 \
  --remote-debugging-port="${CHROME_DEBUG_PORT}" \
  --disable-extensions-except="${EXTENSION_PATH}" \
  --load-extension="${EXTENSION_PATH}" \
  "${START_URL}" &

CHROMIUM_PID=$!
wait "${CHROMIUM_PID}"
