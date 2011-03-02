<?php

/**
 * Implementation of hook_strongarm().
 */
function editor_tinymce_markdown_strongarm() {
  $format = _editor_tinymce_markdown_format(); 
  
  $export = array();
  return $export;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_allow_comments_'. $format;
  $strongarm->value = '0';

  $export['wysiwyg_filter_allow_comments_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_nofollow_domains_'. $format;
  $strongarm->value = array();

  $export['wysiwyg_filter_nofollow_domains_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_nofollow_policy_'. $format;
  $strongarm->value = 'whitelist';

  $export['wysiwyg_filter_nofollow_policy_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_style_urls_'. $format;
  $strongarm->value = array();

  $export['wysiwyg_filter_style_urls_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-1_'. $format;
  $strongarm->value = array(
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
  );

  $export['wysiwyg_filter_styles_border-1_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-2_'. $format;
  $strongarm->value = array(
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
  );

  $export['wysiwyg_filter_styles_border-2_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_box_'. $format;
  $strongarm->value = array(
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
  );

  $export['wysiwyg_filter_styles_box_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_color_'. $format;
  $strongarm->value = array(
    'color' => 0,
    'background' => 0,
    'background-color' => 0,
    'background-image' => 0,
    'background-repeat' => 0,
    'background-attachment' => 0,
    'background-position' => 0,
  );

  $export['wysiwyg_filter_styles_color_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_dimension_'. $format;
  $strongarm->value = array(
    'height' => 0,
    'line-height' => 0,
    'max-height' => 0,
    'max-width' => 0,
    'min-height' => 0,
    'min-width' => 0,
    'width' => 0,
  );

  $export['wysiwyg_filter_styles_dimension_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_font_'. $format;
  $strongarm->value = array(
    'font' => 0,
    'font-family' => 0,
    'font-size' => 0,
    'font-size-adjust' => 0,
    'font-stretch' => 0,
    'font-style' => 0,
    'font-variant' => 0,
    'font-weight' => 0,
  );

  $export['wysiwyg_filter_styles_font_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_layout_'. $format;
  $strongarm->value = array(
    'clear' => 0,
    'display' => 0,
    'float' => 0,
    'position' => 0,
    'visibility' => 0,
  );

  $export['wysiwyg_filter_styles_layout_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_list_'. $format;
  $strongarm->value = array(
    'list-style' => 0,
    'list-style-image' => 0,
    'list-style-position' => 0,
    'list-style-type' => 0,
  );

  $export['wysiwyg_filter_styles_list_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_positioning_'. $format;
  $strongarm->value = array(
    'bottom' => 0,
    'clip' => 0,
    'left' => 0,
    'overflow' => 0,
    'right' => 0,
    'top' => 0,
    'vertical-align' => 0,
    'z-index' => 0,
  );

  $export['wysiwyg_filter_styles_positioning_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_table_'. $format;
  $strongarm->value = array(
    'border-collapse' => 0,
    'border-spacing' => 0,
    'caption-side' => 0,
    'empty-cells' => 0,
    'table-layout' => 0,
  );

  $export['wysiwyg_filter_styles_table_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_text_'. $format;
  $strongarm->value = array(
    'text-align' => 0,
    'text-decoration' => 0,
    'text-indent' => 0,
    'text-transform' => 0,
    'letter-spacing' => 0,
    'word-spacing' => 0,
    'white-space' => 0,
    'direction' => 0,
    'unicode-bidi' => 0,
  );

  $export['wysiwyg_filter_styles_text_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_user_'. $format;
  $strongarm->value = array(
    'cursor' => 0,
    'outline' => 0,
    'outline-width' => 0,
    'outline-style' => 0,
    'outline-color' => 0,
    'zoom' => 0,
  );

  $export['wysiwyg_filter_styles_user_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_classes_'. $format;
  $strongarm->value = array(
    0 => 'content-*',
  );

  $export['wysiwyg_filter_valid_classes_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_parsed_'. $format;
  $strongarm->value = array(
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
  );

  $export['wysiwyg_filter_valid_elements_parsed_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_raw_'. $format;
  $strongarm->value = '@[class],
a[href],
div,p,pre,table,thead,tbody,tr,th,td,
img[src|title|alt|width|height],
br,span,em,strong,cite,code,blockquote,ul,ol,li,dl,dt,dd';

  $export['wysiwyg_filter_valid_elements_raw_'. $format] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_ids_'. $format;
  $strongarm->value = array();

  $export['wysiwyg_filter_valid_ids_'. $format] = $strongarm;
  return $export;
}
