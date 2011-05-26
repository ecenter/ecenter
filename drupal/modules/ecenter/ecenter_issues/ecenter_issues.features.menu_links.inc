<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function ecenter_issues_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: primary-links:issues
  $menu_links['primary-links:issues'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'issues',
    'router_path' => 'issues',
    'link_title' => 'Network issues',
    'options' => array(
      'attributes' => array(
        'title' => '',
      ),
    ),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '-47',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Network issues');


  return $menu_links;
}
