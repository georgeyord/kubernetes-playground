#!/bin/bash

helm uninstall 'experiment' -n default
helm uninstall 'cert-manager' -n cert-manager

kubectl delete secrets --field-selector type=kubernetes.io/tls
kubectl delete namespace 'cert-manager'
kubectl delete crds --all
