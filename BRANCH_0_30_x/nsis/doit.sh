#!/bin/sh
#
# Script for launching makensis to create the ArgoUML windows installer.
# .sh file version.
#
# It assumes that the working directory when this script is called
# is one level up from where the script resides, i.e. argoumlinstaller/
#
# The work is done by tools/makensis.exe, which takes a .nsi file, and builds
# a windows installer (.exe). makensis is part of the Nullsoft Scriptable
# Installer System (NSIS), http://nsis.sourceforge.net/Main_Page
#
# If the environment variable $RELEASE has already been defined, this
# is used as the release name, if not, a prompt is given to enter it.
#
# $DESTDIR can be set to define the output directory.
# 
# This script will normally be called from ./official.sh.
#
# $Id$

BUILD=NSIS_WIN_INSTALLER:

MAKENSIS=`pwd`/nsis/tools/makensis

echo $BUILD The purpose of this script is to use the contents
echo $BUILD of the build directory, to generate a windows installer.

# Check that MAKENSIS exists
if test ! -e $MAKENSIS
then
    echo MAKENSIS not found.
    exit 1;
fi

# Check that MAKENSIS is executable
test ! -x $MAKENSIS || chmod +x $MAKENSIS
if test ! -x $MAKENSIS
then
    echo $MAKENSIS was found but was not executable, chmod failed.
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

directory=build/VERSION_`echo $releasename | sed 's/\./_/g'`

if test ! -d $directory
then
    echo The directory `pwd`/$directory does not exist.
    exit 1;
fi

echo "$BUILD Creating nsis windows installer."
mkdir $directory/DIST
# The paths supplied to makensis are relative to the .nsi file location.
$MAKENSIS /DRELEASENAME=$releasename /DBUILDDIR=../$directory/argouml/build \
    /DOUTPUTDIR=../$directory/DIST nsis/installer_config.nsi
if test $? -ne 0
then
   echo Failed to create nsis windows installer.
   exit 1;
fi

echo $BUILD copying to the svn directory
mv $directory/DIST/* $DESTDIR/argouml-$releasename
rmdir $directory/DIST/

echo Add and commit the newly created directory
echo $DESTDIR/$directoryname

echo Update the index.html in the argouml-downloads project.
