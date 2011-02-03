<?php

/**
 * Implementation of hook_filter_default_formats().
 */
function markdown_wysiwyg_filter_default_formats() {
  $formats = array();

  // Exported format: Markdown WYSIWYG
  // Filters: Markdown, HTML filter, Pathologic
  $formats['Markdown WYSIWYG'] = array(
    'name' => 'Markdown WYSIWYG',
    'roles' => array(
      '1' => 'authenticated user',
    ),
    'filters' => array(
      '0' => array(
        'module' => 'markdown',
        'delta' => '0',
        'weight' => '0',
      ),
      '1' => array(
        'module' => 'filter',
        'delta' => 0,
        'weight' => 1,
      ),
      '2' => array(
        'module' => 'pathologic',
        'delta' => '0',
        'weight' => '2',
      ),
    ),
  );

  return $formats;
}
