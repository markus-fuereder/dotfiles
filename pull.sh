#!/bin/bash

xcode-select --install

DRY="NO"
# DRY="YES"

if [ $DRY == "YES" ]; then
    echo "DRY RUN ..."
fi

CURRENT_DIR=$PWD
INSTALL_DIR="/etc"
TMP_INSTALL_DIR="/tmp"
GITHUB_USER="markus-fuereder"
REPO="dotfiles"
REPO_DIR="$INSTALL_DIR"/"$REPO"
REPO_TMP_DIR="$TMP_INSTALL_DIR"/"$REPO".tmp

set -u

clean_exit() {
  if [ -d "$REPO_TMP_DIR" ]; then
    rm -rf $REPO_TMP_DIR
  fi
  cd $CURRENT_DIR
  exit $1
}

abort() {
  printf "%s\n" "$@" >&2
  clean_exit 1
}

# CLONE REPO IF NOT EXISTS
REPO_URI="git@github.com:$GITHUB_USER/$REPO.git"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning $REPO_URI to $REPO_TMP_DIR"
    git clone $REPO_URI $REPO_TMP_DIR || abort "Failed to clone $REPO_URI"
    sudo mv $REPO_TMP_DIR $REPO_DIR
    # echo "Cloning $REPO_URI to $REPO_DIR"
    # sudo git clone $REPO_URI $REPO_DIR || abort "Failed to clone $REPO_URI"
else
    git -C $REPO_DIR pull || abort "Failed to pull $REPO_URI"
fi

sh link.sh

nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --show-trace --flake "$(readlink -f ~/.config/nix)#shared"

clean_exit 0
