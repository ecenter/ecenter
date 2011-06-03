<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function ecenter_dashboard_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: menu-action-links:network
  $menu_links['menu-action-links:network'] = array(
    'menu_name' => 'menu-action-links',
    'link_path' => 'network',
    'router_path' => 'network',
    'link_title' => 'Weathermap',
    'options' => array(
      'attributes' => array(
        'title' => 'E-Center weathermap',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '0',
  );
  // Exported menu link: menu-action-links:network/health
  $menu_links['menu-action-links:network/health'] = array(
    'menu_name' => 'menu-action-links',
    'link_path' => 'network/health',
    'router_path' => 'network/health',
    'link_title' => 'Network health',
    'options' => array(
      'attributes' => array(
        'title' => 'Can our data retrieval service reach distributed measurement points?',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '2',
  );
  // Exported menu link: menu-action-links:node/add/issue
  $menu_links['menu-action-links:node/add/issue'] = array(
    'menu_name' => 'menu-action-links',
    'link_path' => 'node/add/issue',
    'router_path' => 'node/add/issue',
    'link_title' => 'Create new issue',
    'options' => array(
      'attributes' => array(
        'title' => 'Create a new conversation about a network issue',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '6',
  );
  // Exported menu link: menu-action-links:node/add/wiki
  $menu_links['menu-action-links:node/add/wiki'] = array(
    'menu_name' => 'menu-action-links',
    'link_path' => 'node/add/wiki',
    'router_path' => 'node/add/wiki',
    'link_title' => 'Create new wiki page',
    'options' => array(
      'attributes' => array(
        'title' => 'Create a new wiki page',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '0',
    'expanded' => '0',
    'weight' => '10',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Create new issue');
  t('Create new wiki page');
  t('Network health');
  t('Weathermap');


  return $menu_links;
}
