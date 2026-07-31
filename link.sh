#!/bin/bash

DRY="NO"
# DRY="YES"

if [ $DRY == "YES" ]; then
    echo "DRY RUN ..."
fi

sudo mkdir -p -m 775 /usr/local/bin

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

# herdr keeps live sockets, logs and session.json in ~/.config/herdr, so the
# directory must not be replaced by a symlink. Its files are linked below.
FILE_LINKED="herdr"

for SRC in $COLLECTION_PATH*
do
    [ -L "${SRC%/}" ] && continue
    [ "$SRC" = "$COLLECTION_PATH" ] && continue

    NAME=$(basename "$SRC")
    [ "$NAME" = "$FILE_LINKED" ] && continue
    DST="$CONFIG_DIR"/"$NAME"
    if [ $DRY == "YES" ]; then
        echo "ln -s $SRC $DST"
        continue
    fi
    echo -n "[✖] Linking $NAME "
    rm -rf "$DST" && ln -sf "$SRC" "$DST" && echo -e "\r[✔] Linking $NAME" || echo " "
done

# Link herdr's config file only, leaving its runtime state in place.
HERDR_SRC="$REPO_DIR"/"$COLLECTION"/herdr/config.toml
HERDR_DST="$CONFIG_DIR"/herdr/config.toml
if [ $DRY == "YES" ]; then
    echo "ln -s $HERDR_SRC $HERDR_DST"
else
    echo -n "[✖] Linking herdr "
    mkdir -p "$CONFIG_DIR"/herdr && ln -sf "$HERDR_SRC" "$HERDR_DST" \
        && echo -e "\r[✔] Linking herdr " || echo " "
fi

sudo chmod -R 777 "$REPO_DIR"/"$COLLECTION"/zsh/secrets.zsh

clean_exit 0
