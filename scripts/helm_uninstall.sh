#!/bin/bash

set -e

helm uninstall 'experiment' -n default
helm uninstall 'cert-manager' -n cert-manager

kubectl delete namespace 'cert-manager'
