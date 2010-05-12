Chicago Technology Cooperative Theme Utilities
-------------------------------------------------------------------------------

This is a collection of utilities and hacks that extend Drupal's theming system
in pleasing directions.  These utilities try to extend Drupal without 
drastically altering the conceptual model provided by Drupal.
 
The primary functions of these utilities are:
 
  - Provide a hack to the theming system to provide autoregistration of tpl
    files that override any theme function without futher modification.
    This helps cut down on boiler-plate code.

  - Auto-detect and override CSS files without registration in a theme's
    .info file.  This is a simple convenience, but it is fast and makes
    CSS feel consistent with tpl replacement.
   
  - Provide blocks for common theme configuration options.  This grants end-
    users more flexibility in customizing their theme, because their logo,
    slogan, etc, are now mobile and configurable via the common blocks UI.

It is critical that this module execute late in the invocation process. The 
module installs with a default weight of '9999' which should be sufficient 
in most instances.


Usage
-------------------------------------------------------------------------------

Blocks:

Once the module is enabled, you will have new blocks available on the block 
configuration page (admin/build/blocks).  The new blocks are:

  - Site name: The site's name
  - Site slogan:  Site slogan 
  - Site logo:  @TODO This should be an upload field
  - Site footer:  A site footer
  - Site mission:  The site mission
  - Primary links:  The primary site links
  - Secondary links:  Standalone secondary site links. These are the children
    of the primary links but not nested with them.
  - Tertiary links:  Standalone tertiary links.  Same as secondary links, but
    for the third link level.
  - Tertiary links expanded:  Expanded tertiary site links.  These links 
    include the tertiary level of links, as well as the active path below the 
    tertiary item in the active path.

CSS:

If you place a file with the same name as a Drupal-provided CSS file (i.e.
admin-menus.css) in your theme's CSS directory, it will completely replace the
Drupal-provided CSS file.  If the current theme is a subtheme, if the CSS file
is not found in the current theme's directory, the parent themes will be 
searched.  If none if found, the standard Drupal provided file will come through.

I was concerned about the performance of this system, but by constraining the
search to a subdirectory of the current theme and parent themes and the fact
that the number of CSS files that get added to any given request is necessarily
pretty small, I think it should pose no problems.  On my system, autodiscovery
was taking about ~2ms for a theme / subtheme configuration with a lot of fake
drupal_add_css calls for kicks.

CSS aggregation should work fine with this system.

JS:

@TODO:  Should we give Javascript the same treatment as the CSS?  I think yes,
but we might as well refine the approach with the CSS, abstract out the common
bits, and make a generic js/css/whatever inclusion mechanism.

Theme functions:

On a Drupal theme registry cache rebuild, this module includes a hack that
looks for tpl files which match the function name of *any* Drupal theme
callback and forces the tpl to be called.  This means that you can easily 
route theme_xxx style theming functions that return a string to be rendered
by way of a template file, and don't need to declare stubbed 
mytheme_preprocess_xxx functions when all you want to do is override a template
file. 

The discovery mechanism works similarly to the CSS discovery mechanism, in that
it searches parent themes if a match is not found in 

Unlike the CSS discovery mechanism, this is potentially quite slow.  The array
of callbacks can be quite large and the registration must behave like Drupal,
and therefore scan your entire theme directory for the templates.  However, 
since most sites don't rebuild their theme registry per-request in production,
the performance issues should be a moot point in almost all common 
circumstances.
