<?php
// $Id$

!function_exists('profiler_v2') ? require_once('profiles/ecenter/libraries/profiler/profiler.inc') : FALSE;
profiler_v2('ecenter');

function ecenter_form_alter(&$form, $form_state, $form_id) {
  //dpm(get_defined_vars());
  //dpr($form);
  //print_r($form);
  //print($form_id);

  if (module_exists('ecenter_network')) {
    module_load_include('inc', 'ecenter_network', 'ecenter_network.admin');
    $ecenter_settings = ecenter_network_admin_form();
    //$ecenter_settings['#tree'] = TRUE;
  }

  $form['ecenter'] = array(
    '#type' => 'fieldset',
    '#title' => t('E-Center settings'),
  ) + $ecenter_settings;
}

