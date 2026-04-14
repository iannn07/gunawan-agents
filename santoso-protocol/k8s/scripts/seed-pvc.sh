#!/usr/bin/env bash
# Restores a Paperclip snapshot tarball into the cluster PVC.
#
# Strategy:
#   1. Ensure StatefulSet is scaled to 0 (pod not using the PV).
#   2. Find the local-path PV hostPath for the paperclip-data PVC.
#   3. Extract the snapshot into it, mapping instances/default/* to the PV root.
#   4. Chown to uid 1000:1000 (matches the paperclip user in the image).
#   5. Also apply the deploymentMode / allowedHostnames adjustments to config.json
#      via jq — belt-and-braces for the known local_trusted risk.
#   6. Scale StatefulSet back to 1.
#
# Usage: scripts/seed-pvc.sh [path/to/snapshot.tar.gz]
#        If no arg given, uses the newest file in k8s/snapshots/.
set -euo pipefail

K8S_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NS="gunawan"
STS="paperclip"
PVC="paperclip-data-paperclip-0"

SNAP="${1:-}"
if [[ -z "${SNAP}" ]]; then
  SNAP=$(ls -1t "${K8S_DIR}"/snapshots/paperclip-snapshot-*.tar.gz 2>/dev/null | head -n1 || true)
fi
if [[ -z "${SNAP}" || ! -f "${SNAP}" ]]; then
  echo "ERROR: snapshot tarball not found. Run snapshot-paperclip.sh first." >&2
  exit 1
fi
echo "==> Using snapshot: ${SNAP}"

if ! kubectl -n "${NS}" get statefulset "${STS}" >/dev/null 2>&1; then
  echo "ERROR: statefulset ${NS}/${STS} does not exist. Apply the manifest first." >&2
  exit 1
fi

echo "==> Scaling StatefulSet to 0"
kubectl -n "${NS}" scale statefulset "${STS}" --replicas=0
kubectl -n "${NS}" wait --for=delete pod -l app=paperclip --timeout=60s 2>/dev/null || true

echo "==> Waiting for PVC ${PVC} to be Bound"
for i in {1..30}; do
  PHASE=$(kubectl -n "${NS}" get pvc "${PVC}" -o jsonpath='{.status.phase}' 2>/dev/null || echo "")
  if [[ "${PHASE}" == "Bound" ]]; then break; fi
  sleep 2
done
if [[ "${PHASE}" != "Bound" ]]; then
  echo "ERROR: PVC did not bind. Current state:" >&2
  kubectl -n "${NS}" get pvc "${PVC}" -o wide || true
  exit 1
fi

PV_NAME=$(kubectl -n "${NS}" get pvc "${PVC}" -o jsonpath='{.spec.volumeName}')
HOST_PATH=$(kubectl get pv "${PV_NAME}" -o jsonpath='{.spec.local.path}')
if [[ -z "${HOST_PATH}" ]]; then
  HOST_PATH=$(kubectl get pv "${PV_NAME}" -o jsonpath='{.spec.hostPath.path}')
fi
if [[ -z "${HOST_PATH}" || ! -d "${HOST_PATH}" ]]; then
  echo "ERROR: could not resolve hostPath for PV ${PV_NAME}" >&2
  kubectl get pv "${PV_NAME}" -o yaml
  exit 1
fi
echo "==> PV ${PV_NAME} -> ${HOST_PATH}"

echo "==> Clearing any existing contents in ${HOST_PATH} (sudo)"
sudo find "${HOST_PATH}" -mindepth 1 -delete

echo "==> Extracting snapshot into PVC (sudo)"
# Snapshot layout: instances/default/{config.json, db/, secrets/, data/, ...}
# We want the PV root to look like: config.json, db/, secrets/, data/, ...
# because the container mounts the PV at /home/node/.paperclip, and
# Paperclip's instance dir is /home/node/.paperclip/instances/default.
# So we extract preserving instances/default/ prefix.
sudo tar -C "${HOST_PATH}" -xzf "${SNAP}"
# The extracted tree is now ${HOST_PATH}/instances/default/... which, when
# mounted at /home/node/.paperclip, becomes the exact path Paperclip
# expects.

echo "==> Patching config.json (deploymentMode + allowedHostnames)"
CFG="${HOST_PATH}/instances/default/config.json"
if [[ -f "${CFG}" ]]; then
  sudo cp "${CFG}" "${CFG}.bak"
  # Paperclip's local_trusted mode requires loopback binding. We run
  # Paperclip on 127.0.0.1:3101 inside the pod and expose it via a socat
  # forwarder listening on 0.0.0.0:3100 (see the image entrypoint).
  sudo bash -c "jq '
    .server.host = \"127.0.0.1\" |
    .server.port = 3101 |
    .server.allowedHostnames = [\"gunawan-paperclip.digital-lab.ai\", \"paperclip.gunawan.svc.cluster.local\", \"localhost\", \"127.0.0.1\"] |
    .server.exposure = \"private\" |
    .database.embeddedPostgresDataDir = \"/home/node/.paperclip/instances/default/db\" |
    .logging.logDir = \"/home/node/.paperclip/instances/default/logs\" |
    .storage.localDisk.baseDir = \"/home/node/.paperclip/instances/default/data/storage\" |
    .database.backup.dir = \"/home/node/.paperclip/instances/default/data/backups\" |
    .secrets.localEncrypted.keyFilePath = \"/home/node/.paperclip/instances/default/secrets/master.key\"
  ' ${CFG} > ${CFG}.new && mv ${CFG}.new ${CFG}"
else
  echo "WARNING: ${CFG} not found in snapshot — Paperclip will re-onboard on first boot"
fi

echo "==> Chowning PV contents to uid:gid 1000:1000"
sudo chown -R 1000:1000 "${HOST_PATH}"

# Postgres refuses to start if the data dir isn't 0700 (or 0750).
DB_DIR="${HOST_PATH}/instances/default/db"
if [[ -d "${DB_DIR}" ]]; then
  echo "==> Setting Postgres data dir permissions to 0700"
  sudo chmod 0700 "${DB_DIR}"
fi

echo "==> Scaling StatefulSet back to 1"
kubectl -n "${NS}" scale statefulset "${STS}" --replicas=1
kubectl -n "${NS}" rollout status statefulset "${STS}" --timeout=180s

echo
echo "==> PVC seeded. Paperclip pod should now come up with the snapshot state."
