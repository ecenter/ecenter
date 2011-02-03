<?php

/**
 * Implementation of hook_filter_default_formats().
 */
function markdown_wysiwyg_filter_default_formats() {
  $formats = array();

  // Exported format: Markdown WYSIWYG
  $formats['Markdown WYSIWYG'] = array(
    'name' => 'Markdown WYSIWYG',
    'roles' => array(
      '0' => 'authenticated user',
    ),
    'filters' => array(
      '0' => array(
        'module' => 'markdown',
        'delta' => '0',
        'weight' => '-10',
      ),
      '1' => array(
        'module' => 'wysiwyg_filter',
        'delta' => '0',
        'weight' => '-9',
      ),
      '2' => array(
        'module' => 'pathologic',
        'delta' => '0',
        'weight' => '-8',
      ),
    ),
  );

  return $formats;
}
