#!/bin/sh
# $Id$

# This file will copy the jar files that are modified from
# ../../VERSION_XX_F/argouml/build
# and
# ../../VERSION_XX_F/argouml/build/ext
# to a structure under
# ../../../svn/argouml-downloads/www/maven2
# according to the setup in the file LAYOUT.
# The created jnlp file will end up in
# ../../../svn/argouml-downloads/www/jws

# Must be run from this directory.
if test ! -r LAYOUT; then
    echo $0: "Missing config file. Started from the wrong place?"
    exit 1
fi

if test -n "$RELEASE"
then
    releasename=$RELEASE
else
    echo "Give the name of the release (like X.Y.Z)."
    read releasename
fi

SOURCEDIRS="$BUILDDIR $BUILDDIR/ext"
TARGETDIR="$DESTDIR/maven2"
JNLPTARGETDIR="$DESTDIR/jws"

CMDS=tmp-commands$$.sh
FILES=tmp-files$$.sh

GETLAYOUT="grep -v '^#' LAYOUT | grep -v '^$'"

# Check that all groupIDs directories are created.

eval $GETLAYOUT |
while read jar groupid version rest
do
    if test ! -d $TARGETDIR/`echo $groupid | tr . /`
    then
        echo Directory for $groupid missing.
	exit 1
    fi
done || exit 1

echo All GroupIDs OK.

for jardir in $SOURCEDIRS
do
    for foundjar in $jardir/*.jar
    do
        b=`basename $foundjar`
        jar=`eval $GETLAYOUT | grep "^$b" | awk '{print $1}'`
        groupid=`eval $GETLAYOUT | grep "^$b" | awk '{print $2}'`
        version=`eval $GETLAYOUT | grep "^$b" | awk '{print $3}'`

	if test ! -n "$jar"
        then
            echo Cannot find config for $foundjar
            exit 1
        fi

        rootname=`basename $jar .jar`
        groupiddir=`echo $groupid | tr . /`

        if test ! -n "$version"
        then
            # This will only work until version x.y.9. When x.y.10 comes
            # the lastversion will point to x.y.9 because of the sort order.
            lastversion=`ls $TARGETDIR/$groupiddir/$rootname 2> /dev/null | tail -1`
            lastjar="$TARGETDIR/$groupiddir/$rootname/$lastversion/$rootname-$lastversion.jar"
	    if test ! -f $lastjar
            then
		echo $rootname new - OK
		echo mkdir $TARGETDIR/$groupiddir/$rootname >> $CMDS
		echo mkdir $TARGETDIR/$groupiddir/$rootname/$releasename >> $CMDS
		echo cp $foundjar $TARGETDIR/$groupiddir/$rootname/$releasename/$rootname-$releasename.jar >> $CMDS
		echo $groupiddir/$rootname/$releasename/$rootname-$releasename.jar >> $FILES
            elif ./compare-jars.sh $lastjar $foundjar > /dev/null
	    then
		echo $rootname the same as $lastversion - OK
		echo $groupiddir/$rootname/$lastversion/$rootname-$lastversion.jar >> $FILES
	    else
		echo $rootname new version $releasename replacing $lastversion - OK
		echo mkdir $TARGETDIR/$groupiddir/$rootname/$releasename >> $CMDS
		echo cp $foundjar $TARGETDIR/$groupiddir/$rootname/$releasename/$rootname-$releasename.jar >> $CMDS
		echo $groupiddir/$rootname/$releasename/$rootname-$releasename.jar >> $FILES
	    fi
	else
            if test -d $TARGETDIR/$groupiddir/$rootname/$version
            then
                oldjar="$TARGETDIR/$groupiddir/$rootname/$version/$rootname-$version.jar"
		if ./compare-jars.sh $oldjar $foundjar > /dev/null
		then
		    echo $rootname the same version $version - OK
		    echo $groupiddir/$rootname/$version/$rootname-$version.jar >> $FILES
		else
		    echo $rootname differ - NOT OK - update LAYOUT
		    exit 1
		fi
	    else
		echo $rootname explicit new version $version - OK
		echo mkdir $TARGETDIR/$groupiddir/$rootname/$version >> $CMDS
		echo cp $foundjar $TARGETDIR/$groupiddir/$rootname/$version/$rootname-$version.jar >> $CMDS
		echo $groupiddir/$rootname/$version/$rootname-$version.jar >> $FILES
            fi
        fi

    done
done

#
echo Copy the files.
chmod +x $CMDS
sh -x $CMDS

# 
echo Create the java web start file.
JNLPFILE=$JNLPTARGETDIR/argouml-$releasename.jnlp

cat >> $JNLPFILE <<EOF
<?xml version="1.0" encoding="utf-8"?>
<!-- JNLP File for launching ArgoUML with WebStart -->
<jnlp
  spec="1.0+"
  codebase="http://argouml-downloads.tigris.org/maven2"
  href="http://argouml-downloads.tigris.org/jws/argouml-$releasename.jnlp">
  <information>
    <title>ArgoUML Release $releasename</title>
    <vendor>Tigris.org (Open Source)</vendor>
    <homepage href="http://argouml.tigris.org/"/>
    <description>ArgoUML Tigris Application
                 With your default language.
    </description>
    <description kind="short">The ArgoUML version $releasename</description>
    <icon href="http://argouml.tigris.org/images/argologo.gif"/>
    <offline-allowed/>
  </information>
  <security>
    <all-permissions/>
  </security>
  <resources>
    <j2se version="1.4+" max-heap-size="256m"/>

EOF

cat $FILES |
sed 's;^;    <jar href="http://argouml-downloads.tigris.org/maven2/;' |
sed 's;$;"/>;' |
sed 's;org/argouml/argouml/.*";& main="true";' >> $JNLPFILE

cat >> $JNLPFILE <<EOF

  </resources>
  <application-desc main-class="org.argouml.application.Main"/>
</jnlp>
EOF

echo Done.
rm $CMDS $FILES

echo Now you should add and commit the new files in
echo $TARGET and
echo $JNLPTARGETDIR
