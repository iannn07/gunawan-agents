#!/usr/bin/env bash
# Installs k3s (single-node) with Traefik + local-path, then cert-manager.
# Run with: sudo bash scripts/install-k3s.sh
set -euo pipefail

CERT_MANAGER_VERSION="v1.15.3"
KUBECONFIG_DEST="${HOME}/.kube/config"
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: this script must be run with sudo (it installs k3s as a system service)" >&2
  exit 1
fi

echo "==> Installing k3s (server, disable servicelb + metrics-server, keep Traefik + local-path)"
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644 --disable=servicelb --disable=metrics-server" \
  sh -

echo "==> Waiting for k3s node to become Ready"
for i in {1..60}; do
  if /usr/local/bin/k3s kubectl get nodes 2>/dev/null | grep -q " Ready "; then
    break
  fi
  sleep 2
done
/usr/local/bin/k3s kubectl get nodes

echo "==> Copying kubeconfig to ${USER_HOME}/.kube/config"
mkdir -p "${USER_HOME}/.kube"
cp /etc/rancher/k3s/k3s.yaml "${USER_HOME}/.kube/config"
chown -R "${USER_NAME}:${USER_NAME}" "${USER_HOME}/.kube"
chmod 600 "${USER_HOME}/.kube/config"

echo "==> Symlinking kubectl for the non-root user"
if [[ ! -L /usr/local/bin/kubectl ]]; then
  ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl
fi

echo "==> Waiting for Traefik to be ready"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
for i in {1..60}; do
  if kubectl -n kube-system get deploy traefik 2>/dev/null | grep -q "1/1"; then
    break
  fi
  sleep 3
done
kubectl -n kube-system get deploy traefik

echo "==> Installing cert-manager ${CERT_MANAGER_VERSION}"
kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml"

echo "==> Waiting for cert-manager pods to become Ready (up to 3 min)"
kubectl -n cert-manager wait --for=condition=Ready pod --all --timeout=180s

echo
echo "==> k3s + cert-manager ready."
echo "    Run as ${USER_NAME}:   kubectl get nodes"
