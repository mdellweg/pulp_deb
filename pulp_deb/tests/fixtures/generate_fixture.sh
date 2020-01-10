#!/bin/sh

set -eux

SRCDIR=$(readlink -f $(dirname $0))
TMPDIR=$(mktemp -d)

trap "rm -rf $TMPDIR" exit

cd $TMPDIR

mkdir asgard
cd asgard

for CTL in ${SRCDIR}/asgard/*.ctl
do
  equivs-build --arch ppc64 ${CTL}
done
cd ..

mkdir asgard_udebs
cd asgard_udebs

for CTL in ${SRCDIR}/asgard_udebs/*.ctl
do
  equivs-build --arch ppc64 ${CTL}
done
for DEB in *.deb
do
  mv "$DEB" "${DEB%deb}udeb"
done
cd ..

mkdir jotunheimr
cd jotunheimr

for CTL in ${SRCDIR}/jotunheimr/*.ctl
do
  equivs-build --arch armeb ${CTL}
done
cd ..

cp -a ${SRCDIR}/conf .
cp -a ${SRCDIR}/incoming .
#reprepro include ragnarok incoming/*.changes
reprepro processincoming ragnarok
reprepro -C asgard includeudeb ragnarok asgard_udebs/*.udeb
reprepro -C asgard includedeb ragnarok asgard/*.deb
reprepro -C jotunheimr includedeb ragnarok jotunheimr/*.deb

# Make it more exciting
rm dists/ragnarok/jotunheimr/binary-armeb/Packages

tar cvzf ${SRCDIR}/fixtures.tar.gz dists pool
