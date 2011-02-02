; $Id: markdown_wysiwyg.make.inc,v 1.2.2.1 2011/01/11 17:14:35 nedjo Exp $

; Drupal version
core = 6.x
api = 2

; Contrib modules
projects[advanced_help][subdir] = contrib
projects[advanced_help][version] = 1.2
projects[ctools][subdir] = contrib
projects[ctools][version] = 1.8
projects[better_formats][subdir] = contrib
projects[better_formats][version] = 1.2
projects[debut][subdir] = contrib
projects[markdown_wysiwyg][subdir] = contrib
projects[features][subdir] = contrib
projects[features][version] = 1.0
projects[helpinjector][subdir] = contrib
projects[libraries][subdir] = contrib
projects[libraries][version] = 1.0-alpha1
projects[strongarm][subdir] = contrib
projects[strongarm][version] = 2.0
projects[wysiwyg][subdir] = contrib
projects[wysiwyg][version] = 2.2
projects[wysiwyg_filter][subdir] = contrib
projects[wysiwyg_filter][version] = 1.5

; TinyMCE
libraries[tinymce][download][type] = "get"
libraries[tinymce][download][url] = "http://downloads.sourceforge.net/project/tinymce/TinyMCE/3.2.7/tinymce_3_2_7.zip"
libraries[tinymce][directory_name] = "tinymce"

