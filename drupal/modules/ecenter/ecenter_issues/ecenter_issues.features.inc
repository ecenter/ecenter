<?php

/**
 * Implementation of hook_ctools_plugin_api().
 */
function ecenter_issues_ctools_plugin_api() {
  list($module, $api) = func_get_args();
  if ($module == "context" && $api == "context") {
    return array("version" => 3);
  }
  elseif ($module == "strongarm" && $api == "strongarm") {
    return array("version" => 1);
  }
}

/**
 * Implementation of hook_node_info().
 */
function ecenter_issues_node_info() {
  $items = array(
    'issue' => array(
      'name' => t('Network issue'),
      'module' => 'features',
      'description' => t('A network issue is a discussion about any DOE enterprise network related topic, such as a performance problem or general question. Network issues can be associated with diagnostic results. Network issues support conversations with threaded comments.'),
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

/**
 * Implementation of hook_views_api().
 */
function ecenter_issues_views_api() {
  return array(
    'api' => '3.0-alpha1',
  );
}
