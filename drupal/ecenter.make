; $Id$
;
; E-Center Project makefile
;
; E-Center uses a monolithic git repository to store its codebase.  This
; makefile is currently designed to build a Drupal install profile in the
; current directory to be later integrated with the provided build.sh script.
;
core = 6.x
api = 2

; Modules
projects[adminrole][subdir] = "contrib"
projects[adminrole][version] = "1.3"

projects[advanced_help][subdir] = "contrib"
projects[advanced_help][version] = "1.2"

projects[ahah_helper][subdir] = "contrib"
projects[ahah_helper][version] = "2.1"

; Allow ahah_helper to manipulate all Drupal javascript settings
; (may cause instability for untested modules)
projects[ahah_helper][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/buildsystem/raw/drupal/patches/ahah_helper_js_settings.patch"

projects[beautytips][subdir] = "contrib"
projects[beautytips][version] = "2.0"

projects[conditional_styles][subdir] = "contrib"
projects[conditional_styles][version] = "1.1"

projects[cck][subdir] = "contrib"
projects[cck][version] = "2.9"

projects[context][subdir] = "contrib"
projects[context][version] = "3.0"

projects[ctools][subdir] = "contrib"
projects[ctools][version] = "1.8"

projects[date][subdir] = "contrib/date"
projects[date][version] = "2.7"

projects[devel][subdir] = "contrib"
projects[devel][version] = "1.23"

projects[features][subdir] = "contrib"
projects[features][version] = "1.0"

projects[filefield][subdir] = "contrib"
projects[filefield][version] = "3.9"

projects[geoip][subdir] = "contrib"
projects[geoip][version] = "1.2"

projects[homebox][subdir] = "contrib"
projects[homebox][version] = "2.1"

projects[imageapi][subdir] = "contrib"
projects[imageapi][version] = "1.9"

projects[imagecache][subdir] = "contrib"
projects[imagecache][version] = "2.0-beta10"

projects[jquery_ui][subdir] = "contrib"
projects[jquery_ui][version] = "1.4"
; Handle multiple jQuery UI versions
projects[jquery_ui][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/buildsystem/raw/drupal/patches/jquery_ui_multiple_versions.patch"

projects[jquery_update][subdir] = "contrib"
projects[jquery_update][version] = "1.1"
; Patch for jQuery 1.4.4, required by jqPlot and jQuery UI 1.8.x
projects[jquery_update][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/buildsystem/raw/drupal/patches/jquery_update_jquery-1.4.4.patch"

projects[less][subdir] = "contrib"
projects[less][version] = "2.6"

projects[openlayers][subdir] = "contrib"
projects[openlayers][version] = "2.0-alpha10"

projects[pathauto][subdir] = "contrib"
projects[pathauto][version] = "1.5"

projects[simplemenu][subdir] = "contrib"
projects[simplemenu][version] = "1.13"

projects[strongarm][subdir] = "contrib"
projects[strongarm][version] = "2.0"

projects[token][subdir] = "contrib"
projects[token][version] = "1.15"

projects[vertical_tabs][subdir] = "contrib"
projects[vertical_tabs][version] = "1.0-rc1"

projects[views][subdir] = "contrib"
projects[views][version] = "3.x-dev"
projects[views][patch][] = "http://drupal.org/files/issues/844910-views.dont-add-field-in-orderby_0.patch"
projects[views][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/buildsystem/raw/drupal/patches/views_groupwise_max.patch"

projects[wysiwyg][subdir] = "contrib"
projects[wysiwyg][version] = "2.2"

; Themes
projects[tao][version] = "3.2"

; Libraries

; Our convoluted jQuery UI situation -- we need 1.8.x (for combobox) and 1.6.x
; (for Homebox) so we'll just throw in 1.7.x for good measure
libraries[jquery_ui_1_6][download][type] = "get"
libraries[jquery_ui_1_6][download][url] = "http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip"
libraries[jquery_ui_1_6][directory_name] = "jquery.ui-1.6"
libraries[jquery_ui_1_6][destination] = "modules/contrib/jquery_ui"

libraries[jquery_ui_1_7][download][type] = "get"
libraries[jquery_ui_1_7][download][url] = "http://jquery-ui.googlecode.com/files/jquery-ui-1.7.3.zip"
libraries[jquery_ui_1_7][directory_name] = "jquery.ui-1.7"
libraries[jquery_ui_1_7][destination] = "modules/contrib/jquery_ui"

libraries[jquery_ui_1_8][download][type] = "get"
libraries[jquery_ui_1_8][download][url] = "http://jquery-ui.googlecode.com/files/jquery-ui-1.8.7.zip"
libraries[jquery_ui_1_8][directory_name] = "jquery.ui-1.8"
libraries[jquery_ui_1_8][destination] = "modules/contrib/jquery_ui"

libraries[openlayers][download][type] = "get"
libraries[openlayers][download][url] = "http://openlayers.org/download/OpenLayers-2.10.tar.gz"
libraries[openlayers][directory_name] = "openlayers"

; jqPlot
libraries[jqplot][download][type] = "get"
libraries[jqplot][download][url] = "http://bitbucket.org/cleonello/jqplot/downloads/jquery.jqplot.0.9.7r635.zip"
libraries[jqplot][directory_name] = "jqplot"
libraries[jqplot][destination] = "modules/contrib/jqplot"

; Markdownify
; @TODO Add Markdownify library once module work is further along

; TinyMCE
libraries[tinymce][download][type] = "get"
libraries[tinymce][download][url] = "http://github.com/downloads/tinymce/tinymce/tinymce_3_3_9_3.zip"
libraries[tinymce][directory_name] = "tinymce"

; GeoIP
libraries[geoip][download][type] = "get"
libraries[geoip][download][url] = "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
libraries[geoip][directory_name] = "geoip"
