<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function ecenter_core_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: primary-links:contact
  $menu_links['primary-links:contact'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'contact',
    'router_path' => 'contact',
    'link_title' => 'Leave feedback',
    'options' => array(
      'attributes' => array(
        'title' => '',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '17',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Leave feedback');


  return $menu_links;
}
