#!/bin/sh
# $Id$

BUILD=OFFICIAL:

echo $BUILD The purpose of this shellscript is to create an official release.
echo $BUILD It will use a set of scripts defined by the contents.

DESTDIR=${DESTDIR-`pwd`/../../svn/argouml-downloads/www}
BUILDDIR=${BUILDDIR-`pwd`/argouml/build}

# Do all kinds of tests!

# Check that JAVA_HOME is set correctly (for jar and jarsigner)
if test ! -x $JAVA_HOME/bin/jar
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

for file in argouml.jar log4j.jar java-interfaces.jar mof.jar
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




echo "Give the name of the release (like 0.21.3 or 0.22.ALPHA_3)."
read release

RELEASE=$release
RELEASEFILENAME=`echo $release | sed 's/\./_/g'`
DIRECTORY=`pwd`/../VERSION_${RELEASEFILENAME}_F

# Are we in the right directory?
if test ! -d $DIRECTORY
then
    echo $BUILD The directory $DIRECTORY does not exist. Version given incorrectly.
    exit 1;
fi

tfile=XY$$ZZ
touch $tfile
if test ! -f $DIRECTORY/$tfile
then
    echo $BUILD This is not the right directory. $DIRECTORY points somewhere else.
    rm $tfile
    exit 1;
fi
rm $tfile

# Add more tests above...

# All clear!
export DESTDIR BUILDDIR RELEASE DIRECTORY


## Start doing things
set -x

(
    cd $BUILDDIR &&
    find . -name \*.jar -print |
    while read jarname
    do
        echo "signing $jarname"
        $JAVA_HOME/bin/jarsigner -storepass secret $jarname argouml
    done
)

chmod +x $DIRECTORY/argoumlinstaller/tarzip/doit.sh &&
(
    cd $DIRECTORY/.. &&
    $DIRECTORY/argoumlinstaller/tarzip/doit.sh
)

(
    cd $DIRECTORY/.. &&
    for pdffile in $BUILDDIR/documentation/pdf/*/*.pdf
    do
        cp $pdffile $DESTDIR/argouml-$RELEASE/`basename $pdffile .pdf`-$RELEASE.pdf
    done
)

(
    cd $DIRECTORY/argoumlinstaller/appbund &&
    ./doit.sh
)
(
    mv $DIRECTORY/argoumlinstaller/build/ArgoUML-*.app.tgz $DESTDIR/argouml-$RELEASE
)


(
# Fix this...
    cd ../argoumlinstaller/javawebstart &&
    ./createJWS.sh
)


