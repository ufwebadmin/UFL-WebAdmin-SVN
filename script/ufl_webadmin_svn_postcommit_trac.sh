#!/bin/sh

REPO="$1"
REV="$2"

TRAC_DIR="/var/lib/trac/env/$(basename $REPO)"

if [ -d "$TRAC_DIR" ]; then
    /usr/bin/python /usr/share/doc/trac-*/contrib/trac-post-commit-hook \
	-p "$TRAC_DIR" \
	-r "$REV"
fi
