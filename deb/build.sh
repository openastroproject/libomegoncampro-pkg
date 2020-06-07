#!/bin/bash

export DEBEMAIL=james@openastroproject.org
export DEBFULLNAME="James Fidell"

version=`cat version`

srcdir=libomegonprocam-$version
debdir=debian
debsrc=$debdir/source
quiltconf=$HOME/.quiltrc-dpkg

debversion=`cat /etc/debian_version`
case $debversion in
  jessie/sid)
    compatversion=9
    ;;
  stretch/sid)
    compatversion=9
    ;;
  *)
    compatversion=10
    ;;
esac
echo $compatversion > debfiles/compat

cp ../patches/*.patch debfiles/patches

tar zxf ../libomegonprocam-$version.tar.gz
cd $srcdir
test -d demo && ( chmod -x demo/*.* Makefile )
YFLAG=-y
dh_make -v | fgrep -q '1998-2011'
if [ $? -eq 0 ]
then
  YFLAG=''
fi
dh_make $YFLAG -l -f ../../libomegonprocam-$version.tar.gz

sed -e "s/@@COMPAT@@/$compatversion/" < ../debfiles/control > $debdir/control
cp ../debfiles/copyright $debdir
cp ../debfiles/changelog $debdir
cp ../debfiles/compat $debdir
cp ../debfiles/docs $debdir
cp ../debfiles/watch $debdir
cp ../debfiles/libomegonprocam.dirs $debdir
cp ../debfiles/libomegonprocam.install $debdir
cp ../debfiles/libomegonprocam.symbols $debdir
cp ../debfiles/libomegonprocam.triggers $debdir
cp ../debfiles/libomegonprocam.doc-base $debdir
cp ../debfiles/libomegonprocam-dev.dirs $debdir
cp ../debfiles/libomegonprocam-dev.install $debdir

sed -e '/^.*[ |]configure./a\
	udevadm control --reload-rules || true' < $debdir/postinst.ex > $debdir/postinst
chmod +x $debdir/postinst
sed -e '/^.*[ |]remove./a\
	udevadm control --reload-rules || true' < $debdir/postrm.ex > $debdir/postrm
chmod +x $debdir/postrm
echo "3.0 (quilt)" > $debsrc/format

sed -e "s/DEBVERSION/$version/g" < ../debfiles/rules.overrides >> $debdir/rules

rm $debdir/README.Debian
rm $debdir/README.source
rm $debdir/libomegonprocam-docs.docs
rm $debdir/libomegonprocam1.*
rm $debdir/*.[Ee][Xx]


export QUILT_PATCHES="debian/patches"
export QUILT_PATCH_OPTS="--reject-format=unified"
export QUILT_DIFF_ARGS="-p ab --no-timestamps --no-index --color=auto"
export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"
mkdir -p $QUILT_PATCHES

for p in `ls -1 ../debfiles/patches`
do
  quilt --quiltrc=$quiltconf new $p
  for f in `egrep '^\+\+\+' ../debfiles/patches/$p | awk '{ print $2; }'`
  do
    quilt --quiltrc=$quiltconf add $f
  done
pwd
  patch -p0 < ../debfiles/patches/$p
  quilt --quiltrc=$quiltconf refresh
done

dpkg-buildpackage -us -uc

echo "Now run:"
echo
echo "    lintian -i -I --show-overrides libomegonprocam_$version-0_amd64.changes"
