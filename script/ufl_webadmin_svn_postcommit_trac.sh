#!/bin/sh

SVNLOOK=/usr/bin/svnlook

REPO="$1"
REV="$2"
LOG="$($SVNLOOK log -r "$REV" "$REPO")"
AUTHOR="$($SVNLOOK author -r "$REV" "$REPO")"

TRAC_DIR="/var/lib/trac/$(basename $REPO)"
TRAC_URL="http://trac.webadmin.ufl.edu/$(basename $REPO)"

if [ -d "$TRAC_DIR" ]; then
    /usr/bin/python /usr/bin/ufl_webadmin_svn_postcommit_trac.py \
	-p "$TRAC_DIR" \
	-r "$REV" \
	-u "$AUTHOR" \
	-m "$LOG" \
	-s "$TRAC_URL"
fi
