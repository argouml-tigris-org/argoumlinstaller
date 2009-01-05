#!/bin/sh

# Generate copies of all psf files tagged to a specific release.

# arguments are the release names as VERSION_0_27_3

for version
do
    justversion=`echo $version | sed 's/^VERSION_//'`
    svn ls http://argouml.tigris.org/svn/argouml/releases/$version/www/psf |
    grep '\.psf$' |
    while read psffile
    do
        rm -f gen-copy-stderr.out
        svn cat http://argouml.tigris.org/svn/argouml/releases/$version/www/psf/$psffile |
        sed 's;.*<project ref.*\(http://.*\.tigris\.org/svn/.*/trunk[^,]*\),.*/>$;\1;p;d' |
        sed "s;/trunk;/releases/$version;" |
        xargs svn info 2>gen-copy-stderr.out >/dev/null
        if test -s gen-copy-stderr.out
        then
            rm -f gen-copy-stderr.out
            echo The file $psffile does not have all entries in the release.
            continue
        fi
        rm -f gen-copy-stderr.out
        echo Processing file $psffile...
	test -d ../argouml/www/psf/$justversion ||
            mkdir ../argouml/www/psf/$justversion
        svn cat http://argouml.tigris.org/svn/argouml/releases/$version/www/psf/$psffile |
        sed "s;/trunk;/releases/$version;" |
        cat > ../argouml/www/psf/$justversion/$psffile
        echo Processing file $psffile...done
    done
done
