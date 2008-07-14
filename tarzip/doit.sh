#!/bin/sh
# $Id$

BUILD=PACKRELEASE:

echo $BUILD The purpose of this shellscript is to take the contents
echo $BUILD of the build directory, and create tar and zip files.

# Check that JAVA_HOME is set correctly (for jar)
if test ! -x "$JAVA_HOME"/bin/jar
then
    echo JAVA_HOME is not set correctly.
    exit 1;
fi



if test ! -d $DESTDIR
then
    echo The output directory $DESTDIR does not exist.
    exit 1;
fi

echo "This script expects that the directory VERSION_X_Y_X/argouml/build"
echo "contains a newly built release."
echo ""

if test -n "$RELEASE"
then
    releasename=$RELEASE
else
    echo "Give the name of the release (like X.Y.Z)."
    read releasename
fi

mkdir $DESTDIR/argouml-$releasename

directory=VERSION_`echo $releasename | sed 's/\./_/g'`

if test ! -d $directory
then
    echo The directory $directory does not exist.
    exit 1;
fi
cd $directory

echo "$BUILD Create the zip and tar files."
mkdir DIST
(
  cd argouml/build;
  mkdir argouml-$releasename
  cp *.jar README.txt *.sh *.bat argouml-$releasename
  mkdir argouml-$releasename/ext
  cp ext/*.jar argouml-$releasename/ext

  # Extra file for argouml-sql.
  cp ext/domainmapping.xml argouml-$releasename/ext

  "$JAVA_HOME"/bin/jar cvf ../../DIST/ArgoUML-$releasename.zip argouml-$releasename
  tar cvf ../../DIST/ArgoUML-$releasename.tar argouml-$releasename
  rm -rf argouml-$releasename
)

# The libs are now from different directories but all copied to
# argouml/build. Lets fetch all those that don't start with 
# argouml and that will be good enough hopefully
# TODO: Make this more solid or perhaps stop distributing libs.
(
  cd argouml/build;
  FILES=`ls *.txt *.jar | grep -v '^argouml'`
  "$JAVA_HOME"/bin/jar cvf ../../DIST/ArgoUML-$releasename-libs.zip $FILES
  tar cvf ../../DIST/ArgoUML-$releasename-libs.tar $FILES
)
(
  SRCDIRS="argouml/src/*/src argouml/src/*/build.xml argouml-*/src argouml-*/build.xml"
  zip -r DIST/ArgoUML-$releasename-src.zip $SRCDIRS -x "*/.svn/*"
  tar cvf DIST/ArgoUML-$releasename-src.tar --exclude=".svn" $SRCDIRS
)
( cd DIST && gzip -v *.tar )

sed "s,@URLROOT@,http://argouml-downloads.tigris.org/nonav/argouml-$releasename,g;s,@VERSION@,$releasename,g" < `dirname $0`/release_html.template > DIST/index.html

echo $BUILD copying to the svn directory
mv DIST/* $DESTDIR/argouml-$releasename
rmdir DIST

echo Add and commit the newly created directory
echo $DESTDIR/$directoryname

echo Update the index.html in the argouml-downloads project.
