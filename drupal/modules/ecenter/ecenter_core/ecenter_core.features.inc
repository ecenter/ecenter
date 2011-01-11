<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function ecenter_core_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "context" && $api == "context") {
    return array("version" => 3);
  }
  elseif ($module == "strongarm" && $api == "strongarm") {
    return array("version" => 1);
  }
}

/**
 * Implementation of hook_homebox().
 */
function ecenter_core_homebox() {
  $homeboxes = array();

  $homeboxes['dashboard'] = array (
    'regions' => 2,
    'cache' => 0,
    'color' => 0,
    'colors' => 
    array (
      0 => '#E4F0F8',
      1 => '#E4F0F8',
      2 => '#E4F0F8',
      3 => '#E4F0F8',
      4 => '#E4F0F8',
      5 => '#E4F0F8',
    ),
    'blocks' => 
    array (
      'comment_0' => 
      array (
        'module' => 'comment',
        'delta' => '0',
        'region' => 1,
        'movable' => 1,
        'status' => 1,
        'open' => 1,
        'closable' => 1,
        'title' => '',
        'weight' => -1,
      ),
      'search_0' => 
      array (
        'module' => 'search',
        'delta' => '0',
        'region' => 2,
        'movable' => 1,
        'status' => 1,
        'open' => 1,
        'closable' => 1,
        'title' => '',
        'weight' => -8,
      ),
    ),
    'widths' => 
    array (
    ),
    'title' => 'Dashboard',
    'path' => 'dashboard',
    'menu' => 0,
    'enabled' => 1,
    'full' => 0,
    'custom' => 0,
    'roles' => 
    array (
      0 => 'authenticated user',
    ),
  );


  return $homeboxes;
}

/**
 * Implementation of hook_node_info().
 */
function ecenter_core_node_info() {
  $items = array(
    'page' => array(
      'name' => t('Page'),
      'module' => 'features',
      'description' => t('A static page, typically used for informational purposes.'),
      'has_title' => '1',
      'title_label' => t('Title'),
      'has_body' => '1',
      'body_label' => t('Body'),
      'min_word_count' => '0',
      'help' => '',
    ),
  );
  return $items;
}
