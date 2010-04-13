#!/bin/bash

REPO_DIR="$1"
TRAC_DIR="$2"
TRAC_NAME="$3"
TRAC_DESC="$4"
ADMIN_USER="${5:-dwc@ufl.edu}"
TRAC_USER="${6:-apache}"
TRAC_GROUP="${7:-apache}"
TRAC_APACHE_INCLUDES="${8:-/etc/apache2/vhosts.d/trac}"

if [ "x$TRAC_DIR" == "x" ]; then
    echo "You must specify a location for the Trac instance." > /dev/stderr
    exit 1
fi

if [ "x$TRAC_NAME" == "x" ]; then
    echo "You must specify project name for the Trac instance." > /dev/stderr
    exit 2
fi

if [ ! -d "$REPO_DIR" ]; then
    echo "You must have a Subversion repository at '$REPO_DIR'." > /dev/stderr
    exit 3
fi

if [ -d "$TRAC_DIR" ]; then
    echo "It looks like a Trac instance already exists at '$TRAC_DIR'." > /dev/stderr
    exit 4
fi

TRAC_SUBDIR="$(basename $TRAC_DIR)"

trac-admin "$TRAC_DIR" initenv "$TRAC_NAME" "sqlite:db/trac.db" svn "$REPO_DIR" \
    && mkdir -p "$TRAC_DIR"/gvcache/ \
    && chgrp apache "$TRAC_DIR"/attachments/ "$TRAC_DIR"/db/ "$TRAC_DIR"/gvcache/ "$TRAC_DIR"/db/trac.db "$TRAC_DIR"/log/ \
    && chmod g+w "$TRAC_DIR"/attachments/ "$TRAC_DIR"/db/ "$TRAC_DIR"/gvcache/ "$TRAC_DIR"/db/trac.db "$TRAC_DIR"/log/ \
    && mkdir -p "$TRAC_APACHE_INCLUDES" \
    && echo "Use TracProject \"$TRAC_DIR\" /trac/$TRAC_SUBDIR" > "$TRAC_APACHE_INCLUDES/$TRAC_SUBDIR".include \
    && trac-admin "$TRAC_DIR" component remove component1 \
    && trac-admin "$TRAC_DIR" component remove component2 \
    && trac-admin "$TRAC_DIR" milestone remove milestone1 \
    && trac-admin "$TRAC_DIR" milestone remove milestone2 \
    && trac-admin "$TRAC_DIR" milestone remove milestone3 \
    && trac-admin "$TRAC_DIR" milestone remove milestone4 \
    && trac-admin "$TRAC_DIR" version remove 1.0 \
    && trac-admin "$TRAC_DIR" version remove 2.0 \
    && trac-admin "$TRAC_DIR" permission add "$ADMIN_USER" webadmin \
    && trac-admin "$TRAC_DIR" permission add webadmin TRAC_ADMIN \
    && cat > "$TRAC_DIR"/conf/trac.ini <<EOF
# -*- coding: utf-8 -*-

[inherit]
file = /var/lib/trac/trac.ini

[header_logo]
link = https://trac.webadmin.ufl.edu/$TRAC_SUBDIR/

[project]
descr = $TRAC_DESC
name = $TRAC_NAME
url = https://trac.webadmin.ufl.edu/$TRAC_SUBDIR/

[trac]
repository_dir = $REPO_DIR
EOF

if [ $? ]; then
    echo "Trac instance configured at '$TRAC_DIR'. Don't forget to restart Apache."
else
    echo "Error configuring Trac instance at '$TRAC_DIR'." > /dev/stderr
    exit 5
fi
