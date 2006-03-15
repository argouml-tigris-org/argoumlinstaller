#!/bin/sh

# Create the Appbund for MacOS

echo "Give the name of the release (like X.Y.Z)."
read releasename

# Must be run from this directory.
if test ! -d infra; then
    echo $0: "Missing data directory. Started from the wrong place?"
    exit 1
fi

mkdir -p ../build

mkdir ArgoUML.app
mkdir ArgoUML.app/Contents
mkdir ArgoUML.app/Contents/Resources
mkdir ArgoUML.app/Contents/Resources/Java
mkdir ArgoUML.app/Contents/MacOS

# Copy the specific things
(
  cd infra
  cp PkgInfo ../ArgoUML.app/Contents
  cp GenericJavaApp.icns ../ArgoUML.app/Contents/Resources
  cp JavaApplicationStub ../ArgoUML.app/Contents/MacOS
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

cp ../../argouml/build/*.jar ArgoUML.app/Contents/Resources/Java
tar cvf - ArgoUML.app |
gzip > ../build/ArgoUML-$releasename.app.tgz

rm -r ArgoUML.app
