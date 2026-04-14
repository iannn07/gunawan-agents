#!/usr/bin/env bash
# Stops the local Paperclip (systemd + any tmux leftover) and tars the
# current instance state into k8s/snapshots/ for PVC seeding.
set -euo pipefail

K8S_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAP_DIR="${K8S_DIR}/snapshots"

# When invoked via `sudo`, $HOME is /root — use the invoking user's real home
# so we find ~/.paperclip/instances/default correctly.
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "${REAL_USER}" | cut -d: -f6)
INSTANCE_DIR="${REAL_HOME}/.paperclip/instances/default"

TS=$(date -u +%Y%m%dT%H%M%SZ)
SNAP_FILE="${SNAP_DIR}/paperclip-snapshot-${TS}.tar.gz"

mkdir -p "${SNAP_DIR}"

if [[ ! -d "${INSTANCE_DIR}" ]]; then
  echo "ERROR: ${INSTANCE_DIR} does not exist — nothing to snapshot" >&2
  exit 1
fi

echo "==> Stopping paperclip.service (sudo)"
if systemctl is-active --quiet paperclip.service 2>/dev/null; then
  sudo systemctl stop paperclip.service
else
  echo "    paperclip.service already stopped or absent"
fi

echo "==> Killing any stray paperclipai processes"
pkill -f 'paperclipai onboard' 2>/dev/null || true
pkill -f 'embedded-postgres' 2>/dev/null || true

echo "==> Waiting 3s for Postgres to flush"
sleep 3

echo "==> Verifying port 3100 is free"
if ss -ltn 'sport = :3100' | grep -q LISTEN; then
  echo "WARNING: port 3100 still in use — check process and kill it manually"
  ss -ltnp 'sport = :3100' || true
fi

echo "==> Taring ${INSTANCE_DIR} -> ${SNAP_FILE}"
tar -C "${REAL_HOME}/.paperclip" -czf "${SNAP_FILE}" instances/default

SIZE=$(du -h "${SNAP_FILE}" | cut -f1)
echo
echo "==> Snapshot complete: ${SNAP_FILE} (${SIZE})"
echo "    Use this path in seed-pvc.sh to restore into the cluster PVC."
