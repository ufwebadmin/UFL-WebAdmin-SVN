#!/bin/sh

REPO="$1"
REV="$2"

TRAC_DIR="/var/lib/trac/env/$(basename $REPO)"

if [ -d "$TRAC_DIR" ]; then
    /usr/bin/trac-admin "$TRAC_DIR" changeset added "$REPO" "$REV"
fi
