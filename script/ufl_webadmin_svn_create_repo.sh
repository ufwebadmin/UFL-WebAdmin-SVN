#!/bin/bash

REPO_DIR="$1"
REPO_USER="${2:-apache}"
REPO_GROUP="${3:-apache}"

if [ "x$REPO_DIR" == "x" ]; then
    echo "You must specify a location for the Subversion repository." > /dev/stderr
    exit 1
fi

if [ -d "$REPO_DIR" ]; then
    echo "It looks like a repository already exists at '$REPO_DIR'." > /dev/stderr
    exit 2
fi

svnadmin create --fs-type fsfs "$REPO_DIR" \
    && ln -snf /usr/bin/ufl_webadmin_svn_postcommit.sh "$REPO_DIR"/hooks/post-commit \
    && mkdir "$REPO_DIR"/hooks/post-commit.d \
    && ln -snf /usr/bin/ufl_webadmin_svn_postcommit_email.sh "$REPO_DIR"/hooks/post-commit.d/ \
    && ln -snf /usr/bin/ufl_webadmin_svn_postcommit_trac.sh "$REPO_DIR"/hooks/post-commit.d/ \
    && chown -R "$REPO_USER":"$REPO_GROUP" "$REPO_DIR" \
    && find "$REPO_DIR" -print0 | xargs -0 chmod o-rwx

if [ $? ]; then
    echo "Subversion repository created at '$REPO_DIR'."
else
    echo "Error creating Subversion repository at '$REPO_DIR'." > /dev/stderr
    exit 3
fi
