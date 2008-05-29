#!/bin/sh

REPO="$1"

run-parts -- "$REPO"/hooks/post-commit.d
