#!/bin/bash

DRY="NO"
# DRY="YES"

if [ $DRY == "YES" ]; then
    echo "DRY RUN ..."
fi

INSTALL_DIR="/etc"

REPO="dotfiles"
REPO_DIR="$INSTALL_DIR"/"$REPO"

set -u

clean_exit() {
  exit $1
}


# MOVE TO TMP DIR
cd $REPO_DIR

CONFIG_DIR=~/.config
mkdir -p $CONFIG_DIR

COLLECTION="collection"
COLLECTION_PATH="$REPO_DIR"/"$COLLECTION"/*
for SRC in $COLLECTION_PATH*
do
    [ -L "${SRC%/}" ] && continue
    [ "$SRC" = "$COLLECTION_PATH" ] && continue

    NAME=$(basename "$SRC")
    DST="$CONFIG_DIR"/"$NAME"
    if [ $DRY == "YES" ]; then
        echo "ln -s $SRC $DST"
        continue
    fi
    echo -n "[✖] Linking $NAME "
    rm -rf "$DST" && ln -sf "$SRC" "$DST" && echo -e "\r[✔] Linking $NAME" || echo " "
done

clean_exit 0
