; $Id$
; 
; E-Center Project makefile
;
; E-Center uses a monolithic git repository to store it
core = 6.x

api = 2
projects[drupal][version] = "6.20"
; 
projects[drupal][patch][] = "http://drupal.org/files/issues/do479368-drupal_json_encode_0.patch"

; Modules
projects[ahah_helper][version] = "2.1"
; ahah_helper 
projects[ahah_helper][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/changes/drupal/patches/ahah_helper.patch"

projects[conditional_styles][version] = "1.1"

projects[ctools][version] = "1.8"

projects[date][subdir] = "date"
projects[date][version] = "2.6"

projects[devel][version] = "1.23"

projects[features][version] = "1.0"

projects[geoip][version] = "1.2"

projects[jquery_ui][version] = "1.4"
; Patch for jQuery UI 1.8

projects[jquery_update][version] = "1.1"
projects[jquery_update][patch][] = "http://drupal.org/files/issues/jquery_update_775924.patch"

projects[openlayers][version] = "2.0-alpha10"

projects[simplemenu][version] = "1.13"

projects[strongarm][version] = "2.0"

projects[vertical_tabs][version] = "1.0-rc1"

projects[views][version] = "2.12"

projects[wysiwyg][version] = "2.2"

; Themes
projects[tao][version] = "3.2"

; Libraries
libraries[jquery_ui][download][type] = "get"
libraries[jquery_ui][download][url] = "http://jquery-ui.googlecode.com/files/jquery-ui-1.7.3.zip" ; @TODO use jquery ui 1.8
libraries[jquery_ui][directory_name] = "jquery.ui"
libraries[jquery_ui][destination] = "modules/jquery_ui"

libraries[openlayers][download][type] = "get"
libraries[openlayers][download][url] = "http://nodeload.github.com/developmentseed/openlayers_slim/tarball/v1.8"
libraries[openlayers][directory_name] = "openlayers"

; Markdownify
; TinyMCE
; GeoIP
