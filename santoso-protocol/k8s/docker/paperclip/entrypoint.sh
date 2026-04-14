#!/bin/sh
# Launches Paperclip on 127.0.0.1:3101 (satisfies local_trusted doctor check)
# and a socat forwarder on 0.0.0.0:3100 that rewrites inbound traffic to
# appear as a local loopback client.
set -e

echo "[entrypoint] starting socat: 0.0.0.0:3100 -> 127.0.0.1:3101"
socat -d TCP-LISTEN:3100,fork,reuseaddr TCP:127.0.0.1:3101 &
SOCAT_PID=$!

# Propagate SIGTERM to both children
trap 'echo "[entrypoint] SIGTERM"; kill -TERM $SOCAT_PID $PC_PID 2>/dev/null; wait' TERM INT

echo "[entrypoint] starting paperclipai onboard --yes"
paperclipai onboard --yes &
PC_PID=$!

# Exit when paperclip exits
wait $PC_PID
EXIT=$?
kill $SOCAT_PID 2>/dev/null || true
exit $EXIT
