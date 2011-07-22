# E-Center Project Content Management System

Developed and maintained by David Eads (davideads@gmail.com) for Fermi National
Accelerator Laboratory and the U.S. Department of Energy.

This is the root directory of the custom Drupal 6.x modules, themes, and other
supporting files (patches, makefile, other assets) for the E-Center content
management component and user interface.

## Installing the frontend

### Building E-Center

You will need [Drush][drush] and [Drush Make][drush_make], and Curl to build the
E-Center Drupal frontend.

To install, run the `build.sh` script found in this directory with a single
argument specifying which directory you would like to install E-Center.

    # build.sh /path/to/install/target

The build script works by:

 * Calling `drush make`
 * Symlinking the install profile, modules, and themes from E-Center in their
correct locations under the Drupal directory tree.
 * Downloading and unpacking the MaxMind GeoIP Lite database (Drush make does
not support un-tarred, gzipped archives).
 * Creating a custom build of the OpenLayers Javascript mapping library.

### Installing E-Center

Place the E-Center codebase that you installed under your host's webroot and
visit the new site. On the initial installation screen, select the E-Center 
profile.

Drupal installation details are specific to your environment. See the
[Drupal installation guide][drupal_install] for in-depth instructions.

On the final installation screen, remember to configure the Data
Retrieval Service and optional Anomaly Detection Service settings. The network
weathermap and other DRS-based functionality requires proper configuration
to work. These settings can be added or changed after installing at 
`admin/settings/ecenter`.

### Known installation issues

 * The profiler module (which is used to help smooth out installation) may run
for a fairly long time. If you run into these problems, you may wish to increase
the `max_execution_time` variable in your php.ini files.
 * Input format defaults provided by the Better Formats module are not configured.
For security reasons, you should review them at `admin/settings/filters/defaults`
immediately after installation.
 * There is a bug in menu item exports which prevents a section's home page from 
appearing in the secondary navigation (for example, if you visit `/network`, the 
network weathermap link is missing from the secondary navigation menu). These
links, if desired, must be added manually.
 * You may wish to disable some menu links in the administration menu.

## Repository layout

 * modules
   * ecenter: E-Center-specific Drupal modules and [features][features]
   * util: Utility / general purpose modules and features
 * patches: Custom patches
 * profile: Install profile
 * theme: Drupal theme

## License

All components of E-Center are distributed under the [Fermi Tools
license][fermitools], a BSD variant. Parts of the codebase are based on other 
code or bundle third-party libraries.

Refer to the LICENSE files in each subdirectory for detailed licensing
information.

 [drush]: http://drupal.org/project/drush
 [drush_make]: http://drupal.org/project/drush_make
 [features]: http://drupal.org/project/features
 [fermitools]: http://fermitools.fnal.gov/about/terms.html
 [drupal_install]: http://drupal.org/documentation/install
