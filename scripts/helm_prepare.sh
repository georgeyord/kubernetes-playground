#!/bin/bash

set -e

export HELM_NO_PREPARE="${HELM_NO_PREPARE:-0}"
if [[ "$1" == "-f" ]]; then HELM_NO_PREPARE=1; shift; fi

if [[ "${HELM_NO_PREPARE}" == "1" ]]; then
  echo >&2 "Bypass updating helm charts..." && sleep 0.2
else
  echo >&2 -e "\n########## Deploy prerequisites ########## \n"
  kubectl create namespace "cert-manager" || echo >&2 -e "OK"

  echo >&2 -e "\n\n########## Helm dependencies update ########## \n"
  helm repo add stable https://kubernetes-charts.storage.googleapis.com

  echo >&2 "Updating helm charts..." && sleep 0.2
  helm dependencies update
fi