#!/bin/sh
# $Id$

BUILD=TEST-OFFICIAL-CONTENTS:

BUILDDIR="$1"

if test ! -d $BUILDDIR
then
    echo $BUILD The input directory $BUILDDIR does not exist.
    exit 1;
fi

# Update this whenever the version of log4j changes!
for file in \
    argouml.jar \
    argouml-model.jar argouml-mdr.jar argouml-euml.jar \
    log4j-1.2.6.jar \
    java-interfaces.jar mof.jar
do
    if test ! -f $BUILDDIR/$file
    then
	echo $BUILD The $file file in $BUILDDIR does not exist.
	exit 1;
    fi
done

# Tests for modules in ext directory
# This is a complete test to make sure none of the module have failed.
for file in \
    argouml-diagrams-activity.jar \
    argouml-diagrams-deployment.jar \
    argouml-diagrams-sequence.jar \
    argouml-diagrams-state.jar \
    argouml-notation.jar \
    argouml-transformer.jar \
    argouml-umlpropertypanels.jar \
    argo_java.jar \
    argo_cpp.jar argo_idl.jar argo_php.jar argouml-csharp.jar \
    argo_argoprint.jar \
    argouml-sql.jar \
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
	exit 1;
    fi
done

exit 0

