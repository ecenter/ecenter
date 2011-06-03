<?php

/**
 * Implementation of hook_menu_default_menu_custom().
 */
function ecenter_dashboard_menu_default_menu_custom() {
  $menus = array();

  // Exported menu: menu-action-links
  $menus['menu-action-links'] = array(
    'menu_name' => 'menu-action-links',
    'title' => 'Action links',
    'description' => 'Primary site actions, for display outside of main menu structure.',
  );
  // Translatables
  // Included for use with string extractors like potx.
  t('Action links');
  t('Primary site actions, for display outside of main menu structure.');


  return $menus;
}
