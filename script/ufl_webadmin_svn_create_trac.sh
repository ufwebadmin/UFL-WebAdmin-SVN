#!/bin/bash

REPO_DIR="$1"
TRAC_DIR="$2"
TRAC_NAME="$3"
TRAC_DESC="$4"
TRAC_DB="$5"
ADMIN_USER="${6:-dwc@ufl.edu}"
TRAC_USER="${7:-apache}"
TRAC_GROUP="${8:-apache}"
TRAC_APACHE_INCLUDES="${9:-/etc/apache2/vhosts.d/trac}"
TRAC_DOMAIN="${10:-trac.webadmin.ufl.edu}"
BASE_URL="${11:-https://$TRAC_DOMAIN}"

if [ "x$TRAC_DIR" == "x" ]; then
    echo "You must specify a location for the Trac instance." > /dev/stderr
    exit 1
fi

if [ "x$TRAC_NAME" == "x" ]; then
    echo "You must specify project name for the Trac instance." > /dev/stderr
    exit 1
fi

if [ "x$TRAC_DB" == "x" ]; then
    echo "You must specify the database connection string for the Trac instance." > /dev/stderr
    exit 1
fi

if [ ! -d "$REPO_DIR" ]; then
    echo "You must have a Subversion repository at '$REPO_DIR'." > /dev/stderr
    exit 1
fi

if [ -d "$TRAC_DIR" ]; then
    echo "It looks like a Trac instance already exists at '$TRAC_DIR'." > /dev/stderr
    exit 1
fi

TRAC_SUBDIR="$(basename $TRAC_DIR)"


#
# Functions
#

create_trac_instance() {
    trac-admin "$TRAC_DIR" initenv "$TRAC_NAME" "$TRAC_DB" svn "$REPO_DIR" \
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
        && trac-admin "$TRAC_DIR" permission add anonymous TICKET_CREATE \
        && mkdir -p "$TRAC_APACHE_INCLUDES" \
        && echo "Use TracProject /$TRAC_SUBDIR" > "$TRAC_APACHE_INCLUDES/$TRAC_SUBDIR".include \
        && cat > "$TRAC_DIR"/conf/trac.ini <<EOF
# -*- coding: utf-8 -*-

[header_logo]
link = $BASE_URL/$TRAC_SUBDIR/

[inherit]
file = /var/lib/trac/trac.ini

[notification]
smtp_replyto = trac+$TRAC_SUBDIR@trac.webadmin.ufl.edu

[project]
descr = $TRAC_DESC
name = $TRAC_NAME
url = $BASE_URL/$TRAC_SUBDIR/

[trac]
base_url = $BASE_URL/$TRAC_SUBDIR/
database = $TRAC_DB
repository_dir = $REPO_DIR
EOF
}

_update_permissions() {
    chgrp "$TRAC_GROUP" $@ && chmod g+w $@
}

update_permissions() {
    mkdir -p "$TRAC_DIR"/gvcache/ \
        && _update_permissions "$TRAC_DIR"/attachments/ "$TRAC_DIR"/conf/ "$TRAC_DIR"/gvcache/ "$TRAC_DIR"/log/ \

    # Update permissions for SQLite, if we're using it
    if [ -d "$TRAC_DIR"/db/ ]; then
        _update_permissions "$TRAC_DIR"/db/
    fi

    if [ -f "$TRAC_DIR"/db/trac.db ]; then
        _update_permissions "$TRAC_DIR"/db/trac.db
    fi
}

display_additional_configuration() {
    cat > /dev/stdout <<EOF
Trac instance configured at "$TRAC_DIR". Don't forget to restart
Apache.

To enable easy linking between Trac instances, Add the following to the global
Trac configuration under the "intertrac" section:

###
$TRAC_SUBDIR.title = $TRAC_NAME
$TRAC_SUBDIR.url = $BASE_URL/$TRAC_SUBDIR
###

To enable sending mail to this instance, add the following to the mail aliases
file:

###
trac+$TRAC_SUBDIR: "| /var/lib/trac/plugins/mail2trac -p /var/lib/trac/env/$TRAC_SUBDIR"
###
EOF
}


#
# Main script
#

main() {
    create_trac_instance && update_permissions

    if [ $? ]; then
        display_additional_configuration
    else
        echo "Error configuring Trac instance at '$TRAC_DIR'." > /dev/stderr
        exit 1
    fi
}

main
