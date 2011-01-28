E-Center Project Content Management System
------------------------------------------

Developed and maintained by David Eads (davideads@gmail.com) for Fermi National
Accelerator Laboratory and the US Department of Energy.

This is the root directory of the custom Drupal modules, themes, and other
supporting files (patches, makefile, other assets) for E-Center.

A full build system and install profile are planned for year 2 and is under
active development.


License
-------

Most components of E-Center are distributed under the Fermi Tools license
(http://fermitools.fnal.gov/about/terms.html), a BSD variant. Refer to the
LICENSE files in each sub-directory for detailed licensing information.

A few parts of the codebase are based on other code. These pieces are
distributed according to the terms of their parent license.


Install
-------

Download from our git repository:

$ git clone http://cdcvs.fnal.gov/projects/ecenter

Use Drush Make to build the base Drupal installation by running build.sh.

This will build a full Drupal installation in a directory called 'build' in
your current working directory. The build script is very primitive and will
delete anything in your current build directory. However, the build directory
will provide everything you need (patched Drupal, modules, custom code, and
an install profile) to install Drupal according to standard practices.

When visiting install.php to complete your Drupal installation, make sure you
select the E-Center installation profile.
