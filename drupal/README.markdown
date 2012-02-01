# E-Center Project Content Management System

Developed and maintained by David Eads (davideads@gmail.com) for Fermi National
Accelerator Laboratory and the U.S. Department of Energy.

This is the root directory of the custom Drupal 6.x modules, themes, and other
supporting files (patches, makefile, other assets) for the E-Center content
management component and user interface.

## Requirements

PHP 5.2+, Curl

## Build E-Center

You will need [Drush][drush] and [Drush Make][drush_make], and Curl to build the
E-Center Drupal frontend. Clone from the Git repository:

<pre>git clone https://github.com/ecenter/ecenter.git</pre>

Run the build script:

<pre>cd ecenter/drupal
./build.sh /var/www/ecenter</pre>

This command will create an E-Center instance in the `/var/www/ecenter` directory. You may pass the `--tar` flag to create a gzipped tarball of the built distribution or the `--working-copy` flag to build E-Center for local development.

## Install E-Center

Point your browser at the default Drupal install URL `http://ecenter.myhost.tld/install.php`.

## Known installation issues

 * The profiler module (which is used to help smooth out installation) may run
for a fairly long time. If you run into these problems, you may wish to increase
the `max_execution_time` variable in your php.ini files.

## Repository layout

Self-explanatory directories (such as `js` for Javascript assets) are omitted from this list:

* misc: Random files, currently an OpenLayers build configuration file and a frozen version of the qTip library for convenience.
* modules
  * ecenter: E-Center-specific Drupal modules and [features][features]
    * ecenter_backbone: Experimental module to include a Backbone JS application within Drupal (i.e. with access to Drupal's session cookie, protected by Drupal's permission system).
    * ecenter_core: Provides basic permissions, roles (pre-authenticated, trusted, administrator), tag vocabulary, and page + snippet content types.
    * ecenter_dashboard: Provides code and Views for the E-Center homepage.
    * ecenter_editor: Provides Markdown Restricted and Markdown Advanced input formats, WYSIWYG editor configuration.
    * ecenter_groups: Default settings and Views for Organic Groups integration.
    * ecenter_help: Provides default E-Center documentation, and BeautyTip module settings.
    * ecenter_issues: Provides issue and network query content types, custom logic for issue creation.
    * ecenter_mail: Provides reply-by-email functionality for comment threads, notification settings.
    * ecenter_network: The core E-Center module that provides the data visualization user interface and data access code. 
      * includes: Drupal-agnostic Data Retrieval Service data access classes (e.g. data_retrieval_service.class.inc) and Drupal-specific wrappers and parsers (e.g. data_retrieval_service.inc).
    * ecenter_test: A collection of simple-minded tests of various E-Center functionality. These are not formal tests and are provided mainly for debugging purposes.
    * ecenter_user: Provides configuration defaults for authentication (OpenID, Shibboleth).
    * ecenter_wiki: Defines wiki content type, basic wiki functionality.
  * util: Utility / general purpose modules and features
    * combobox: Provides select-box with full-text search functionality 
    * jqplot: Provides simple jqPlot integration and jQuery plugin to automatically generate charts from HTML tables.
* patches: Custom patches
* profile: Install profile
* theme
  * ecenter: Custom E-center theme. Depends on the Drupal LESS CSS preprocessor module.

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
