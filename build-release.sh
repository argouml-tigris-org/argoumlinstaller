#!/bin/sh

#
# This script does two things:
# 1. Sets the tags / create the copy, in the involved projects.
# 2. Checks out and builds the copy.
#
# Either of these two must be specified explicitly
# -t do tag
# -b do build
# -tb do both
#

# argouml
PROJECTS="
    argouml-classfile \
    argouml-cpp \
    argouml-csharp \
    argouml-idl \
    argouml-php \
    argouml-de argouml-es argouml-en-gb argouml-fr argouml-it argouml-nb \
    argouml-pt argouml-ru \
    argouml-i18n-zh
    argoumlinstaller"

tag=false
build=false
while getopts tb found "$@"
do
    case $found in
    t)
        tag=true
        ;;
    b)
        build=true
        ;;
    ?)
        echo "Only the argument -t and -b are allowed." 1>&2
        exit 1
        ;;
    esac
done

echo "Give the name of the release (like 0.21.3 or 0.22.ALPHA_3)."
read release

RELEASE=$release
VERSIONNAME=VERSION_`echo $release | sed 's/\./_/g'`

# Set the tag
if $tag
then
  for proj in $PROJECTS
  do
    if svn info http://$proj.tigris.org/svn/$proj/releases |
       grep -q "Node Kind: directory"
    then
        :
    else
	echo releases does not exist in project $proj 1>&2
        exit 1
    fi

    if svn info http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME |
       grep -q "Node Kind: directory"
    then
	echo The tag $VERSIONNAME already exists in the $proj project. 1>&2
        exit 1
    fi
  done

  for proj in $PROJECTS
  do
    echo svn copy http://$proj.tigris.org/svn/$proj/trunk http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME
  done
fi
