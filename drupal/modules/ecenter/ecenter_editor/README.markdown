# Editor: TinyMCE Markdown

Developed and maintained by David Eads (davideads@gmail.com) for Fermi National
Accelerator Laboratory and the U.S. Department of Energy as part of the 
[E-Center Project][1].

This Drupal feature installs and configures everything you need to use the 
TinyMCE WYSIWYG editor with Markdown source code, and includes additional 
niceties to spruce up the TinyMCE editor UI in Drupal: Linkit module configuration,
a sane default configuration for WYSIWYG, and filters to handle embedded media
(via a URL on its own line) and syntax highlighting.

## Requirements

* exportables module versions AFTER 6.x-2.0-beta1, currently only dev
* A patch to wYSIWYG filter: http://drupal.org/files/issues/wysiwyg_filter-form-alter.patch
(see http://drupal.org/node/887532)
* There is a features patch (http://drupal.org/node/981248) that doesn't work, but
would be the preferable solution.

## Install

1. Enable the feature. 
1. You **MUST** visit admin/settings/filters/{X}/configure where
{X} is the format ID of the format installed by this module, called 'WYSIWYG
Markdown' and save the configuration. Sorry!

## Configure

You'll likely want to configure wysiwyg_filter's configuration settings for the
"Markdown WYSIWYG" input format (admin/settings/filter), as well as the the
WYSIWYG profile associated with the input format (admin/settings/wysiwyg).
You may also wish to install Better Formats module and/or additional Linkit
module plugins and Oembed providers.

## Features

### Embedded media

Enable your desired oembed providers and provide a URL on its own line 
in your source code.

### Syntax highlighting

To add source code, use markup of this form to allow code to be editable in both
markdown mode and TinyMCE (less reliable):

    <pre>
    {syntaxhighlighter class="brush: php"}
    My code:
      Indented line
    {/syntaxhighlighter}
    </pre>

## Implementation notes

The Drupal editor and input format situation is very complicated. This module 
tries to work around this situation by locking down various format configuration 
screens. 

This module consists of what amount to a series of hacks to allow the editor to
be installed and configured correctly. Once installed, the module works by 
providing a tiny TinyMCE plugin that makes AJAX calls to the Markdownify module 
to convert from HTML to Markdown when the editor is disabled by the user or 
unloaded prior to saving content.

 [1]: https://cdcvs.fnal.gov/redmine/projects/ecenter/
