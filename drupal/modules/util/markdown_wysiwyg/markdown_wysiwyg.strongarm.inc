<?php

/**
 * Implementation of hook_strongarm().
 *
 * Includes manual installation of 
 */
function markdown_wysiwyg_strongarm() {
  $export = array();

  // Ensure the formats have been installed.
  if (!$formats = _markdown_wysiwyg_formats()) {
    return $export;
  }

  _markdown_wysiwyg_install_manual($formats);

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-1_' . $formats['WYSIWYG public'];
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

  $export['wysiwyg_filter_styles_border-1_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-1_' . $formats['WYSIWYG contributor'];
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

  $export['wysiwyg_filter_styles_border-1_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-1_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'border' => 'border',
    'border-top' => 'border-top',
    'border-right' => 'border-right',
    'border-bottom' => 'border-bottom',
    'border-left' => 'border-left',
    'border-width' => 'border-width',
    'border-top-width' => 'border-top-width',
    'border-right-width' => 'border-right-width',
    'border-bottom-width' => 'border-bottom-width',
    'border-left-width' => 'border-left-width',
  );

  $export['wysiwyg_filter_styles_border-1_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-2_' . $formats['WYSIWYG public'];
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

  $export['wysiwyg_filter_styles_border-2_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-2_' . $formats['WYSIWYG contributor'];
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

  $export['wysiwyg_filter_styles_border-2_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_border-2_' . $formats['WYSIWYG editor'];
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

  $export['wysiwyg_filter_styles_border-2_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_box_' . $formats['WYSIWYG public'];
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

  $export['wysiwyg_filter_styles_box_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_box_' . $formats['WYSIWYG contributor'];
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

  $export['wysiwyg_filter_styles_box_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_box_' . $formats['WYSIWYG editor'];
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

  $export['wysiwyg_filter_styles_box_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_color_' . $formats['WYSIWYG public'];
  $strongarm->value = array(
    'color' => 0,
    'background' => 0,
    'background-color' => 0,
    'background-image' => 0,
    'background-repeat' => 0,
    'background-attachment' => 0,
    'background-position' => 0,
  );

  $export['wysiwyg_filter_styles_color_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_color_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'color' => 0,
    'background' => 0,
    'background-color' => 0,
    'background-image' => 0,
    'background-repeat' => 0,
    'background-attachment' => 0,
    'background-position' => 0,
  );

  $export['wysiwyg_filter_styles_color_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_color_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'color' => 0,
    'background' => 0,
    'background-color' => 0,
    'background-image' => 0,
    'background-repeat' => 0,
    'background-attachment' => 0,
    'background-position' => 0,
  );

  $export['wysiwyg_filter_styles_color_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_dimension_' . $formats['WYSIWYG public'];
  $strongarm->value = array(
    'height' => 0,
    'line-height' => 0,
    'max-height' => 0,
    'max-width' => 0,
    'min-height' => 0,
    'min-width' => 0,
    'width' => 0,
  );

  $export['wysiwyg_filter_styles_dimension_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_dimension_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'height' => 0,
    'line-height' => 0,
    'max-height' => 0,
    'max-width' => 0,
    'min-height' => 0,
    'min-width' => 0,
    'width' => 0,
  );

  $export['wysiwyg_filter_styles_dimension_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_dimension_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'height' => 0,
    'line-height' => 0,
    'max-height' => 0,
    'max-width' => 0,
    'min-height' => 0,
    'min-width' => 0,
    'width' => 0,
  );

  $export['wysiwyg_filter_styles_dimension_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_font_' . $formats['WYSIWYG public'];
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

  $export['wysiwyg_filter_styles_font_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_font_' . $formats['WYSIWYG contributor'];
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

  $export['wysiwyg_filter_styles_font_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_font_' . $formats['WYSIWYG editor'];
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

  $export['wysiwyg_filter_styles_font_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_layout_' . $formats['WYSIWYG public'];
  $strongarm->value = array(
    'clear' => 0,
    'display' => 0,
    'float' => 0,
    'position' => 0,
    'visibility' => 0,
  );

  $export['wysiwyg_filter_styles_layout_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_layout_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'clear' => 0,
    'display' => 0,
    'float' => 0,
    'position' => 0,
    'visibility' => 0,
  );

  $export['wysiwyg_filter_styles_layout_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_layout_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'clear' => 0,
    'display' => 0,
    'float' => 0,
    'position' => 0,
    'visibility' => 0,
  );

  $export['wysiwyg_filter_styles_layout_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_list_' . $formats['WYSIWYG public'];
  $strongarm->value = array(
    'list-style' => 0,
    'list-style-image' => 0,
    'list-style-position' => 0,
    'list-style-type' => 0,
  );

  $export['wysiwyg_filter_styles_list_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_list_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'list-style' => 0,
    'list-style-image' => 0,
    'list-style-position' => 0,
    'list-style-type' => 0,
  );

  $export['wysiwyg_filter_styles_list_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_list_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'list-style' => 0,
    'list-style-image' => 0,
    'list-style-position' => 0,
    'list-style-type' => 0,
  );

  $export['wysiwyg_filter_styles_list_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_positioning_' . $formats['WYSIWYG public'];
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

  $export['wysiwyg_filter_styles_positioning_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_positioning_' . $formats['WYSIWYG contributor'];
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

  $export['wysiwyg_filter_styles_positioning_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_positioning_' . $formats['WYSIWYG editor'];
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

  $export['wysiwyg_filter_styles_positioning_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_table_' . $formats['WYSIWYG public'];
  $strongarm->value = array(
    'border-collapse' => 0,
    'border-spacing' => 0,
    'caption-side' => 0,
    'empty-cells' => 0,
    'table-layout' => 0,
  );

  $export['wysiwyg_filter_styles_table_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_table_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'border-collapse' => 0,
    'border-spacing' => 0,
    'caption-side' => 0,
    'empty-cells' => 0,
    'table-layout' => 0,
  );

  $export['wysiwyg_filter_styles_table_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_table_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'border-collapse' => 'border-collapse',
    'border-spacing' => 'border-spacing',
    'caption-side' => 'caption-side',
    'empty-cells' => 'empty-cells',
    'table-layout' => 'table-layout',
  );

  $export['wysiwyg_filter_styles_table_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_text_' . $formats['WYSIWYG public'];
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

  $export['wysiwyg_filter_styles_text_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_text_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'text-align' => 'text-align',
    'text-decoration' => 'text-decoration',
    'text-indent' => 'text-indent',
    'text-transform' => 0,
    'letter-spacing' => 0,
    'word-spacing' => 0,
    'white-space' => 0,
    'direction' => 0,
    'unicode-bidi' => 0,
  );

  $export['wysiwyg_filter_styles_text_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_text_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'text-align' => 'text-align',
    'text-decoration' => 'text-decoration',
    'text-indent' => 'text-indent',
    'text-transform' => 0,
    'letter-spacing' => 0,
    'word-spacing' => 0,
    'white-space' => 0,
    'direction' => 0,
    'unicode-bidi' => 0,
  );

  $export['wysiwyg_filter_styles_text_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_user_' . $formats['WYSIWYG public'];
  $strongarm->value = array(
    'cursor' => 0,
    'outline' => 0,
    'outline-width' => 0,
    'outline-style' => 0,
    'outline-color' => 0,
    'zoom' => 0,
  );

  $export['wysiwyg_filter_styles_user_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_user_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'cursor' => 0,
    'outline' => 0,
    'outline-width' => 0,
    'outline-style' => 0,
    'outline-color' => 0,
    'zoom' => 0,
  );

  $export['wysiwyg_filter_styles_user_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_styles_user_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'cursor' => 0,
    'outline' => 0,
    'outline-width' => 0,
    'outline-style' => 0,
    'outline-color' => 0,
    'zoom' => 0,
  );

  $export['wysiwyg_filter_styles_user_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_parsed_' . $formats['WYSIWYG public'];
  $strongarm->value = array(
    'a' => array(
      'href' => array(
        'required' => TRUE,
      ),
      'target' => array(
        'values' => array(
          0 => '_blank',
        ),
      ),
      'title' => array(),
    ),
    'b' => array(),
    'br' => array(),
    'em' => array(),
    'i' => array(),
    'li' => array(),
    'ol' => array(),
    'p' => array(),
    'strong' => array(),
    'ul' => array(),
  );

  $export['wysiwyg_filter_valid_elements_parsed_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_parsed_' . $formats['WYSIWYG contributor'];
  $strongarm->value = array(
    'a' => array(
      'href' => array(
        'required' => TRUE,
      ),
      'target' => array(
        'values' => array(
          0 => '_blank',
        ),
      ),
      'title' => array(),
    ),
    'b' => array(),
    'blockquote' => array(),
    'br' => array(),
    'cite' => array(),
    'code' => array(),
    'dd' => array(),
    'div' => array(
      'align' => array(
        'values' => array(
          0 => 'center',
          1 => 'justify',
          2 => 'left',
          3 => 'right',
        ),
      ),
    ),
    'dl' => array(),
    'dt' => array(),
    'em' => array(),
    'h2' => array(),
    'h3' => array(),
    'h4' => array(),
    'i' => array(),
    'img' => array(
      'float' => array(
        'values' => array(
          0 => 'left',
          1 => 'right',
        ),
      ),
    ),
    'li' => array(),
    'ol' => array(),
    'p' => array(
      'style' => array(),
      'align' => array(
        'values' => array(
          0 => 'center',
          1 => 'justify',
          2 => 'left',
          3 => 'right',
        ),
      ),
    ),
    'span' => array(
      'style' => array(),
      'class' => array(),
    ),
    'strong' => array(),
    'ul' => array(),
  );

  $export['wysiwyg_filter_valid_elements_parsed_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_parsed_' . $formats['WYSIWYG editor'];
  $strongarm->value = array(
    'a' => array(
      'href' => array(
        'required' => TRUE,
      ),
      'target' => array(
        'values' => array(
          0 => '_blank',
        ),
      ),
      'title' => array(),
    ),
    'b' => array(),
    'blockquote' => array(),
    'br' => array(),
    'caption' => array(),
    'cite' => array(),
    'code' => array(),
    'col' => array(),
    'colgroup' => array(),
    'dd' => array(),
    'div' => array(
      'align' => array(
        'values' => array(
          0 => 'center',
          1 => 'justify',
          2 => 'left',
          3 => 'right',
        ),
      ),
    ),
    'dl' => array(),
    'dt' => array(),
    'em' => array(),
    'h2' => array(),
    'h3' => array(),
    'h4' => array(),
    'i' => array(),
    'img' => array(
      'float' => array(
        'values' => array(
          0 => 'left',
          1 => 'right',
        ),
      ),
    ),
    'li' => array(),
    'ol' => array(),
    'p' => array(
      'style' => array(),
      'align' => array(
        'values' => array(
          0 => 'center',
          1 => 'justify',
          2 => 'left',
          3 => 'right',
        ),
      ),
    ),
    'span' => array(
      'style' => array(),
      'class' => array(),
    ),
    'strong' => array(),
    'table' => array(
      'width' => array(),
      'cellpadding' => array(),
      'cellspacing' => array(),
      'border' => array(),
    ),
    'tbody' => array(),
    'td' => array(
      'align' => array(),
      'valign' => array(),
      'width' => array(),
    ),
    'tfoot' => array(),
    'th' => array(
      'align' => array(),
      'valign' => array(),
      'width' => array(),
    ),
    'thead' => array(),
    'tr' => array(
      'align' => array(),
      'valign' => array(),
    ),
    'ul' => array(),
  );

  $export['wysiwyg_filter_valid_elements_parsed_' . $formats['WYSIWYG editor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_raw_' . $formats['WYSIWYG public'];
  $strongarm->value = 'a[!href|target<_blank|title],
br,p,em/i,strong/b,ul,ol,li,';

  $export['wysiwyg_filter_valid_elements_raw_' . $formats['WYSIWYG public']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_raw_' . $formats['WYSIWYG contributor'];
  $strongarm->value = 'a[!href|target<_blank|title],
div[align<center?justify?left?right],
p[style|align<center?justify?left?right],
img[float<left?right],
br,span[style|class],em/i,strong/b,cite,code,blockquote,ul,ol,li,dl,dt,dd,h2,h3,h4';

  $export['wysiwyg_filter_valid_elements_raw_' . $formats['WYSIWYG contributor']] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'wysiwyg_filter_valid_elements_raw_' . $formats['WYSIWYG editor'];
  $strongarm->value = 'a[!href|target<_blank|title],
div[align<center?justify?left?right],
p[style|align<center?justify?left?right],
img[float<left?right],
br,span[style|class],em/i,strong/b,cite,code,blockquote,ul,ol,li,dl,dt,dd,h2,h3,h4,
table[width|cellpadding|cellspacing|border], tr[align|valign], td[align|valign|width], tbody, th[align|valign|width], thead, tfoot, colgroup, col, caption,';

  $export['wysiwyg_filter_valid_elements_raw_' . $formats['WYSIWYG editor']] = $strongarm;

  return $export;
}

/**
 * "Manually" install WYSIWYG and Better Formats settings.
 */
function _markdown_wysiwyg_install_manual($formats) {
  if (!variable_get('markdown_wysiwyg_installed', FALSE)) {

    // Install WYSIWYG.
    $wysiwyg = array();
    $wysiwyg[] = array(
      'format' => $formats['WYSIWYG public'],
      'editor' => 'tinymce',
      'settings' => 'a:20:{s:7:"default";i:1;s:11:"user_choose";i:1;s:11:"show_toggle";i:1;s:5:"theme";s:8:"advanced";s:8:"language";s:2:"en";s:7:"buttons";a:1:{s:7:"default";a:5:{s:4:"bold";i:1;s:6:"italic";i:1;s:7:"bullist";i:1;s:7:"numlist";i:1;s:4:"link";i:1;}}s:11:"toolbar_loc";s:3:"top";s:13:"toolbar_align";s:4:"left";s:8:"path_loc";s:6:"bottom";s:8:"resizing";i:1;s:11:"verify_html";i:1;s:12:"preformatted";i:0;s:22:"convert_fonts_to_spans";i:1;s:17:"remove_linebreaks";i:1;s:23:"apply_source_formatting";i:0;s:27:"paste_auto_cleanup_on_paste";i:0;s:13:"block_formats";s:9:"h2,h3,h4,";s:11:"css_setting";s:4:"none";s:8:"css_path";s:0:"";s:11:"css_classes";s:0:"";}',
    );

    $wysiwyg[] = array(
      'format' => $formats['WYSIWYG contributor'],
      'editor' => 'tinymce',
      'settings' => 'a:20:{s:7:"default";i:1;s:11:"user_choose";i:1;s:11:"show_toggle";i:1;s:5:"theme";s:8:"advanced";s:8:"language";s:2:"en";s:7:"buttons";a:3:{s:7:"default";a:13:{s:4:"bold";i:1;s:6:"italic";i:1;s:9:"underline";i:1;s:11:"justifyleft";i:1;s:13:"justifycenter";i:1;s:12:"justifyright";i:1;s:11:"justifyfull";i:1;s:7:"bullist";i:1;s:7:"numlist";i:1;s:7:"outdent";i:1;s:6:"indent";i:1;s:4:"link";i:1;s:6:"unlink";i:1;}s:4:"font";a:1:{s:12:"formatselect";i:1;}s:5:"paste";a:1:{s:9:"pastetext";i:1;}}s:11:"toolbar_loc";s:3:"top";s:13:"toolbar_align";s:4:"left";s:8:"path_loc";s:6:"bottom";s:8:"resizing";i:1;s:11:"verify_html";i:1;s:12:"preformatted";i:0;s:22:"convert_fonts_to_spans";i:1;s:17:"remove_linebreaks";i:1;s:23:"apply_source_formatting";i:0;s:27:"paste_auto_cleanup_on_paste";i:0;s:13:"block_formats";s:9:"h2,h3,h4,";s:11:"css_setting";s:4:"none";s:8:"css_path";s:0:"";s:11:"css_classes";s:0:"";}', 
    );
    $wysiwyg[] = array(
      'format' => $formats['WYSIWYG editor'],
      'editor' => 'tinymce',
      'settings' => 'a:20:{s:7:"default";i:1;s:11:"user_choose";i:1;s:11:"show_toggle";i:1;s:5:"theme";s:8:"advanced";s:8:"language";s:2:"en";s:7:"buttons";a:4:{s:7:"default";a:13:{s:4:"bold";i:1;s:6:"italic";i:1;s:9:"underline";i:1;s:11:"justifyleft";i:1;s:13:"justifycenter";i:1;s:12:"justifyright";i:1;s:11:"justifyfull";i:1;s:7:"bullist";i:1;s:7:"numlist";i:1;s:7:"outdent";i:1;s:6:"indent";i:1;s:4:"link";i:1;s:6:"unlink";i:1;}s:4:"font";a:1:{s:12:"formatselect";i:1;}s:5:"paste";a:1:{s:9:"pastetext";i:1;}s:5:"table";a:1:{s:13:"tablecontrols";i:1;}}s:11:"toolbar_loc";s:3:"top";s:13:"toolbar_align";s:4:"left";s:8:"path_loc";s:6:"bottom";s:8:"resizing";i:1;s:11:"verify_html";i:1;s:12:"preformatted";i:0;s:22:"convert_fonts_to_spans";i:1;s:17:"remove_linebreaks";i:1;s:23:"apply_source_formatting";i:0;s:27:"paste_auto_cleanup_on_paste";i:0;s:13:"block_formats";s:9:"h2,h3,h4,";s:11:"css_setting";s:4:"none";s:8:"css_path";s:0:"";s:11:"css_classes";s:0:"";}',
    );
    foreach ($wysiwyg as $editor) {
      db_query("INSERT INTO {wysiwyg} (format, editor, settings) VALUES (%d, '%s', '%s')", $editor['format'], $editor['editor'], $editor['settings']);
    }

    // Install Better Formats.
    $types = array('node', 'comment', 'block');
    $roles = user_roles();
    $names = array(
      $roles[DRUPAL_ANONYMOUS_RID] => array(
        'format' => $formats['WYSIWYG public'],
        'weight' => -1,
      ),
      $roles[DRUPAL_AUTHENTICATED_RID] => array(
        'format' => $formats['WYSIWYG public'],
        'weight' => -2,
      ),
      'contributor' => array(
        'format' => $formats['WYSIWYG contributor'],
        'weight' => -20,
      ),
      'editor' => array(
        'format' => $formats['WYSIWYG editor'],
        'weight' => -30,
      ),
      'administrator' => array(
        'format' => $formats['WYSIWYG editor'],
        'weight' => -40,
      ),
    );
    foreach ($types as $type) {
      foreach ($roles as $rid => $name) {
        if (in_array($name, array_keys($names))) {
          db_query("UPDATE {better_formats_defaults} SET format = %d , weight = %d WHERE rid = %d AND type = '%s'", $names[$name]['format'], $names[$name]['weight'], $rid, $type);
          if (!db_affected_rows()) {
            db_query("INSERT INTO {better_formats_defaults} (rid, type, format, type_weight, weight) VALUES (%d, '%s', %d, 1, %d)", $rid, $type, $names[$name]['format'], $names[$name]['weight']);
          }
        }
      }
    }
    drupal_set_message(t('WYSIWYG and Better Formats settings saved. Note that these settings are not managed by Features, meaning that no updates will be received.'));
    variable_set('markdown_wysiwyg_installed', TRUE);
  }
}

/**
 * Return an array of formats used with WYSIWYG.
 */
function _markdown_wysiwyg_formats() {
  $default_formats = array('WYSIWYG public', 'WYSIWYG contributor', 'WYSIWYG editor');
  $formats = array();
  $result = db_query('SELECT format, name FROM {filter_formats} WHERE name IN (' . db_placeholders($default_formats, 'varchar') . ')', $default_formats);
  while ($format = db_fetch_array($result)) {
    $formats[$format['name']] = $format['format'];
  }
  return $formats;
}
