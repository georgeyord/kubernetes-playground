#! /usr/bin/env bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

cd "${SCRIPT_DIR}"

pwd


# Load all vars from `.env` file

set -o allexport
source .env
set +o allexport

KIND_CLUSTER_NAME="one-cluster"
S=30

# The following vars will be filled from code
ARGOCD_PASSWORD=""
DASHBOARD_ADMIN_TOKEN=""
DASHBOARD_READ_ONLY_TOKEN=""

# Be extra strict
set -o errexit
set -o nounset
set -o xtrace

function delete-cluster() {
  echo "Delete cluster..."
  kind delete cluster --name="${KIND_CLUSTER_NAME}"
}

function create-cluster() {
  echo "Create cluster..."
  # --name="${KIND_CLUSTER_NAME}" is omitted since the name is taken from the yaml file
  pushd "cluster"
  kind create cluster --config=one.yaml
  popd
}

function pause-cluster() {
  docker pause "${KIND_CLUSTER_NAME}-control-plane"
}

function unpause-cluster() {
  docker unpause "${KIND_CLUSTER_NAME}-control-plane"
}

function set-context() {
  echo "Ensure we are in the right Kubernetes context..."
  kubectx "kind-${KIND_CLUSTER_NAME}"
}

function add-ingress-controller() {
  echo "############# Ingress #############"
  echo "Create NGINX ingress from Kubernetes definitions..."
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

  sleep "${S:-1}"
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s
}

function delete-ingress-controller() {
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
}

function deploy-sample-ingress() {
  echo "Create Sample ingress from Kubernetes definitions"
  pushd "${SAMPLE_INGRESS_PATH}"
  kubectl apply -f  .
  popd

  wait-for-word-web-content "http://localhost/foo" "foo"
  wait-for-word-web-content "http://${SAMPLE_INGRESS_URL}" "foo"
}

function delete-sample-ingress() {
  pushd "${SAMPLE_INGRESS_PATH}"
  kubectl delete -f  .
  popd
}

function deploy-argocd() {
  echo "############# ArgoCD #############"

  echo "Create ArgoCD from Kubernetes definitions"
  pushd "${ARGOCD_PATH}"

  kubectl create namespace argocd || true
  # kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  helm repo add bitnami https://charts.bitnami.com/bitnami || true
  helm repo update
  helm upgrade --install argocd bitnami/argo-cd -n argocd -f values.yaml

  get-argocd-credentials

  sleep "${S:-1}"
  kubectl wait --namespace argocd \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=server,app.kubernetes.io/instance=argocd,app.kubernetes.io/name=argo-cd \
    --timeout=90s

  wait-for-word-web-content "https://${ARGOCD_URL}/" "argo"
  popd
}

function get-argocd-credentials() {
  echo "Username: \"admin\""
  ARGOCD_PASSWORD="$(kubectl -n argocd get secret argocd-secret -o jsonpath="{.data.clearPassword}" | base64 -d)"
  echo "Password: ${ARGOCD_PASSWORD}"
}

function login-argocd() {
  get-argocd-credentials
  argocd login "${ARGOCD_URL}" --name="${KIND_CLUSTER_NAME}" --username=admin --password="${ARGOCD_PASSWORD}" --insecure --grpc-web
}

function delete-argocd() {
  helm uninstall argocd -n argocd || true
}

function load-argocd-apps() {
  login-argocd

  argocd app create argocd-apps \
    --repo "${ARGOCD_SAMPLE_APPS_REPO}" \
    --path argocd-apps/base \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --sync-policy automated

  sleep "${S:-1}"
  kubectl wait --namespace samples \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/instance=echo-server \
    --timeout=90s

  wait-for-word-web-content "http://${SAMPLE_ARGOCD_APP_URL}" "echo-server"
}

function deploy-backstage() {
  echo "############# Backstage #############"

  echo "Load pre-built Backstage image"
  kind --name="${KIND_CLUSTER_NAME}" load docker-image "${BACKSTAGE_DOCKER_IMAGE}"

  echo "Create Backstage from Kubernetes definitions"
  kubectl create namespace backstage || true

  pushd "${BACKSTAGE_KUBERNETES_PATH}"
  kubectl apply -f  .
  popd

  sleep "${S:-1}"
  kubectl wait --namespace backstage \
    --for=condition=ready pod \
    --selector=app=backstage \
    --timeout=90s

  # wait-for-word-web-content "http://"${BACKSTAGE_KUBERNETES_URL}"" "backstage"
}

function delete-backstage() {
  pushd "${BACKSTAGE_KUBERNETES_PATH}"
  kubectl delete -f  .
  popd
}

function deploy-kubernetes-dashboard() {
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml

  pushd "${KUBERNETES_DASHBOARD_PATH}"
  kubectl apply -f dashboard-admin.yaml
  kubectl apply -f dashboard-read-only.yaml
  popd

  DASHBOARD_ADMIN_TOKEN="$(kubectl create token -n kubernetes-dashboard --duration 24h admin-user)"
  DASHBOARD_READ_ONLY_TOKEN="$(kubectl create token -n kubernetes-dashboard --duration 24h read-only-user)"
  echo """
### Kubernetes Dashboard Access ###

1. Run: kubectl proxy
2. Open in browser: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
3a. Use this Kubernetes Dashboard admin token (will expire in 1 day): ${DASHBOARD_ADMIN_TOKEN}
3b. OR use this Kubernetes Dashboard read-only access token (will expire in 1 day): ${DASHBOARD_READ_ONLY_TOKEN}
"""
}

function delete-kubernetes-dashboard() {
  pushd "${KUBERNETES_DASHBOARD_PATH}"
  kubectl delete -f dashboard-admin.yaml
  kubectl delete -f dashboard-read-only.yaml
  popd

  kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
}

# Helper functions

function wait-for-word-web-content() {
  until curl -s --insecure "${1}" | grep "${2}"; do
      date
      sleep "${S:-1}"
  done
}

# Bundle functions

function reset() {
  delete-cluster
  create-cluster
  set-context
  add-ingress-controller
  deploy-sample-ingress
  deploy-argocd
  login-argocd
  load-argocd-apps
  deploy-backstage
}

# Info functions

function get-running-pods() {
  set +o xtrace
  kubectl get po --all-namespaces --no-headers \
    | grep -v kube-system \
    | grep -v local-path-storage \
    | tee /dev/tty \
    | wc -l
}

function help() {
  set +o xtrace
  local basename
  basename=$(basename "${BASH_SOURCE[0]}")
  echo -e "----\nHelp\n----"
  sleep 0.5

  cat "${SCRIPT_DIR}/${basename}" | grep "function " | awk '{print $2}' | sed -E 's/[\(]//' | sed -E 's/[\)]//' | sort | tail -n +2
}

if [ -z "${1:-}" ]; then
  set -- help
fi

# Run the functions named at $1, pass the rest of the args
$1 "${@:2}"
