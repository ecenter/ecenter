<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function ecenter_groups_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: primary-links:og
  $menu_links['primary-links:og'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'og',
    'router_path' => 'og',
    'link_title' => 'Groups',
    'options' => array(
      'attributes' => array(
        'title' => 'Groups',
      ),
    ),
    'module' => 'menu',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '1',
    'expanded' => '0',
    'weight' => '-45',
  );
  // Exported menu link: primary-links:og/all
  $menu_links['primary-links:og/all'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'og/all',
    'router_path' => 'og/all',
    'link_title' => 'All groups',
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
    'weight' => '-50',
    'parent_path' => 'og',
  );
  // Exported menu link: primary-links:og/my
  $menu_links['primary-links:og/my'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'og/my',
    'router_path' => 'og/my',
    'link_title' => 'My groups',
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
    'parent_path' => 'og',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('All groups');
  t('Groups');
  t('My groups');


  return $menu_links;
}
