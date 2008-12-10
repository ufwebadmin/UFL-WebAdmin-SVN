#!/bin/sh

SVNLOOK=/usr/bin/svnlook

REPO="$1"
REV="$2"
LOG="$($SVNLOOK log -r "$REV" "$REPO")"
AUTHOR="$($SVNLOOK author -r "$REV" "$REPO")"

TRAC_DIR="/var/lib/trac/env/$(basename $REPO)"
TRAC_URL="http://trac.webadmin.ufl.edu/$(basename $REPO)"

if [ -d "$TRAC_DIR" ]; then
    /usr/bin/python /usr/share/doc/trac-*/contrib/trac-post-commit-hook \
	-p "$TRAC_DIR" \
	-r "$REV"
fi
