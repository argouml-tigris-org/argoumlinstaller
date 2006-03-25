#!/bin/sh

# Compare two jar files.
#
# If they have the same contents and are signed by the same key, they are
# judged to be the same.

file1=$1
file2=$2

if test ! -r "$file1"; then
    echo $0: $file1 is not readable.
    exit 1
fi
if test ! -r "$file2"; then
    echo $0: $file2 is not readable.
    exit 1
fi

if cmp $file1 $file2; then
    # They are the same
    exit 0
fi

# Now, we need to unpack and then compare the contents of every file 
# except the *.dsa file.
TMP=/tmp/compare-jars$$
trap "rm -rf $TMP" 0 1 2 15

echo TMP is $TMP

mkdir $TMP $TMP/1 $TMP/2 || exit 1
unzip -d $TMP/1 $file1 || exit 1
unzip -d $TMP/2 $file2 || exit 1

rm $TMP/1/META-INF/*.DSA
rm $TMP/2/META-INF/*.DSA

diff -rq $TMP/1 $TMP/2
res=$?

rm -rf $TMP

exit $res
