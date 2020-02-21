#!/bin/bash

set -e

export HELM_DEP_IGNORE="${HELM_DEP_IGNORE:-0}"
if [[ "$1" == "-f" ]]; then HELM_DEP_IGNORE=1; shift; fi

if [[ "${HELM_DEP_IGNORE}" == "1" ]]; then
  echo >&2 "Bypass updating helm charts..." && sleep 0.2
else
  echo >&2 -e "\n########## Deploy prerequisites ########## \n"
  kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml --validate=false >&2

  echo >&2 -e "\n\n########## Helm dependencies update ########## \n"
  helm repo add stable https://kubernetes-charts.storage.googleapis.com

  echo >&2 "Updating helm charts..." && sleep 0.2
  helm dependencies update
fi