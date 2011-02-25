# Editor: TinyMCE Markdown

Developed and maintained by David Eads (davideads@gmail.com) for Fermi National
Accelerator Laboratory and the U.S. Department of Energy as part of the 
[E-Center Project][1].

This Drupal feature installs and configures everything you need to use the 
TinyMCE WYSIWYG editor with Markdown source code, and includes additional 
niceties to spruce up the TinyMCE editor UI in Drupal.

## Installation

### Warning!

There is an upstream bug in the input_formats module when exporting wysiwyg_filter.
Be advised that until this bug is resolved, installing this module could break your
site in one or two fairly horrible ways.

### Required patches

* Features: http://drupal.org/files/issues/features-981248.patch

### Install

Enabled the feature.

### Configure

You'll likely want to configure wysiwyg_filter's configuration settings for the
"Markdown WYSIWYG" input format (admin/settings/filter), as well as the the
WYSIWYG profile associated with the input format (admin/settings/wysiwyg).

## Implementation notes

The Drupal editor and input format situation is very complicated. This module tries
to work around this situation by locking down various 

 [1]: https://cdcvs.fnal.gov/redmine/projects/ecenter/
