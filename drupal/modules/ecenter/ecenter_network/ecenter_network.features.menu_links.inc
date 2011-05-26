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
    'link_title' => 'Network tools',
    'options' => array(
      'attributes' => array(
        'title' => '',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '1',
    'expanded' => '0',
    'weight' => '-48',
  );
  // Exported menu link: primary-links:network/health
  $menu_links['primary-links:network/health'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'network/health',
    'router_path' => 'network/health',
    'link_title' => 'Health status',
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
    'weight' => '-49',
    'parent_path' => 'network',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Dashboard');
  t('Health status');
  t('Network tools');


  return $menu_links;
}
