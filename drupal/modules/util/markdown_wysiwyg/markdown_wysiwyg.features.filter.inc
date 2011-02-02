<?php

/**
 * Implementation of hook_filter_default_formats().
 */
function markdown_wysiwyg_filter_default_formats() {
  $formats = array();

  // Exported format: WYSIWYG public
  $formats['WYSIWYG public'] = array(
    'name' => 'WYSIWYG public',
    'roles' => array(
      '0' => 'anonymous user',
      '1' => 'authenticated user',
      '2' => 'contributor',
      '3' => 'editor',
      '4' => 'administrator',
    ),
    'filters' => array(
      '0' => array(
        'module' => 'filter',
        'delta' => '2',
        'weight' => '0',
      ),
      '1' => array(
        'module' => 'wysiwyg_filter',
        'delta' => '0',
        'weight' => '1',
      ),
      '2' => array(
        'module' => 'filter',
        'delta' => '1',
        'weight' => '2',
      ),
      '3' => array(
        'module' => 'filter',
        'delta' => '3',
        'weight' => '10',
      ),
    ),
  );

  // Exported format: WYSIWYG contributor
  $formats['WYSIWYG contributor'] = array(
    'name' => 'WYSIWYG contributor',
    'roles' => array(
      '0' => 'contributor',
      '1' => 'editor',
      '2' => 'administrator',
    ),
    'filters' => array(
      '0' => array(
        'module' => 'filter',
        'delta' => '2',
        'weight' => '0',
      ),
      '1' => array(
        'module' => 'wysiwyg_filter',
        'delta' => '0',
        'weight' => '1',
      ),
      '2' => array(
        'module' => 'filter',
        'delta' => '1',
        'weight' => '2',
      ),
      '3' => array(
        'module' => 'filter',
        'delta' => '3',
        'weight' => '10',
      ),
    ),
  );

  // Exported format: WYSIWYG editor
  $formats['WYSIWYG editor'] = array(
    'name' => 'WYSIWYG editor',
    'roles' => array(
      '0' => 'editor',
      '1' => 'administrator',
    ),
    'filters' => array(
      '0' => array(
        'module' => 'filter',
        'delta' => '2',
        'weight' => '0',
      ),
      '1' => array(
        'module' => 'wysiwyg_filter',
        'delta' => '0',
        'weight' => '1',
      ),
      '2' => array(
        'module' => 'filter',
        'delta' => '1',
        'weight' => '2',
      ),
      '3' => array(
        'module' => 'filter',
        'delta' => '3',
        'weight' => '10',
      ),
    ),
  );

  return $formats;
}
