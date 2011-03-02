<?php

/**
 * Implementation of hook_input_formats().
 */
function editor_tinymce_markdown_input_formats() {
  $input_formats = array();

  $input_format = new stdClass;
  $input_format->api_version = 1;
  $input_format->name = 'WYSIWYG Markdown';
  $input_format->roles = array(
    2 => 'authenticated user',
  );
  $input_format->cache = TRUE;
  $input_format->settings = array(
    // Settings for: oembed module
    'oembed' => array(
      // Maximum width of embed
      'oembed_maxwidth' => '',
      // Maximum height of embed
      'oembed_maxheight' => '',
    ),
    // Settings for: pathologic module
    'pathologic' => array(
      // Also considered local
      'filter_pathologic_local_paths' => '',
      // Output full absolute URLs
      'filter_pathologic_absolute' => 1,
    ),
    // Settings for: wysiwyg_filter module
    'wysiwyg_filter' => array(
      // HTML elements and attributes
      'wysiwyg_filter_valid_elements_raw' => '@[class],
a[href],
div,p,pre,table,thead,tbody,tr,th,td,h2,h3,h4,h5,h6,
img[src|title|alt|width|height],
br,span,em,strong,cite,code,blockquote,ul,ol,li,dl,dt,dd',
      // HTML comments
      'wysiwyg_filter_allow_comments' => '0',
      // Color and background properties
      'wysiwyg_filter_styles_color' => array(
          'color' => 0,
          'background' => 0,
          'background-color' => 0,
          'background-image' => 0,
          'background-repeat' => 0,
          'background-attachment' => 0,
          'background-position' => 0,
        ),
      // Font properties
      'wysiwyg_filter_styles_font' => array(
          'font' => 0,
          'font-family' => 0,
          'font-size' => 0,
          'font-size-adjust' => 0,
          'font-stretch' => 0,
          'font-style' => 0,
          'font-variant' => 0,
          'font-weight' => 0,
        ),
      // Text properties
      'wysiwyg_filter_styles_text' => array(
          'text-align' => 0,
          'text-decoration' => 0,
          'text-indent' => 0,
          'text-transform' => 0,
          'letter-spacing' => 0,
          'word-spacing' => 0,
          'white-space' => 0,
          'direction' => 0,
          'unicode-bidi' => 0,
        ),
      // Box properties
      'wysiwyg_filter_styles_box' => array(
          'margin' => 0,
          'margin-top' => 0,
          'margin-right' => 0,
          'margin-bottom' => 0,
          'margin-left' => 0,
          'padding' => 0,
          'padding-top' => 0,
          'padding-right' => 0,
          'padding-bottom' => 0,
          'padding-left' => 0,
        ),
      // Border properties (1)
      'wysiwyg_filter_styles_border-1' => array(
          'border' => 0,
          'border-top' => 0,
          'border-right' => 0,
          'border-bottom' => 0,
          'border-left' => 0,
          'border-width' => 0,
          'border-top-width' => 0,
          'border-right-width' => 0,
          'border-bottom-width' => 0,
          'border-left-width' => 0,
        ),
      // Border properties (2)
      'wysiwyg_filter_styles_border-2' => array(
          'border-color' => 0,
          'border-top-color' => 0,
          'border-right-color' => 0,
          'border-bottom-color' => 0,
          'border-left-color' => 0,
          'border-style' => 0,
          'border-top-style' => 0,
          'border-right-style' => 0,
          'border-bottom-style' => 0,
          'border-left-style' => 0,
        ),
      // Dimension properties
      'wysiwyg_filter_styles_dimension' => array(
          'height' => 0,
          'line-height' => 0,
          'max-height' => 0,
          'max-width' => 0,
          'min-height' => 0,
          'min-width' => 0,
          'width' => 0,
        ),
      // Positioning properties
      'wysiwyg_filter_styles_positioning' => array(
          'bottom' => 0,
          'clip' => 0,
          'left' => 0,
          'overflow' => 0,
          'right' => 0,
          'top' => 0,
          'vertical-align' => 0,
          'z-index' => 0,
        ),
      // Layout properties
      'wysiwyg_filter_styles_layout' => array(
          'clear' => 0,
          'display' => 0,
          'float' => 0,
          'position' => 0,
          'visibility' => 0,
        ),
      // List properties
      'wysiwyg_filter_styles_list' => array(
          'list-style' => 0,
          'list-style-image' => 0,
          'list-style-position' => 0,
          'list-style-type' => 0,
        ),
      // Table properties
      'wysiwyg_filter_styles_table' => array(
          'border-collapse' => 0,
          'border-spacing' => 0,
          'caption-side' => 0,
          'empty-cells' => 0,
          'table-layout' => 0,
        ),
      // User interface properties
      'wysiwyg_filter_styles_user' => array(
          'cursor' => 0,
          'outline' => 0,
          'outline-width' => 0,
          'outline-style' => 0,
          'outline-color' => 0,
          'zoom' => 0,
        ),
      // Rules for Class Names
      'wysiwyg_filter_valid_classes' => array(
          0 => 'content-*',
        ),
      // Rules for Element IDs
      'wysiwyg_filter_valid_ids' => array(),
      // Rules for URLs used within inline styles
      'wysiwyg_filter_style_urls' => array(),
      // Policy
      'wysiwyg_filter_nofollow_policy' => 'whitelist',
      // Domains list
      'wysiwyg_filter_nofollow_domains' => array(),
      // Valid elements parsed
      'wysiwyg_filter_valid_elements_parsed' => array(
          'a' => array(
            'href' => array(),
            'class' => array(),
          ),
          'blockquote' => array(
            'class' => array(),
          ),
          'br' => array(
            'class' => array(),
          ),
          'cite' => array(
            'class' => array(),
          ),
          'code' => array(
            'class' => array(),
          ),
          'dd' => array(
            'class' => array(),
          ),
          'div' => array(
            'class' => array(),
          ),
          'dl' => array(
            'class' => array(),
          ),
          'dt' => array(
            'class' => array(),
          ),
          'em' => array(
            'class' => array(),
          ),
          'img' => array(
            'src' => array(),
            'title' => array(),
            'alt' => array(),
            'width' => array(),
            'height' => array(),
            'class' => array(),
          ),
          'li' => array(
            'class' => array(),
          ),
          'ol' => array(
            'class' => array(),
          ),
          'p' => array(
            'class' => array(),
          ),
          'pre' => array(
            'class' => array(),
          ),
          'span' => array(
            'class' => array(),
          ),
          'strong' => array(
            'class' => array(),
          ),
          'table' => array(
            'class' => array(),
          ),
          'tbody' => array(
            'class' => array(),
          ),
          'td' => array(
            'class' => array(),
          ),
          'th' => array(
            'class' => array(),
          ),
          'thead' => array(
            'class' => array(),
          ),
          'tr' => array(
            'class' => array(),
          ),
          'ul' => array(
            'class' => array(),
          ),
        ),
    ),
  );
  $input_format->filters = array(
    'markdown' => array(
      // Delta => Weight for: Markdown
      '0' => '10',
    ),
    'oembed' => array(
      // Delta => Weight for: oEmbed filter
      '0' => '10',
    ),
    'pathologic' => array(
      // Delta => Weight for: Pathologic
      '0' => '10',
    ),
    'syntaxhighlighter' => array(
      // Delta => Weight for: Syntax highlighter
      '0' => '10',
    ),
    'wysiwyg_filter' => array(
      // Delta => Weight for: WYSIWYG Filter
      '0' => '10',
    ),
  );
  $input_format->machine = 'wysiwyg_markdown';
  $input_formats['wysiwyg_markdown'] = $input_format;

  return $input_formats;

}
