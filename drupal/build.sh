#!/bin/bash
# Build E-Center
#
# This is a somewhat dangerous (because it deletes the build directory
# automatically), very simple build script for the E-Center project.
#
# Usage: Run build.sh

ARGS=1

old_dir=`pwd`
dir=$1
script_dir=$(dirname `readlink -f $0`)

if [ $# -ne $ARGS ]  # Correct number of arguments passed to script?
then
  echo "Usage: `basename $0` target_directory"
  exit 1
fi

if [ -d "$dir" ] # Check if directory exists
then
  echo -e "\nThe target directory ($1) already exists. Would you like to overwrite it"
  echo -e "and create a new E-center instance? (Y/n): \c"
  read OVERWRITE
  if [ $OVERWRITE = "Y" ] || [ $OVERWRITE = "y" ]; then
    rm -Rf $dir
  else
    echo "Couldn't build E-Center in the specified directory, exiting."
    exit
  fi
else
  echo -e "\nAbout to create a new E-Center instance in $dir. Would you like to continue? (Y/n): \c"
  read CONFIRM
  if [ $CONFIRM != "Y" ] && [ $CONFIRM != "y" ]; then
    exit
  fi
fi

echo -e "Creating Drupal instance in $dir.\n\n"
drush -y make --contrib-destination=profiles/ecenter ecenter.make $dir

ln -s $script_dir/profile/* $dir/profiles/ecenter/
ln -s $script_dir/modules/ecenter $dir/profiles/ecenter/modules/
ln -s $script_dir/modules/util $dir/profiles/ecenter/modules/
ln -s $script_dir/themes/ecenter $dir/profiles/ecenter/themes/
mkdir $dir/sites/default/files

# See http://drupal.org/node/1050262 - Drush make can't handle untarred,
# gzipped files
mkdir -p $dir/profiles/ecenter/libraries/geoip
curl http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -o $dir/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz
gunzip $dir/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz

# Build OpenLayers configuration
cd $dir/profiles/ecenter/libraries/openlayers/build
./build.py $script_dir/misc/ecenter_openlayers.cfg
cd $old_dir
