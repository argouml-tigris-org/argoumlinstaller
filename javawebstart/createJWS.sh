#!/bin/sh
# $Id$

# This file will copy the jar files that are modified from
# $BUILDDIR
# to a structure under
# $DESTDIR/maven2
# according to the setup in the file LAYOUT.
# The created jnlp file will end up in
# $DESTDIR/jws

LAYOUT="`dirname $0`/LAYOUT"
if test ! -r "$LAYOUT"; then
    echo $0: "Missing config file $LAYOUT."
    exit 1
fi
COMPAREJARS="`dirname $0`/compare-jars.sh"

if test -n "$RELEASE"
then
    releasename=$RELEASE
else
    echo "Give the name of the release (like X.Y.Z)."
    read releasename
fi

notonlytest=true
while getopts t found "$@"
do
    case $found in
    t)
        notonlytest=false
        ;;
    esac
done


SOURCEDIRS="$BUILDDIR $BUILDDIR/ext"
TARGETDIR="$DESTDIR/maven2"
JNLPTARGETDIR="$DESTDIR/jws"

CMDS=/tmp/commands$$.sh
FILES=/tmp/files$$.sh

GETLAYOUT="grep -v '^#' $LAYOUT | grep -v '^$'"

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

function add_to_file() {
    groupid=$1
    name=$2
    version=$3
    echo $groupid/$name/$version/$name-$version.jar >> $FILES
}

function add_to_commands() {
    groupid=$1
    name=$2
    version=$3
    echo mkdir $TARGETDIR/$groupid/$name/$version >> $CMDS
    jar=$groupid/$name/$version/$name-$version.jar
    echo cp $foundjar $TARGETDIR/$jar >> $CMDS

    # Create the pom.xml file
    echo "cat > $TARGETDIR/$groupid/$name/$version/$name-$version.pom <<EOF" >> $CMDS
    echo "<project>" >> $CMDS
    echo "<groupId>$groupid</groupId>" >> $CMDS
    echo "<artifactId>$name</artifactId>" >> $CMDS
    echo "<version>$version</version>" >> $CMDS
    echo "<modelVersion>4.0.0</modelVersion>" >> $CMDS
    echo "</project>" >> $CMDS
    echo "EOF" >> $CMDS
}


for jardir in $SOURCEDIRS
do
    for foundjar in $jardir/*.jar
    do
        b=`basename $foundjar`
        jar=`eval $GETLAYOUT | grep "^$b" | awk '{print $1}'`

	if test ! -n "$jar"
        then
            b=`echo $b | sed 's/-[0-9][-._0-9BETA3M]*[.]jar$/.jar/'`
            jar=`eval $GETLAYOUT | grep "^$b" | awk '{print $1}'`
        fi

	if test ! -n "$jar"
        then
            b=`echo $b | sed 's/_[1-9][.][0-9][.][0-9][.]v20[0-9]*[.]jar$/.jar/'`
            jar=`eval $GETLAYOUT | grep "^$b" | awk '{print $1}'`
        fi

	if test ! -n "$jar"
        then
            echo Cannot find config for $foundjar
            exit 1
        fi

        groupid=`eval $GETLAYOUT | grep "^$b" | awk '{print $2}'`
        version=`eval $GETLAYOUT | grep "^$b" | awk '{print $3}'`

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
                add_to_commands $groupiddir $rootname $releasename
                add_to_file $groupiddir $rootname $releasename
            elif $COMPAREJARS $lastjar $foundjar
	    then
		echo $rootname the same as $lastversion - OK
                add_to_file $groupiddir $rootname $lastversion
	    else
		echo $rootname new version $releasename replacing $lastversion - OK
                add_to_commands $groupiddir $rootname $releasename
		add_to_file $groupiddir $rootname $releasename
	    fi
	else
            # Check that $foundjar and $rootname-$version are similar enough
            if echo $rootname-$version | grep `basename $foundjar .jar` > /dev/null
            then
               : this is OK
            elif echo ${rootname}_$version | grep `basename $foundjar .jar` > /dev/null
            then
               : this is also OK
            else
               echo Neither $rootname-$version nor ${rootname}_$version matches `basename $foundjar` - NOT OK - update "$LAYOUT"
               exit 1
            fi

            if test -d $TARGETDIR/$groupiddir/$rootname/$version
            then
                oldjar="$TARGETDIR/$groupiddir/$rootname/$version/$rootname-$version.jar"
		if $COMPAREJARS $oldjar $foundjar
		then
		    echo $rootname the same version $version - OK
                    add_to_file $groupiddir $rootname $version
		else
		    echo $rootname differ - NOT OK - update "$LAYOUT"
		    exit 1
		fi
	    else
		echo $rootname explicit new version $version - OK
                add_to_commands $groupiddir $rootname $version
		add_to_file $groupiddir $rootname $version
            fi
        fi
    done
done


if $notonlytest
then
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
    <description kind="short">ArgoUML $releasename</description>
    <icon href="http://argouml.tigris.org/images/argologo16x16.gif" width="16" height="16" />
    <icon href="http://argouml.tigris.org/images/argologo32x32.gif" width="32" height="32" />
    <icon href="http://argouml.tigris.org/images/argologo64x64.gif" width="64" height="64" />
    <offline-allowed/>
  </information>
  <security>
    <all-permissions/>
  </security>
  <resources>
    <j2se version="1.5+" max-heap-size="512m"/>

EOF

    cat $FILES |
    sed 's;^;    <jar href="http://argouml-downloads.tigris.org/maven2/;' |
    sed 's;$;"/>;' |
    sed 's;org/argouml/argouml/.*";& main="true";' >> $JNLPFILE

    cat >> $JNLPFILE <<EOF

    <property name="argouml.modules"
EOF
    awk 'BEGIN { printf "      value=\""; first=true; }
         { if (!first) { printf ";"; }
           first=false;
           printf "%s", $0;
         }
         END { printf "\""; }' >> $JNLPFILE <<EOF
org.argouml.state2.StateDiagramModule
org.argouml.sequence2.SequenceDiagramModule
org.argouml.activity2.ActivityDiagramModule
org.argouml.core.propertypanels.module.XmlPropertyPanelsModule
org.argouml.transformer.TransformerModule
org.argouml.language.cpp.generator.ModuleCpp
org.argouml.language.cpp.notation.NotationModuleCpp
org.argouml.language.cpp.profile.ProfileModule
org.argouml.language.cpp.reveng.CppImport
org.argouml.language.cpp.ui.SettingsTabCpp
org.argouml.language.csharp.generator.GeneratorCSharp
org.argouml.language.java.cognitive.critics.InitJavaCritics
org.argouml.language.java.generator.GeneratorJava
org.argouml.language.java.profile.ProfileJava
org.argouml.language.java.reveng.JavaImport
org.argouml.language.java.reveng.classfile.ClassfileImport
org.argouml.language.java.ui.JavaTools
org.argouml.language.java.ui.SettingsTabJava
org.argouml.language.php.generator.ModulePHP4
org.argouml.language.php.generator.ModulePHP5
org.argouml.language.sql.SqlInit
org.argouml.uml.reveng.classfile.ClassfileImport
org.argouml.uml.reveng.idl.IDLFileImport
EOF
    cat >> $JNLPFILE <<EOF
    />
  </resources>
  <application-desc main-class="org.argouml.application.Main"/>
</jnlp>
EOF

    echo Done.

    echo Now you should add and commit the new files in
    echo $TARGET and
    echo $JNLPTARGETDIR

fi

rm $CMDS $FILES

exit 0
