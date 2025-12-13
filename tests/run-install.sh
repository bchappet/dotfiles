#!/usr/bin/env bash

set -e

echo "==================================="
echo "Running install...                 "
echo "==================================="

git clone https://github.com/bchappet/dotfiles.git
cd dotfiles
./install

bash tests/verify-install.sh


