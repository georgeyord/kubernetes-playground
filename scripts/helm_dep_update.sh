#!/bin/bash

set -e

echo >&2 -e "\n\n########## Helm dependencies update ########## \n"
helm3 repo add stable https://kubernetes-charts.storage.googleapis.com

echo >&2 "Updating helm charts..." && sleep 0.2
helm3 dependencies update
