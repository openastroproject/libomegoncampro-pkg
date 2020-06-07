#!/bin/bash

cp ../patches/*.patch .
rm -f makefile.patch

rm -f libomegonprocam-*.tar.gz
ln ../libomegonprocam-*.tar.gz .
rel=`cut -d' ' -f3 < /etc/redhat-release`
fedpkg --release f$rel local
