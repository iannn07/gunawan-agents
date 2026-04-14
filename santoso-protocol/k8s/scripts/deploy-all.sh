#!/usr/bin/env bash
# Top-level orchestrator. Assumes k3s + cert-manager are already installed
# (run scripts/install-k3s.sh first) and that images have been pushed to
# Docker Hub (run scripts/build-and-push.sh first).
#
# Workflow:
#   1. Render Secret from .env
#   2. Apply namespace, Secret, ConfigMap
#   3. Apply Paperclip StatefulSet + Service (at replicas=1)
#   4. Snapshot + seed the PVC (scripts/snapshot-paperclip.sh + seed-pvc.sh)
#   5. Apply bridge Deployment + Service
#   6. Apply ClusterIssuer + Ingress
#   7. Wait for Certificate to be Ready
#   8. Print verification summary
set -euo pipefail

K8S_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "${K8S_DIR}/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"
MANIFESTS="${K8S_DIR}/manifests"
SECRETS_TMPL="${MANIFESTS}/10-secrets.yaml.tmpl"
SECRETS_RENDERED="${MANIFESTS}/10-secrets.generated.yaml"
NS="gunawan"

cleanup() {
  rm -f "${SECRETS_RENDERED}"
}
trap cleanup EXIT

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: ${ENV_FILE} not found" >&2
  exit 1
fi

# --- Step 1: render Secret ---
echo "==> Rendering Secret from ${ENV_FILE}"
set -a; source "${ENV_FILE}"; set +a
: "${ANTHROPIC_API_KEY:?missing in .env}"
: "${TELEGRAM_BOT_TOKEN:?missing in .env}"
: "${TELEGRAM_CHAT_ID:?missing in .env}"

sed \
  -e "s|__ANTHROPIC_API_KEY__|${ANTHROPIC_API_KEY}|" \
  -e "s|__TELEGRAM_BOT_TOKEN__|${TELEGRAM_BOT_TOKEN}|" \
  -e "s|__TELEGRAM_CHAT_ID__|${TELEGRAM_CHAT_ID}|" \
  "${SECRETS_TMPL}" > "${SECRETS_RENDERED}"

# --- Step 2: apply namespace + config + secrets ---
echo "==> Applying namespace, secrets, configmap"
kubectl apply -f "${MANIFESTS}/00-namespace.yaml"
kubectl apply -f "${SECRETS_RENDERED}"
kubectl apply -f "${MANIFESTS}/20-configmap.yaml"

# --- Step 3: apply Paperclip StatefulSet + Service ---
echo "==> Applying Paperclip StatefulSet + Service"
kubectl apply -f "${MANIFESTS}/31-paperclip-service.yaml"
kubectl apply -f "${MANIFESTS}/30-paperclip-statefulset.yaml"

# --- Step 4: snapshot + seed PVC ---
# If a snapshot already exists in k8s/snapshots/, skip re-snapshotting and
# just seed from the latest.
if ls -1t "${K8S_DIR}"/snapshots/paperclip-snapshot-*.tar.gz >/dev/null 2>&1; then
  echo "==> Using existing snapshot (skipping snapshot-paperclip.sh)"
else
  echo "==> Taking a fresh snapshot of current Paperclip state"
  bash "${K8S_DIR}/scripts/snapshot-paperclip.sh"
fi

echo "==> Seeding PVC from snapshot"
bash "${K8S_DIR}/scripts/seed-pvc.sh"

echo "==> Waiting for Paperclip pod Ready (up to 3 min)"
kubectl -n "${NS}" wait --for=condition=Ready pod -l app=paperclip --timeout=180s

# --- Step 5: bridge ---
echo "==> Applying telegram-bridge Deployment + Service"
kubectl apply -f "${MANIFESTS}/41-bridge-service.yaml"
kubectl apply -f "${MANIFESTS}/40-bridge-deployment.yaml"
kubectl -n "${NS}" rollout status deployment/telegram-bridge --timeout=120s

# --- Step 6: ClusterIssuer + Ingress ---
echo "==> Applying ClusterIssuer + Ingress"
kubectl apply -f "${MANIFESTS}/60-cert-manager-issuer.yaml"
kubectl apply -f "${MANIFESTS}/50-ingress.yaml"

# --- Step 7: wait for cert ---
echo "==> Waiting for Certificate 'gunawan-tls' Ready (up to 3 min)"
for i in {1..36}; do
  READY=$(kubectl -n "${NS}" get certificate gunawan-tls -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "")
  if [[ "${READY}" == "True" ]]; then
    echo "    Certificate Ready"
    break
  fi
  sleep 5
done
if [[ "${READY}" != "True" ]]; then
  echo "WARNING: certificate not ready yet. Run: kubectl -n ${NS} describe certificate gunawan-tls"
fi

# --- Step 8: verification ---
echo
echo "==> Deployment complete. Summary:"
kubectl -n "${NS}" get pods,svc,ingress,certificate
echo
echo "==> Next: disable old systemd paperclip.service"
echo "    sudo systemctl disable paperclip.service"
echo
echo "==> Public URLs:"
echo "    https://gunawan-paperclip.digital-lab.ai"
echo "    https://gunawan-bridge.digital-lab.ai"
