# Editor: TinyMCE Markdown

*Developed and maintained by David Eads (davideads@gmail.com) for Fermi National
Accelerator Laboratory and the U.S. Department of Energy as part of the 
[E-Center Project][1].*

This Drupal 6 feature provides a TinyMCE-based WYSIWYG editor with Markdown 
source code. When editing content, select the WYSIWYG Markdown input format. 
Disable the WYSIWYG editor to edit with Markdown syntax.

Includes additional configuration and styling to spruce up the TinyMCE editor
UI in Drupal.

## Requirements

* [Exportables][2] module versions **after** 6.x-2.0-beta1; currently only the `-dev` 
version will work.
* [A patch to WYSIWYG filter][3] (see http://drupal.org/node/887532).
* [A patch to features][4] (see http://drupal.org/node/981248) that should allow
the WYSIWYG profile to be installed, but requires a manual revert.

## Install

You may include or copy the makefile snippet bundled with this module to build
using the correct versions. 

Also, buckle your seatbelt. Installation of this module is a little non-sensical.

1. Enable the feature.
2. Click the feature's "overridden" link from the main features list 
(`/admin/build/features`) and revert the `wysiwyg_markdown` strongarm variable.
3. Visit `admin/settings/filters/N/configure` where `N` is the format ID of the
format installed by this module, called 'WYSIWYG Markdown' and save the 
configuration. 

Step 2) is required to install the WYSIWYG Profile and Step 3) is required to
install the proper WYSIWYG Filter settings, neither of which are properly
enabled when the feature is turned on.

## Configure

You'll likely want to configure wysiwyg_filter's configuration settings for the
"Markdown WYSIWYG" input format (`admin/settings/filter)`, as well as the the
WYSIWYG profile associated with the input format (`admin/settings/wysiwyg`).

Configuration checklist:

* **Configure WYSIWYG profile** (`admin/settings/wysiwyg/profile/N/edit`): You will 
almost certainly want to specify a location for the editor's CSS. Required 
options are locked.
* **Configure WYSIWYG Markdown input format** (`admin/settings/filters/N/configure`):  
You should tweak the spam deterrent settings, as well as whitelisted class names
and allowed tags and styles.
* **Configure oembed providers** (`admin/build/oembed/provider`): Enable your
desired oembed providers.
* (Optional) **Enable additional Linkit modules**
* (Optional) **Install and configure [Better Formats][5] module**

## Features

### LinkIt

This module uses the [LinkIt][6] TinyMCE plugin, which provides a smart UI for
linking to internal and external content.

### Default content classes

WYSIWYG Filter requires allowed class names in content source code to be 
whitelisted (i.e. `allowed-class-*`). TinyMCE Markdown editor whitelists 
`content-*` and provides these classes in TinyMCE by default:

* `.content-align-center`
* `.content-align-right`
* `.content-float-left`
* `.content-float-right`
* `.content-introduction`
* `.content-highlight`
* `.content-large`
* `.content-small`
* `.content-loud`
* `.content-quiet`

### Embedded media

Enable your desired oembed providers and provide a URL on its own line 
in your source code.

### Syntax highlighting

To add source code, use markup of this form to allow code to be editable in both
markdown mode and TinyMCE (beware: editing is less reliable in TinyMCE):

    <pre>
    {syntaxhighlighter class="brush: php"}
    My code:
      Indented line
    {/syntaxhighlighter}
    </pre>

## Implementation notes

The Drupal editor and input format situation is very complicated. This module 
tries to work around this situation by locking down various format configuration 
options and hacking around other limitations.

The core functionality of the module works by providing a TinyMCE plugin that makes 
AJAX calls to the Markdownify module to convert from HTML to Markdown when the editor
is disabled by the user or unloaded prior to saving content.

## Screenshots

![TinyMCE](http://img.skitch.com/20110304-n51u6xsc86ibg17a7qa93swga7.png)

![Markdown](http://img.skitch.com/20110304-nbdr2atxbqtq287xjmcst4hmgw.png)

![Rendered](http://img.skitch.com/20110304-gb3icxjm747k8287cg38ya87dp.png)

 [1]: https://cdcvs.fnal.gov/redmine/projects/ecenter/
 [2]: http://drupal.org/project/exportables
 [3]: http://drupal.org/files/issues/wysiwyg_filter-form-alter.patch
 [4]: http://drupal.org/files/issues/features-981248.patch
 [5]: http://drupal.org/project/better_formats
 [6]: http://drupal.org/project/linkit
