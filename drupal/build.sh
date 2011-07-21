#!/bin/bash
# Build E-Center
#
# This is a somewhat dangerous (because it deletes the build directory
# automatically), very simple build script for the E-Center project.
#
# Usage: Run build.sh

ARGS=1
E_BADARGS=65
E_NOFILE=66

old_dir=`pwd`
script_dir=$(dirname `readlink -f $0`)

if [ $# -ne $ARGS ]  # Correct number of arguments passed to script?
then
  echo "Usage: `basename $0` target_directory"
  exit $E_BADARGS
fi

#if [ -d "$1" ] # Check if directory exists
#then
#  echo 'oh hai'
  #dir=$1
  #exit $E_NOFILE
#fi

dir=$1
echo "Creating Drupal instance in $dir"
drush -y make --working-copy --contrib-destination=profiles/ecenter ecenter.make $dir

ln -s $script_dir/profile/* $dir/profiles/ecenter/
ln -s $script_dir/modules/ecenter $dir/profiles/ecenter/modules/
ln -s $script_dir/modules/util $dir/profiles/ecenter/modules/
ln -s $script_dir/themes/ecenter $dir/profiles/ecenter/themes/

# See http://drupal.org/node/1050262 - Drush make can't handle untarred,
# gzipped files
mkdir -p $dir/profiles/ecenter/libraries/geoip
curl http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -o $dir/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz
gunzip $dir/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz

# Build OpenLayers configuration
cd $dir/profiles/ecenter/libraries/openlayers/build
./build.py $script_dir/misc/ecenter_openlayers.cfg
cd $old_dir
