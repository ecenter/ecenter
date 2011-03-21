<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function ecenter_network_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: primary-links:network
  $menu_links['primary-links:network'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'network',
    'router_path' => 'network',
    'link_title' => 'Explore network data',
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
    'weight' => '0',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Explore network data');


  return $menu_links;
}
