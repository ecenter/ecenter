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

Use Drush Make to build the base Drupal installation:

$ drush make /path/to/ecenter.make /path/to/target

Currently, to install the Drupal component of E-Center, you must copy or symlink
the modules and theme folders to /path/to/target/sites/default or 
/path/to/target/sites/mysite
