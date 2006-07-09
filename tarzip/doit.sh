#!/bin/sh
# $Id$

BUILD=PACKRELEASE:

echo $BUILD The purpose of this shellscript is to take the contents
echo $BUILD of the build directory, and create tar and zip files.

# Check that JAVA_HOME is set correctly (for jar)
if test ! -x $JAVA_HOME/bin/jar
then
    echo JAVA_HOME is not set correctly.
    exit 1;
fi

if test ! -d ../svn/argouml-downloads/www
then
    echo The output directory ../svn/argouml-downloads/www does not exist.
    exit 1;
fi

echo "This script expects that the directory VERSION_X_Y_X_F/argouml/build"
echo "contains a newly built release."
echo ""

if test -n "$RELEASE"
then
    releasename=$RELEASE
else
    echo "Give the name of the release (like X.Y.Z)."
    read releasename
fi

mkdir ../svn/argouml-downloads/www/argouml-$releasename

directory=VERSION_`echo $releasename | sed 's/\./_/g'`_F

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
  $JAVA_HOME/bin/jar cvf ../../DIST/ArgoUML-$releasename.zip *.jar README.txt *.sh *.bat ext/*.jar
  tar cvf ../../DIST/ArgoUML-$releasename.tar *.jar README.txt *.sh *.bat ext/*.jar
)
(
  cd argouml/lib;
  $JAVA_HOME/bin/jar cvf ../../DIST/ArgoUML-$releasename-libs.zip *.txt *.jar
  tar cvf ../../DIST/ArgoUML-$releasename-libs.tar *.txt *.jar
)
(
  SRCDIRS="argouml/src_new argouml/src/*/src argouml-*/src"
  $JAVA_HOME/bin/jar cvf DIST/ArgoUML-$releasename-src.zip $SRCDIRS
  tar cvf DIST/ArgoUML-$releasename-src.tar --exclude="CVS" $SRCDIRS
)
( cd DIST && gzip -v *.tar )

sed "s,@URLROOT@,http://argouml-downloads.tigris.org/nonav/argouml-$releasename,g;s,@VERSION@,$releasename,g" < argoumlinstaller/tarzip/release_html.template > DIST/index.html

echo $BUILD copying to the svn directory
mv DIST/* ../../svn/argouml-downloads/www/argouml-$releasename
rmdir DIST

echo Add and commit the newly created directory
echo ../svn/argouml-downloads/www/$directoryname

echo Update the index.html in the argouml-downloads project.
