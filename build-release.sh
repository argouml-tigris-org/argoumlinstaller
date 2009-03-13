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
    argouml-cpp \
    argouml-csharp \
    argouml-idl \
    argouml-java \
    argouml-php \
    argouml-sql \
    \
    argouml-de argouml-es argouml-en-gb argouml-fr argouml-it argouml-nb \
    argouml-pt argouml-pt-br \
    argouml-ru \
    argouml-i18n-zh \
    \
    argouml-documentation \
    "

RELATIVE_ANT=tools/apache-ant-1.7.0/bin/ant


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
USERNAME=linus

echo Release: $release
echo Tagname: $VERSIONNAME
echo Destdir: $DESTDIR
echo "User:    $USERNAME"

svn_add_prop()
{
  # $1 property
  # $2 the line to add
  # $3 the path
  TMPFILE=/tmp/svn_add_prop$$.txt
  TMPDIR=/tmp/svn_add_prop$$.dir
  svn propget --non-interactive $1 $3 | egrep -v '^$' > $TMPFILE
  echo $2 >> $TMPFILE
  svn co -q --username $USERNAME -N $3 $TMPDIR
  svn propset -q --non-interactive $1 --file $TMPFILE $TMPDIR
  svn commit --username $USERNAME -q -m"Updated the $1 tag." $TMPDIR
  rm $TMPFILE
  rm -rf $TMPDIR
}

verifyalldefaultidentitiessetup() {
  echo -n Checking $* default login / password combinations
  for proj in $PROJECTS
  do
    echo -n .
    svn propget --username $USERNAME dummy:tag \
      http://$proj.tigris.org/svn/$proj/trunk
  done
  echo done.
}


# Set the tag
if $tag
then
  echo -n Checking for already existing tag
  for proj in $PROJECTS
  do
    echo -n .
    if svn info http://$proj.tigris.org/svn/$proj/releases 2>/dev/null |
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

  echo Checking for ant
  if svn info http://argouml.tigris.org/svn/argouml/trunk/$RELATIVE_ANT 2>/dev/null |
      grep -q "Node Kind: file"
  then
    : ok it does exist
  else
    echo Ant is missing at $RELATIVE_ANT
    if $dontjusttest
    then
      exit 1
    fi
  fi
  echo done.
  

  if $dontjusttest
  then
    verifyalldefaultidentitiessetup and setting

    # Fixing subclipse:tags property for the main project
    svn info http://argouml.tigris.org/svn/argouml/trunk |
    grep '^Revision:' |
    while read zz rev
    do
      for subdir in \
             modules/dev \
             src/argouml-app \
             src/argouml-core-diagrams-sequence2 \
             src/argouml-core-infra \
             src/argouml-core-model \
             src/argouml-core-model-euml \
             src/argouml-core-model-mdr \
             src \
             tools www
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

      svn copy --username $USERNAME http://$proj.tigris.org/svn/$proj/trunk http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME -m"Creating the release $RELEASE"
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
    if svn info http://$proj.tigris.org/svn/$proj/releases 2>/dev/null |
       grep -q "Node Kind: directory"
    then
        :
    else
	echo releases subdir does not exist in project $proj 1>&2
        exit 1
    fi

    echo -n .
    if svn info http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME 2>/dev/null |
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
  verifyalldefaultidentitiessetup
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
      svn co --username $USERNAME http://$proj.tigris.org/svn/$proj/releases/$VERSIONNAME $proj
    done
  )
fi


if $build
then
  verifyjavahome javac
  verifyallcheckedout

  # Test that the version does not contain pre.
  if grep -q "argo.core.version=PRE-" $DESTDIR/argouml/src/argouml-app/default.properties
  then
    echo The version contains PRE-. 1>&2
    exit 1
  fi

  # Build things
  echo Build the core argouml that all projects depend on
  cd $DESTDIR/argouml && $RELATIVE_ANT install

  echo Build all projects
  (
    cd $DESTDIR
    for proj in $PROJECTS
    do
      echo Building $proj
      ( cd $proj && ../argouml/$RELATIVE_ANT install )
    done
  )

  echo Update the manifest to include modules files.
  cd $DESTDIR/argouml && $RELATIVE_ANT update-argouml.jar-manifest
fi

# Build the English pdf version of the Quick Guide and User Manual
if $builddoc
then
  verifyjavahome java
  verifyallcheckedout

  # Test that the version does not contain pre.
  if grep -q "argo.core.version.  *value=.PRE-" $DESTDIR/argouml-documentation/build.xml
  then
    echo The version contains PRE-. 1>&2
    exit 1
  fi

  # Test that Jimi is in place
  if test ! -f $JIMICLASSES
  then
    echo The file $JIMICLASSES does not exist. 1>&2
    exit 1
  fi

  # Build things
  echo Copy Jimi
  cp $JIMICLASSES $DESTDIR/argouml-documentation/tools/lib
  echo Building documentation
  cd $DESTDIR/argouml-documentation && ./build.sh released-pdfs
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
