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

mkdir -p ../build

mkdir ArgoUML.app
mkdir ArgoUML.app/Contents
mkdir ArgoUML.app/Contents/Resources

# Copy the specific things
(
  cd infra
  cp PkgInfo ../ArgoUML.app/Contents
  cp GenericJavaApp.icns ../ArgoUML.app/Contents/Resources
)
# Format the Info.plist file
( cd ../../argouml/build && ls *.jar ) > ArgoUML.app/temp.list
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
cp ../../argouml/build/*.jar ArgoUML.app/Contents/Resources/Java
tar uvf ArgoUML.app.tar ArgoUML.app/Contents/Resources/Java

gzip < ArgoUML.app.tar > ../build/ArgoUML-$releasename.app.tgz

rm -r ArgoUML.app
rm ArgoUML.app.tar
