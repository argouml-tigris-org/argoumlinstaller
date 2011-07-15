#!/bin/sh
#
# Add sha1 checksums in the maven repository.
#
find . -type d -name .svn -prune -o -name \*.sha1 -prune -o -type f -print |
while read filename
do
  if test -f $filename.sha1
  then
    : $filename already has a checksum
  else
    echo Creating checksum file for $filename
    sha1sum $filename |
      awk '{ print $1 }' > $filename.sha1
  fi
done
