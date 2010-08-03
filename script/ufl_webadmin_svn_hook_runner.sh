#!/bin/sh

REPO="$1"
REV="$2"

HOOK="$(basename $0)"

run-parts --arg="$REPO" --arg="$REV" -- "$REPO"/hooks/"$HOOK".d
