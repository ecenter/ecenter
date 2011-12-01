#!/bin/bash
#
# Build E-Center Drupal distribution
#
# Usage: Run build.sh {options} build_directory

function help {
  echo "Build the E-Center Drupal distribution. Usage: `basename $0` {options} target_directory"
  echo ""
  echo "Options (options may not be combined):"
  echo "  --help: Display this message"
  echo "  --tar: Create tarball"
  echo "  --working-copy: Create development environment with install profile symlinked to development directories and repository versions of libraries where possible."
  exit 1
}

if [ $# = 0 ]; then
  help $script
fi

old_dir=`pwd`
script_dir=$(dirname `readlink -f $0`)
tar=false
dev=false

for var in "$@"; do
  if [ $var = "--help" ]; then
    help $0
  fi
  if [ $var = "--tar" ]; then
    tar=true
  fi
  if [ $var = "--working-copy" ]; then
    dev=true
  fi
done 

dir=$var

if [ $dir != "--working-copy" ] && [ $dir != "--tar" ]; then
  if $tar; then
    dir_name=$dir
    dir=/tmp/$dir
  fi

  if [ -d "$dir" ]; then
    echo -e "\nThe target directory ($dir) already exists. Would you like to overwrite it"
    echo -e "and create a new E-center instance? (Y/n): \c"
    read OVERWRITE
    if [ $OVERWRITE = "Y" ] || [ $OVERWRITE = "y" ]; then
      rm -Rf $dir
    else
      echo "Couldn't build E-Center in the specified directory, exiting."
      exit
    fi
  else
    echo -e "\nAbout to create a new E-Center distribution build. Would you like to continue? (Y/n): \c"
    read CONFIRM
    if [ $CONFIRM != "Y" ] && [ $CONFIRM != "y" ]; then
      exit
    fi
  fi
else
  echo -e "\nWarning: no target directory provided, distribution not built!\n"
  help $0
fi

if $dev && $tar; then 
  echo -e "Cannot create tarball and development environment at same time. Building development environment.\n"
  tar=false
fi

if $tar; then
  echo -e "Building E-Center distribution as $dir_name.tar.gz.\n"
else
  echo -e "Building E-Center distribution in $dir.\n"
fi

if $dev; then
  drush -y make --prepare-install --working-copy --contrib-destination=profiles/ecenter ecenter.make $dir
  ln -s $script_dir/profile/* $dir/profiles/ecenter/
  ln -s $script_dir/modules/ecenter $dir/profiles/ecenter/modules/
  ln -s $script_dir/modules/util $dir/profiles/ecenter/modules/
  ln -s $script_dir/themes/ecenter $dir/profiles/ecenter/themes/
else
  drush -y make --prepare-install --contrib-destination=profiles/ecenter ecenter.make $dir
  cp -R $script_dir/profile/* $dir/profiles/ecenter/
  cp -R $script_dir/modules/ecenter $dir/profiles/ecenter/modules/
  cp -R $script_dir/modules/util $dir/profiles/ecenter/modules/
  cp -R $script_dir/themes/ecenter $dir/profiles/ecenter/themes/
fi

# See http://drupal.org/node/1050262 - Drush make can't handle untarred,
# gzipped files
mkdir -p $dir/profiles/ecenter/libraries/geoip
curl http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -o $dir/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz
gunzip $dir/profiles/ecenter/libraries/geoip/GeoLiteCity.dat.gz

# Build OpenLayers configuration
cd $dir/profiles/ecenter/libraries/openlayers/build
./build.py $script_dir/misc/ecenter_openlayers.cfg
cd $old_dir

if $tar; then
  cd /tmp
  tar czf $dir_name.tar.gz $dir_name
  cp $dir_name.tar.gz $old_dir
  rm $dir_name.tar.gz
  rm -Rf $dir_name
  cd $old_dir
fi
