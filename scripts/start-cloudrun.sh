#!/bin/bash
# Start gateway in background, then Moltcraft on 8080.
# Expects config mounted at /home/node/.clawdbot (e.g. -v ~/.openclaw:/home/node/.clawdbot).
set -e
export HOME="${HOME:-/home/node}"

# Gateway on 18789 (internal)
node /app/dist/index.js gateway --bind lan --port 18789 &
GWPID=$!

# Wait for gateway to listen
for i in $(seq 1 30); do
  if curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:18789/" 2>/dev/null | grep -qE '^[0-9]+$'; then
    break
  fi
  sleep 1
done

# Moltcraft on 8080 (serves UI; connects to gateway via config in .clawdbot)
exec npx -y @ask-mojo/moltcraft --port 8080 --no-open
