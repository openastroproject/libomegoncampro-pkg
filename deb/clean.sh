#!/bin/bash

version=`cat version`

rm -fr libomegonprocam-$version
rm -fr libomegonprocam_*
rm -fr libomegonprocam-dev_*
rm -f debfiles/compat
rm -f debfiles/patches/*
