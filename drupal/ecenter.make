; E-Center Project makefile
;
; E-Center uses a monolithic git repository to store its codebase.  This
; makefile is currently designed to build a Drupal install profile in the
; current directory to be later integrated with the provided build.sh script.
;
core = 6.x
api = 2

; Drupal core
projects[drupal][type] = "core"
projects[drupal][version] = "6.22"

; Patch Drupal to use jQuery 1.4 (see http://drupal.org/node/479368)
projects[drupal][patch][] = "http://drupal.org/files/issues/do479468-drupal_to_js-expanded-comments-nostatic.patch"

; Modules
projects[adminrole][subdir] = "contrib"
projects[adminrole][version] = "1.3"

projects[advanced_help][subdir] = "contrib"
projects[advanced_help][version] = "1.2"

projects[ahah_helper][subdir] = "contrib"
projects[ahah_helper][version] = "2.1"
projects[ahah_helper][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/raw/drupal/patches/ahah_helper_form_id.patch"
projects[ahah_helper][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/raw/drupal/patches/ahah_helper_js_settings.patch"
projects[ahah_helper][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/raw/drupal/patches/ahah_helper_optional_validation_handlers.patch"

projects[autoload][subdir] = "contrib"
projects[autoload][version] = "2.0"

projects[beautytips][subdir] = "contrib"
projects[beautytips][version] = "2.0"

projects[better_formats][subdir] = "contrib"
projects[better_formats][version] = "1.2"

projects[buildmodes][subdir] = "contrib"
projects[buildmodes][version] = "1.0-beta1"

projects[cck][subdir] = "contrib"
projects[cck][version] = "2.9"

projects[conditional_styles][subdir] = "contrib"
projects[conditional_styles][version] = "1.2"

projects[context][subdir] = "contrib"
projects[context][version] = "3.0"
projects[context][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/raw/drupal/patches/context_jquery_ui_1.8.patch"

projects[ctools][subdir] = "contrib"
projects[ctools][version] = "1.8"

projects[curl][subdir] = "contrib"
projects[curl][version] = "2.0-rc1"

projects[date][subdir] = "contrib/date"
projects[date][version] = "2.7"

projects[devel][subdir] = "contrib"
projects[devel][version] = "1.26"

projects[diff][subdir] = "contrib"
projects[diff][version] = "2.3"

projects[exportables][subdir] = "contrib"
projects[exportables][version] = "2.x-dev"

projects[fbconnect][subdir] = "contrib"
projects[fbconnect][version] = "2.0-beta1"

projects[features][subdir] = "contrib"
projects[features][version] = "1.1"

projects[filefield][subdir] = "contrib"
projects[filefield][version] = "3.10"

projects[flag][subdir] = "contrib"
projects[flag][version] = "1.3"

projects[fontyourface][subdir] = "contrib"
projects[fontyourface][version] = "2.8"

projects[geoip][subdir] = "contrib"
projects[geoip][version] = "1.4"

projects[gravatar][subdir] = "contrib"
projects[gravatar][version] = "1.10"

projects[imageapi][subdir] = "contrib"
projects[imageapi][version] = "1.10"

projects[imagecache][subdir] = "contrib"
projects[imagecache][version] = "2.0-beta12"

projects[imagefield][subdir] = "contrib"
projects[imagefield][version] = "3.10"

projects[input_formats][subdir] = "contrib"
projects[input_formats][version] = "1.0-beta6"

projects[insert][subdir] = "contrib"
projects[insert][version] = "1.1"

projects[jquery_ui][subdir] = "contrib"
projects[jquery_ui][version] = "1.5"
projects[jquery_ui][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/raw/drupal/patches/jquery_ui_multiple_versions.patch"

projects[jquery_update][subdir] = "contrib"
projects[jquery_update][version] = "1.1"
projects[jquery_update][patch][] = "https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/raw/drupal/patches/jquery_update_jquery-1.4.4.patch"

projects[less][subdir] = "contrib"
projects[less][version] = "2.7"

projects[libraries][subdir] = "contrib"
projects[libraries][version] = "1.0"

projects[linkit][subdir] = "contrib"
projects[linkit][version] = "1.10"

projects[logintoboggan][subdir] = "contrib"
projects[logintoboggan][version] = "1.10"

projects[mapbox][subdir] = "contrib"
projects[mapbox][version] = "1.0-alpha3"

projects[markdown][subdir] = "contrib"
projects[markdown][version] = "1.2"

projects[markdownify][type] = "module"
projects[markdownify][subdir] = "contrib"
projects[markdownify][download][type] = "git"
projects[markdownify][download][url] = "git://github.com/ecenter/markdownify"
projects[markdownify][download][branch] = "6.x-1.0-dev"

projects[menu_block][subdir] = "contrib"
projects[menu_block][version] = "2.4"

projects[oembed][subdir] = "contrib"
projects[oembed][version] = "0.8"

projects[og][subdir] = "contrib"
projects[og][version] = "2.1"

projects[openid_selector][subdir] = "contrib"
projects[openid_selector][version] = "1.x-dev"

projects[openlayers][subdir] = "contrib"
projects[openlayers][version] = "2.0-beta1"

projects[pathauto][subdir] = "contrib"
projects[pathauto][version] = "1.6"

projects[pathologic][subdir] = "contrib"
projects[pathologic][version] = "3.4"

projects[semanticviews][subdir] = "contrib"
projects[semanticviews][version] = "1.1"

projects[shib_auth][subdir] = "contrib"
projects[shib_auth][version] = "4.0"

projects[simplemenu][subdir] = "contrib"
projects[simplemenu][version] = "1.14"

projects[statistics_granularity][subdir] = "contrib"
projects[statistics_granularity][version] = "1.0"

projects[strongarm][subdir] = "contrib"
projects[strongarm][version] = "2.0"

projects[syntaxhighlighter][subdir] = "contrib"
projects[syntaxhighlighter][version] = "1.26"

projects[tableofcontents][subdir] = "contrib"
projects[tableofcontents][version] = "3.7"

projects[token][subdir] = "contrib"
projects[token][version] = "1.18"

projects[vertical_tabs][subdir] = "contrib"
projects[vertical_tabs][version] = "1.0-rc2"

projects[views][subdir] = "contrib"
projects[views][version] = "3.0-rc3"

projects[views_slideshow][subdir] = "contrib"
projects[views_slideshow][version] = "3.0"

projects[wysiwyg][subdir] = "contrib"
projects[wysiwyg][version] = "2.4"

projects[wysiwyg_filter][subdir] = "contrib"
projects[wysiwyg_filter][version] = "1.x-dev"

; Themes
projects[tao][type] = "theme"
projects[tao][version] = "3.2"

projects[seven][type] = "theme"
projects[seven][version] ="1.0-beta13"

; Libraries

; Drupal profiler module/library
libraries[profiler][download][type] = "get"
libraries[profiler][download][url] = "http://ftp.drupal.org/files/projects/profiler-6.x-2.x-dev.tar.gz"
libraries[profiler][directory_name] = "profiler"

; Our convoluted jQuery UI situation -- we need 1.8.x (for combobox) and 1.6.x
; (for Homebox) so we'll just throw in 1.7.x for good measure
libraries[jquery_ui_1_6][download][type] = "get"
libraries[jquery_ui_1_6][download][url] = "http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip"
libraries[jquery_ui_1_6][directory_name] = "jquery.ui-1.6"

libraries[jquery_ui_1_7][download][type] = "get"
libraries[jquery_ui_1_7][download][url] = "http://jquery-ui.googlecode.com/files/jquery-ui-1.7.3.zip"
libraries[jquery_ui_1_7][directory_name] = "jquery.ui-1.7"

libraries[jquery_ui_1_8][download][type] = "get"
libraries[jquery_ui_1_8][download][url] = "http://jquery-ui.googlecode.com/files/jquery-ui-1.8.7.zip"
libraries[jquery_ui_1_8][directory_name] = "jquery.ui-1.8"

; OpenLayers
libraries[openlayers][download][type] = "get"
libraries[openlayers][download][url] = "http://openlayers.org/download/OpenLayers-2.10.tar.gz"
libraries[openlayers][directory_name] = "openlayers"

; jqPlot
libraries[jqplot][download][type] = "get"
libraries[jqplot][download][url] = "http://bitbucket.org/cleonello/jqplot/downloads/jquery.jqplot.1.0.0b2_r947.tar.gz"
libraries[jqplot][directory_name] = "jqplot"

; TinyMCE
libraries[tinymce][download][type] = "get"
libraries[tinymce][download][url] = "http://github.com/downloads/tinymce/tinymce/tinymce_3.4.7.zip"
libraries[tinymce][directory_name] = "tinymce"

; SyntaxHighlighter, probably won't work because of download url
libraries[syntaxhighlighter][download][type] = "get"
libraries[syntaxhighlighter][download][url] = "http://alexgorbatchev.com/SyntaxHighlighter/download/syntaxhighlighter_3.0.83.zip"
libraries[syntaxhighlighter][directory_name] = "syntaxhighlighter"

; GeoIP
;libraries[geoip][download][type] = "get"
;libraries[geoip][download][url] = "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
;libraries[geoip][directory_name] = "geoip"

; OpenID Selector
libraries[openid_selector][download][type] = "get"
libraries[openid_selector][download][url] = "http://openid-selector.googlecode.com/files/openid-selector-1.3.zip"
libraries[openid_selector][directory_name] = "openid-selector"

; jQuery cycle
libraries[jquery.cycle][download][type] = "get"
libraries[jquery.cycle][download][url] = "https://raw.github.com/malsup/cycle/master/jquery.cycle.all.js"
libraries[jquery.cycle][directory_name] = "jquery.cycle"

; qTip library
libraries[qtip][download][type] = "get"
libraries[qtip][download][url] = "https://raw.github.com/Craga89/qTip2/master/dist/jquery.qtip.js"
libraries[qtip][directory_name] = "qtip"

; Masonry
libraries[masonry][download][type] = "get"
libraries[masonry][download][url] = "http://masonry.desandro.com/jquery.masonry.min.js"
libraries[masonry][directory_name] = "masonry"

; Raphael
libraries[raphael][download][type] = "git"
libraries[raphael][download][url] = "https://github.com/ecenter/raphael.git"
libraries[raphael][directory_name] = "raphael"
