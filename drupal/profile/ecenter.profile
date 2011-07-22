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
}

