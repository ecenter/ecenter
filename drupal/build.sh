#!/bin/bash
# Build E-Center to a specified directory
#
# Usage: build.sh /path/to/install
#if [ -d $1 ]; then
  d=`dirname $0`
  echo $d
  rm -Rf $d/build
  drush -y make --working-copy $d/drupal.make $d/build/ 
  drush -y make --working-copy --no-core --contrib-destination=$d/build/profiles/ecenter $d/ecenter.make
  cp $d/*.txt $d/build/profiles/ecenter/
  cp $d/profile/* $d/build/profiles/ecenter/
  cp -R $d/modules/* $d/build/profiles/ecenter/modules/
  cp -R $d/themes/* $d/build/profiles/ecenter/themes/
#else
#  echo "Target is not a directory. Specify a directory to build E-Center."
#fi
