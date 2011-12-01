<?php
// $Id$

!function_exists('profiler_v2') ? require_once('profiles/ecenter/libraries/profiler/profiler.inc') : FALSE;
profiler_v2('ecenter');

/**
 * Implementation of hook_form_alter().
 */
function ecenter_form_alter(&$form, $form_state, $form_id) {
  if ($form_id == 'install_configure') {
    if (module_exists('ecenter_network')) {
      module_load_include('inc', 'ecenter_network', 'ecenter_network.admin');
      $ecenter_settings = ecenter_network_admin_form();
      $ecenter_settings['#tree'] = TRUE;
      unset($ecenter_settings['buttons']);
    }

    $form['ecenter'] = array(
      '#type' => 'fieldset',
      '#title' => t('E-Center settings'),
    ) + $ecenter_settings;

    $form['#submit'] = array('ecenter_profile_submit', 'install_configure_form_submit');
  }
}

/**
 * Submit callback for site install form
 */
function ecenter_profile_submit($form, &$form_state) {
  // Set E-center settings
  foreach ($form_state['values']['ecenter'] as $settings) {
    foreach ($settings as $key => $value) {
      variable_set($key, $value);
    }
  }
  _ecenter_profile_post_install();
}

/**
 * Post install function
 */
function _ecenter_profile_post_install() {
  // Required because menu_block doesn't support CTools/Features exportables
  // see http://drupal.org/node/693302
  variable_set('menu_block_1_admin_title', 'E-Center: Primary Links');
  variable_set('menu_block_1_depth', '1');
  variable_set('menu_block_1_expanded', 0);
  variable_set('menu_block_1_follow', 0);
  variable_set('menu_block_1_level', '1');
  variable_set('menu_block_1_parent', 'primary-links:0');
  variable_set('menu_block_1_sort', 0);
  variable_set('menu_block_1_title_link', 0);

  variable_set('menu_block_2_admin_title', 'E-Center: Secondary Links');
  variable_set('menu_block_2_depth', '1');
  variable_set('menu_block_2_expanded', 0);
  variable_set('menu_block_2_follow', 0);
  variable_set('menu_block_2_level', '2');
  variable_set('menu_block_2_parent', 'primary-links:0');
  variable_set('menu_block_2_sort', 0);
  variable_set('menu_block_2_title_link', 0);

  variable_set('menu_block_ids', array(1, 2));

  // Install syntaxhighlighter and ecenter_editor (must be installed after 
  // everything else)
  foreach (array('syntaxhighlighter', 'ecenter_editor') as $module) {
    module_load_install($module);
    $versions = drupal_get_schema_versions($module);
    drupal_set_installed_schema_version($module, SCHEMA_UNINSTALLED);
    module_invoke($module, 'uninstall');
    _drupal_install_module($module);
    module_invoke($module, 'enable');
    drupal_get_schema(NULL, TRUE);

    // Reset messages
    drupal_get_messages();
  }
}
