<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function ecenter_issues_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "strongarm" && $api == "strongarm") {
    return array("version" => 1);
  }
}

/**
 * Implementation of hook_node_info().
 */
function ecenter_issues_node_info() {
  $items = array(
    'issue' => array(
      'name' => t('Issue'),
      'module' => 'features',
      'description' => t('An issue related to network performance.  Issues are automatically versioned, but the interface is hidden from the user.  Issues support comments.'),
      'has_title' => '1',
      'title_label' => t('Subject'),
      'has_body' => '1',
      'body_label' => t('Body'),
      'min_word_count' => '0',
      'help' => '',
    ),
    'network_query' => array(
      'name' => t('Network query'),
      'module' => 'features',
      'description' => t('A description of a query sent to the backend, along with the raw and processed data.'),
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
