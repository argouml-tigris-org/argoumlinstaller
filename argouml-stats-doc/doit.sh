#!/bin/sh

# Fix documentation for in the argouml-stats project for a specific release.

VERSION=0.32
WWWSVNPATH=http://argouml-stats.tigris.org/svn/argouml-stats/trunk/www

cat <<EOF |
en documentation
de documentation-de
es documentation-es
EOF
while read lang target
do
    cat <<EOF |
$lang/defaulthtml/manual manual-$VERSION
$lang/printablehtml/manual manual-$VERSION-single
$lang/defaulthtml/quickguide quickguide-$VERSION
$lang/printablehtml/quickguide quickguide-$VERSION-single
$lang/pdf pdf-$VERSION
EOF
    while read from to
    do
        svn copy -m"Fix for the $VERSION release." $WWWSVNPATH/daily-userdoc/$from $WWWSVNPATH/$target/$to
    done
done
