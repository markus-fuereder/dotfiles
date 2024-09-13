#!/bin/bash
DRY="NO"
DRY="YES"

if [ $DRY == "YES" ]; then
    echo "DRY RUN ..."
fi

CURRENT_DIR=$PWD
INSTALL_DIR="/etc"
TMP_INSTALL_DIR="/tmp"
GITHUB_USER="markus-dot-fuereder"
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

# MOVE TO TMP DIR
cd $REPO_DIR
ls -la
CONFIG_DIR=~/.config
mkdir -p CONFIG_DIR

COLLECTION="collection"
COLLECTION_PATH="$REPO_DIR"/"$COLLECTION"/*
for SRC in $COLLECTION_PATH*
do 
    echo "$SRC"
    [ -L "${SRC%/}" ] && continue
    [ "$SRC" = "$COLLECTION_PATH" ] && continue

    NAME=$(basename "$SRC")
    echo "$SRC $NAME"
    DST="$CONFIG_DIR"/"$NAME"
    if [ $DRY != "YES" ]; then
        echo "ln -s $SRC ~/$TARGET"
        continue
    fi
    # ln -s $SRC ~/$TARGET
done

clean_exit 0









# for file in "$COLLECTION/**"; do

#     [ -L "${file%/}" ] && continue
#     echo "$file"
#     # if [[ -d "$file" ]]; then
#     #   TARGET=".config/$file"
#     #   echo "$file - $COLLECTION/$TARGET ~/$TARGET"
#     # fi
# done