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
# -d do build of documentation
# -s do sign
# Normal arguments to give: -tcbds
#
# This was tested for the first time during the 0.23.2 release.

PROJECTS=" \
    argouml \
    argouml-classfile \
    argouml-cpp \
    argouml-csharp \
    argouml-idl \
    argouml-php \
    argouml-de argouml-es argouml-en-gb argouml-fr argouml-it argouml-nb \
    argouml-pt argouml-pt-br \
    argouml-ru \
    argoumlinstaller \
    argouml-i18n-zh \
    "

tag=false
dontjusttest=false
checkout=false
build=false
builddoc=false
sign=false
while getopts Ttcbds found "$@"
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
    d)
        builddoc=true
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
BUILD=`pwd`/build
DESTDIR=$BUILD/$VERSIONNAME
JIMICLASSES=$BUILD/JimiProClasses.zip

echo Release: $release
echo Tagname: $VERSIONNAME
echo Destdir: $DESTDIR


svn_add_prop()
{
  # $1 property
  # $2 the line to add
  # $3 the path
  TMPFILE=/tmp/svn_add_prop$$.txt
  TMPDIR=/tmp/svn_add_prop$$.dir
  svn propget --non-interactive $1 $3 | egrep -v '^$' > $TMPFILE
  echo $2 >> $TMPFILE
  svn co -q -N $3 $TMPDIR
  svn propset -q --non-interactive $1 --file $TMPFILE $TMPDIR
  svn commit -q -m"Updated the $1 tag." $TMPDIR
  rm $TMPFILE
  rm -rf $TMPDIR
}


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
    # Fixing subclipse:tags property for the main project
    svn info http://argouml.tigris.org/svn/argouml/trunk |
    grep '^Revision:' |
    while read zz rev
    do
      for subdir in documentation lib modules/dev modules/menutest \
             src/model src/model-mdr src_new tests tools www
      do
        svn_add_prop subclipse:tags \
	    "$rev,$VERSIONNAME,/releases/$VERSIONNAME/$subdir,tag" \
	    http://argouml.tigris.org/svn/argouml/trunk/$subdir
      done
    done

    for proj in $PROJECTS
    do
      echo Creating the release in $proj

      svn info http://$proj.tigris.org/svn/$proj/trunk |
      grep '^Revision:' |
      while read zz rev
      do
        svn_add_prop subclipse:tags "$rev,$VERSIONNAME,/releases/$VERSIONNAME,tag" http://$proj.tigris.org/svn/$proj/trunk
      done

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

verifyallcheckedout() {
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


verifyjavahome() {
  # Check that JAVA_HOME is set correctly
  if test ! -x "$JAVA_HOME/bin/$1"
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

  # The reason for doing this at this point is that a network connection
  # is needed for this. If this is done here, then the rest of the process
  # can be done without the network.
  echo Downloading docbook
  cd $DESTDIR/argouml/documentation && ./build.sh docbook-xsl-get

fi


if $build
then
  verifyjavahome javac
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
      ( cd $proj && ../argouml/tools/apache-ant-1.6.5/bin/ant install )
    done
  )
fi

if $builddoc
then
  verifyjavahome java
  verifyallcheckedout

  # Test that the version does not contain pre.
  if grep -q "argo.core.version=PRE-" $DESTDIR/argouml/src_new/default.properties
  then
    echo The version contains PRE-. 1>&2
    exit 1
  fi

  # Test that the version does not contain pre.
  if test ! -f $JIMICLASSES
  then
    echo The file $JIMICLASSES does not exist. 1>&2
    exit 1
  fi

  # Build things
  echo Downloading docbook again
  cd $DESTDIR/argouml/documentation && ./build.sh docbook-xsl-get
  echo Copy Jimi
  cp $JIMICLASSES $DESTDIR/argouml/tools/lib
  echo Building documentation
  cd $DESTDIR/argouml/documentation && ./build.sh pdf
fi


if $sign
then
  verifyjavahome jar

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
