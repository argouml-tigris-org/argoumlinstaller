#!/bin/sh

# Create the Appbund for MacOS

if test -n "$RELEASE"
then
    releasename=$RELEASE
else
    echo "Give the name of the release (like X.Y.Z)."
    read releasename
fi

# Must be run from this directory.
if test ! -d infra; then
    echo $0: "Missing data directory. Started from the wrong place?"
    exit 1
fi

if test -n "$BUILDDIR"
then
    builddirectory=$BUILDDIR
else
    VERSIONNAME=VERSION_`echo $releasename | sed 's/\./_/g'`
    builddirectory=`pwd`/../build/$VERSIONNAME/argouml/build
    echo "\$BUILDDIR not defined, using $builddirectory."
fi

if test ! -d $builddirectory; then
    echo build directory "$builddirectory" does not exist.
    exit 1
fi

mkdir -p ../build

mkdir ArgoUML.app
mkdir ArgoUML.app/Contents
mkdir ArgoUML.app/Contents/Resources

# Copy the specific things
(
  cd infra
  cp PkgInfo ../ArgoUML.app/Contents
  cp ArgoIcon.icns ../ArgoUML.app/Contents/Resources
  cp ArgoDocument.icns ../ArgoUML.app/Contents/Resources
)
# Format the Info.plist file
( cd $builddirectory && ls *.jar ) > ArgoUML.app/temp.list
cat < infra/Info.plist |
  sed 's/@VERSION_NUMBER@/'$releasename'/' |
  awk '$0 == "@FILE_LIST@" {
          while ((getline line < "ArgoUML.app/temp.list" > 0))
              printf "<string>$JAVAROOT/%s</string>\n", line
          next
       }
       { print }' |
  cat > ArgoUML.app/Contents/Info.plist
rm ArgoUML.app/temp.list

tar cvf ArgoUML.app.tar ArgoUML.app

mkdir ArgoUML.app/Contents/MacOS
(
  cd infra
  cp JavaApplicationStub ../ArgoUML.app/Contents/MacOS
)
tar uvf ArgoUML.app.tar --mode 755 ArgoUML.app/Contents/MacOS

mkdir ArgoUML.app/Contents/Resources/Java
cp $builddirectory/*.jar ArgoUML.app/Contents/Resources/Java
mkdir ArgoUML.app/Contents/Resources/Java/ext
cp $builddirectory/ext/*.jar ArgoUML.app/Contents/Resources/Java/ext
cp $builddirectory/ext/domainmapping.xml ArgoUML.app/Contents/Resources/Java/ext
tar uvf ArgoUML.app.tar ArgoUML.app/Contents/Resources/Java

gzip < ArgoUML.app.tar > ../build/ArgoUML-$releasename.app.tar.gz

rm -rf ArgoUML.app
rm ArgoUML.app.tar
