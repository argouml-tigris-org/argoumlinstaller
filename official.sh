#!/bin/sh
# $Id$

BUILD=OFFICIAL:

# The purpose of this shellscript is to create an official release.
# It will use a set of other scripts from the argoumlinstaller project
# to do so.
#
# Before this script starts everything is built and signed correctly.
# This just constructs the tars, zips etc.

echo "Give the name of the release (like 0.21.3 or 0.22.ALPHA_3)."
read release

RELEASE=$release
VERSIONNAME=VERSION_`echo $release | sed 's/\./_/g'`
BUILDDIR=`pwd`/build/$VERSIONNAME/argouml/build
DOCBUILDDIR=`pwd`/build/$VERSIONNAME/argouml/documentation/build

DESTDIR=${DESTDIR-`pwd`/../argouml-downloads/www}

RELEASEFILENAME=`echo $release | sed 's/\./_/g'`
DIRECTORY=`pwd`/build/VERSION_${RELEASEFILENAME}

export DESTDIR BUILDDIR RELEASE DIRECTORY

# Do all kinds of tests!

# Check that JAVA_HOME is set correctly (for jar and jarsigner)
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

if test ! -d $BUILDDIR
then
    echo $BUILD The input directory $BUILDDIR does not exist.
    exit 1;
fi

# Update this whenever the version of log4j changes!
for file in argouml.jar log4j-1.2.6.jar java-interfaces.jar mof.jar
do
    if test ! -f $BUILDDIR/$file
    then
	echo $BUILD The $file file in $BUILDDIR does not exist.
	echo $BUILD 'Have you built the release?'
	exit 1;
    fi
done

# Tests for modules.
# This is a complete test to make sure none of the module have failed.
for file in \
    argo_classfile.jar \
    argo_cpp.jar argo_idl.jar argo_php.jar argouml-csharp.jar \
    argouml-i18n-de.jar \
    argouml-i18n-en_GB.jar argouml-i18n-es.jar \
    argouml-i18n-fr.jar \
    argouml-i18n-it.jar \
    argouml-i18n-nb.jar \
    argouml-i18n-pt.jar \
    argouml-i18n-pt_BR.jar \
    argouml-i18n-ru.jar \
    argouml-i18n-zh.jar
do
    if test ! -f $BUILDDIR/ext/$file
    then
	echo $BUILD The $file file in $BUILDDIR/ext does not exist.
	echo $BUILD 'Have you built the modules?'
	exit 1;
    fi
done

# Are we in the right directory?
if test ! -d $DIRECTORY
then
    echo $BUILD The directory $DIRECTORY does not exist. Version given incorrectly.
    exit 1;
fi

# Is the pdf documentation built?
if test ! -f $DOCBUILDDIR/documentation/pdf/manual/argomanual.pdf
then
    echo $BUILD The pdf version of the manual does not exist. Build incorrect.
    exit 1;
fi

# Test for javawebstart
if ( javawebstart/createJWS.sh -t )
then
    : OK
else
    echo $BUILD The java web start is not correctly setup.
    exit 1;
fi

# Add more tests above...

# All clear!


## Start doing things
set -x

TARZIPDOIT=`pwd`/tarzip/doit.sh
chmod +x $TARZIPDOIT &&
(
    cd $DIRECTORY/.. &&
    $TARZIPDOIT
)

(
    cd $DIRECTORY/.. &&
    for pdffile in $DOCBUILDDIR/documentation/pdf/*/*.pdf
    do
        cp $pdffile $DESTDIR/argouml-$RELEASE/`basename $pdffile .pdf`-$RELEASE.pdf
    done
)

(
    cd appbund &&
    ./doit.sh
)
mv build/ArgoUML-*.app.tgz $DESTDIR/argouml-$RELEASE


javawebstart/createJWS.sh

NSISDOIT=`pwd`/nsis/doit.sh
chmod +x $NSISDOIT &&
(
  $NSISDOIT
)


## Do most of the subversion adding.
(
    cd $DESTDIR
    svn add argouml-$RELEASE
    svn propset svn:mime-type application/octet-stream argouml-$RELEASE/*.pdf
    svn add jws/argouml-$RELEASE.jnlp
    svn status maven2 | awk '/^?/ { print $2 }' | xargs svn add
)
