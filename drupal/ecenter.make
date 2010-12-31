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
projects[ahah_helper][subdir] = "contrib"
projects[ahah_helper][version] = "2.1"
; ahah_helper 
projects[ahah_helper][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/changes/drupal/patches/ahah_helper.patch"

projects[conditional_styles][subdir] = "contrib"
projects[conditional_styles][version] = "1.1"

projects[ctools][subdir] = "contrib"
projects[ctools][version] = "1.8"

projects[date][subdir] = "contrib/date"
projects[date][version] = "2.6"

projects[devel][subdir] = "contrib"
projects[devel][version] = "1.23"

projects[features][subdir] = "contrib"
projects[features][version] = "1.0"

projects[geoip][subdir] = "contrib"
projects[geoip][version] = "1.2"

projects[jquery_ui][subdir] = "contrib"
projects[jquery_ui][version] = "1.4"

projects[jquery_update][subdir] = "contrib"
projects[jquery_update][version] = "1.1"
; Patch for jQuery 1.4
projects[jquery_update][patch][] = "http://drupal.org/files/issues/jquery_update_775924.patch"

projects[openlayers][subdir] = "contrib"
projects[openlayers][version] = "2.0-alpha10"

projects[simplemenu][subdir] = "contrib"
projects[simplemenu][version] = "1.13"

projects[strongarm][subdir] = "contrib"
projects[strongarm][version] = "2.0"

projects[vertical_tabs][subdir] = "contrib"
projects[vertical_tabs][version] = "1.0-rc1"

projects[views][subdir] = "contrib"
projects[views][version] = "2.12"

projects[wysiwyg][subdir] = "contrib"
projects[wysiwyg][version] = "2.2"

; Themes
projects[tao][version] = "3.2"

; Libraries
libraries[jquery_ui][download][type] = "get"
libraries[jquery_ui][download][url] = "http://jquery-ui.googlecode.com/files/jquery-ui-1.7.3.zip" ; @TODO use jquery ui 1.8
libraries[jquery_ui][directory_name] = "jquery.ui"
libraries[jquery_ui][destination] = "modules/contrib/jquery_ui"

libraries[openlayers][download][type] = "get"
libraries[openlayers][download][url] = "http://nodeload.github.com/developmentseed/openlayers_slim/tarball/v1.8"
libraries[openlayers][directory_name] = "openlayers"

; Markdownify
; TinyMCE
; GeoIP
