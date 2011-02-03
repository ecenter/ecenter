Markdown WYSIWYG 
================

Markdown WYSIWYG is a Kit-compliant Drupal feature based on ajax_markup module
and the debut_wysiwyg feature which provides a TinyMCE-based WYSIWYG editor 
that uses Markdown as its source format.  This allows "the best of both worlds"
for editing community content such as wiki pages or collaborative 
documentation. 
 
In practice, I've found that two content editing styles work in the real world:
Markdown is a great tool for enforcing good structure and is very comfortable 
for people with geeky mentalities. So-called average users" (bloggers, 
journalists, video people, "content creators") seem to appreciate a clean,
simple  WYSIWYG tool for content editing (Wordpress nails this).

Because of the limitations of the technology and Drupal 6's rigid filter
system, you're forced to pick HTML or Markdown and stick to it on a per-node
basis. This ain't ideal for supporting both types of users. 

Architecture notes
------------------

This is a small but fairly complicated module -- it bundles together an editor
feature that uses strongarm, better_formats, and some manual installation code
to set up the proper formats and WYSIWYG profiles. It contains several big hacks 
to work around limitations in Drupal filter system and WYSIWYG API.  

A word of warning: markdown_wysiwyg encapsulates everything needed to create a 
working  WYSIWYG editor with Markdown source -- it's a hack, but a clean one. 
It comes at the expense of requiring a rigid input format.  If you change the 
filters for the provided input format, you are likely to break the module.

Drupal filters are "one way" -- they convert a source format to HTML. There's
no provision for specifying a way to convert HTML back to source. A future 
iteration of this feature might try to detect and handle HTML-to-source
conversion for common filters, but the current version contains hardcoded 
rules that correspond to the provided input format. My goal is to enhance
functionality (i.e. get media embedding and linking working smoothly) before
making it general purpose.
