#!/bin/sh

SVNLOOK=/usr/bin/svnlook
SVNNOTIFY=/usr/bin/svnnotify

REPO="$1"
REV="$2"

"$SVNNOTIFY" --repos-path "$REPO" --revision "$REV" --svnlook "$SVNLOOK" --to webadmin-dev-l@lists.ufl.edu --from webmaster@ufl.edu --subject-prefix "[WebAdmin SVN]" --subject-cx --with-diff
