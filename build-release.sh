#!/bin/sh
# $Id$

#
# This script prepares the release into build/VERSION_X_Y_Z directory.
#
# Either of these arguments must be specified or the script does nothing
# -T test for the tag (tests that there is no tag there already).
# -t do tag
# -c do checkout
# -b do build
# -s do sign
# Normal argument: -tcbs
#
# This will be tested for the first time during the 0.23.2 release.

PROJECTS=" \
    argouml \
    argouml-classfile \
    argouml-cpp \
    argouml-csharp \
    argouml-idl \
    argouml-php \
    argouml-de argouml-es argouml-en-gb argouml-fr argouml-it argouml-nb \
    argouml-pt \
    argouml-ru \
    argoumlinstaller \
    argouml-i18n-zh \
    "

tag=false
dontjusttest=false
checkout=false
build=false
sign=false
while getopts Ttcbs found "$@"
do
    case $found in
    T)
        tag=true
	;;
    t)
        tag=true
        dontjusttest=true
        ;;
    c)
        checkout=true
        ;;
    b)
        build=true
        ;;
    s)
        sign=true
        ;;
    ?)
        exit 1
        ;;
    esac
done

echo "Give the name of the release (like 0.21.3 or 0.22.ALPHA_3)."
read release

RELEASE=$release
VERSIONNAME=VERSION_`echo $release | sed 's/\./_/g'`
DESTDIR=`pwd`/build/$VERSIONNAME

echo Release: $release
echo Tagname: $VERSIONNAME
echo Destdir: $DESTDIR

# Set the tag
if $tag
then
  echo -n Checking for already existing tag
  for proj in $PROJECTS
  do
    echo -n .
    if svn info http://$proj.tigris.org/svn/$proj/releases |
       grep -q "Node Kind: directory"
    then
      echo -n .
      if svn info http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME 2>/dev/null |
	 grep -q "Node Kind: directory"
      then
	  echo The release $VERSIONNAME already exists in the $proj project. 1>&2
	  if $dontjusttest
	  then
	    exit 1
	  fi
      fi
    else
	echo releases subdir does not exist in project $proj 1>&2
        if $dontjusttest
        then
          exit 1
        fi
    fi
  done
  echo done.

  if $dontjusttest
  then
    for proj in $PROJECTS
    do
      echo Creating the release in $proj
      svn copy http://$proj.tigris.org/svn/$proj/trunk http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME -m"Creating the release $RELEASE"
    done
  else
    exit 0
  fi
fi


verifyallexists() {
  echo -n Checking for existing tag
  for proj in $PROJECTS
  do
    echo -n .
    if svn info http://$proj.tigris.org/svn/$proj/releases |
       grep -q "Node Kind: directory"
    then
        :
    else
	echo releases subdir does not exist in project $proj 1>&2
        exit 1
    fi

    echo -n .
    if svn info http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME |
       grep -q "Node Kind: directory"
    then
	:
    else
	echo The release $VERSIONNAME does not exists in the $proj project. 1>&2
        exit 1
    fi
  done
  echo done.
}

verifyallexists() {
  echo -n Checking for checked out
  for proj in $PROJECTS
  do
    echo -n .
    if test -d $DESTDIR/$proj
    then
	:
    else
	echo The checked out copy $DESTDIR/$proj does not exist. 1>&2
        exit 1
    fi
  done
  echo done.
}


verifyjavahomejavac() {
  # Check that JAVA_HOME is set correctly (for jar and jarsigner)
  if test ! -x "$JAVA_HOME/bin/javac"
  then
    echo JAVA_HOME is not set correctly.
    exit 1;
  fi
}

verifyjavahomejar() {
  # Check that JAVA_HOME is set correctly (for jar and jarsigner)
  if test ! -x "$JAVA_HOME/bin/jar"
  then
    echo JAVA_HOME is not set correctly.
    exit 1;
  fi
}


if $checkout
then
  verifyallexists

  if test -d "$DESTDIR"
  then
    echo The directory $DESTDIR already exists 1>&2
    exit 1
  fi

  echo Checking out everything
  mkdir -p $DESTDIR

  (
    cd $DESTDIR
    for proj in $PROJECTS
    do
      echo Checking out $proj
      svn co http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME $proj
    done
  )
fi


if $build
then
  verifyjavahomejavac
  verifyallcheckedout

  # Test that the version does not contain pre.
  if grep -q "argo.core.version=PRE-" $DESTDIR/argouml/src_new/default.properties
  then
    echo The version contains PRE-. 1>&2
    exit 1
  fi

  # Build things
  echo Building package in core
  cd $DESTDIR/argouml/src_new && ./build.sh package
  (
    cd $DESTDIR
    for proj in $PROJECTS
    do
      echo Building $proj
      ( cd $proj && ../argouml/tools/ant-1.6.2/bin/ant install )
    done
  )
fi

if $sign
then
  verifyjavahomejar

  (
    cd $DESTDIR/argouml/build &&
    find . -name \*.jar -print |
    while read jarname
    do
      echo "signing $jarname"
      "$JAVA_HOME/bin/jarsigner" -storepass secret $jarname argouml
    done
  )
fi
