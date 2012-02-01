<?php
// $Id$

!function_exists('profiler_v2') ? require_once('profiles/ecenter/libraries/profiler/profiler.inc') : FALSE;
profiler_v2('ecenter');

/**
 * Implementation of hook_form_alter().
 */
function ecenter_form_alter(&$form, $form_state, $form_id) {
  if ($form_id == 'install_configure') {

    // Drop timezone offset and add date module's timezone name select box
    $form['server_settings']['date_default_timezone']['#access'] = FALSE;
    date_timezone_site_form($form);

    // Date module uses the validate callback to set timezone name and includes
    // date and time settings form specific logic. We'll do it ourselves in the
    // submit callback.
    unset($form['locale']['#element_validate']);

    // Add E-Center settings
    $form['ecenter'] = array(
      '#type' => 'fieldset',
      '#title' => t('E-Center settings'),
      '#tree' => TRUE,
    );

    if (module_exists('ecenter_network')) {
      module_load_include('inc', 'ecenter_network', 'ecenter_network.admin');
      $ecenter_settings = ecenter_network_admin_form();
      unset($ecenter_settings['buttons']);
      $form['ecenter'] += $ecenter_settings;
    }

    $form['#submit'] = array('ecenter_profile_submit', 'install_configure_form_submit');
  }
}

/**
 * Submit callback for site install form
 */
function ecenter_profile_submit($form, &$form_state) {

  // Set timezone name variable and offset, similar to date module
  if (!empty($form_state['values']['date_default_timezone_name'])) {
    variable_set('date_default_timezone_name', $form_state['values']['date_default_timezone_name']);
    $date = date_make_date('now', $form_state['values']['date_default_timezone_name']);
    $offset = date_offset_get($date);
    variable_set('date_default_timezone', $offset);
  }

  // Set E-Center variables
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

  // Disable Shib auth blocks
  db_query("UPDATE {blocks} SET status=0, region=NULL WHERE module='shib_auth'");
}
