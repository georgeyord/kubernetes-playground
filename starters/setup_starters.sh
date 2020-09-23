#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE}")";
STARTERS_PATH="$(pwd)"

mkdir -p ~/.helm

if [ -d ~/.helm/starters ] || [ -f ~/.helm/starters ]; then
  echo "Moving existing 'starters' folder to '~/.helm/starters.bak'"
  mv ~/.helm/starters ~/.helm/starters.bak
fi

cd ~/.helm

echo "Creating a soft link from '${STARTERS_PATH}' folder in repo to '~/.helm/starters'"
ln -s "${STARTERS_PATH}" .

echo "Done, use 'helm create --starter [STARTER]' to use one of the starter charts to create a new chart"