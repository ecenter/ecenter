#!/bin/bash
# Build E-Center
#
# This is a somewhat dangerous (because it deletes the build directory
# automatically), very simple build script for the E-Center project.
#
# Usage: Run build.sh

d=`dirname $0`
cwd=`pwd`
rm -Rf $d/build
drush -y make --working-copy $d/drupal.make $d/build/

drush -y make --working-copy --no-core --contrib-destination=$d/build/profiles/ecenter $d/ecenter.make
cp $d/*.markdown $d/build/profiles/ecenter/
cp $d/profile/* $d/build/profiles/ecenter/
ln -s $cwd/modules/ecenter $cwd/build/profiles/ecenter/modules/ecenter
ln -s $cwd/modules/util $cwd/build/profiles/ecenter/modules/util
ln -s $cwd/themes/ecenter $cwd/build/profiles/ecenter/themes/ecenter

# See http://drupal.org/node/1050262 - Drush make can't handle untarred,
# gzipped files
mkdir -p $cwd/build/profiles/ecenter/libraries/geoip
curl http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -o $cwd/build/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz
gunzip $cwd/build/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz

