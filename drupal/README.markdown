# E-Center Project Content Management System

Developed and maintained by David Eads (davideads@gmail.com) for Fermi National
Accelerator Laboratory and the U.S. Department of Energy.

This is the root directory of the custom Drupal modules, themes, and other 
supporting files (patches, makefile, other assets) for the E-Center content
management component and user interface.

## Installing the frontend 

You will need [Drush][drush] and [Drush Make][drush_make] to build the E-Center
frontend. 

Run `build.sh`, found in the `drupal` directory -- the build script will invoke
`drush make` and build a Drupal installation in the `build` directory in your 
current working directory.

After building, set up Drupal (details vary based on host and configuration) 
and select the 'E-Center' profile in the Drupal installer.

## Layout

 * modules
   * ecenter: E-Center-specific Drupal modules and [features][features]
   * util: Utility / general purpose modules and features
 * patches: Custom patches
 * profile: Install profile
 * theme: Drupal theme

## License

All components of E-Center are distributed under the [Fermi Tools
license][fermitools], a BSD variant. A few parts of the codebase are 
based on other code or bundle third-party libraries.

Refer to the LICENSE files in each subdirectory for detailed licensing 
information. 

 [drush]: http://drupal.org/project/drush
 [drush_make]: http://drupal.org/project/drush_make
 [features]: http://drupal.org/project/features
 [fermitools]: http://fermitools.fnal.gov/about/terms.html
