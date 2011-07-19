<?php

/**
 * Implementation of hook_menu_default_menu_links().
 */
function ecenter_wiki_menu_default_menu_links() {
  $menu_links = array();

  // Exported menu link: primary-links:node/add/wiki
  $menu_links['primary-links:node/add/wiki'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'node/add/wiki',
    'router_path' => 'node/add/wiki',
    'link_title' => 'Create wiki page',
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
    'parent_path' => 'wiki',
  );
  // Exported menu link: primary-links:wiki
  $menu_links['primary-links:wiki'] = array(
    'menu_name' => 'primary-links',
    'link_path' => 'wiki',
    'router_path' => 'wiki',
    'link_title' => 'Wiki',
    'options' => array(),
    'module' => 'system',
    'hidden' => '0',
    'external' => '0',
    'has_children' => '1',
    'expanded' => '0',
    'weight' => '-46',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Create wiki page');
  t('Wiki');


  return $menu_links;
}
