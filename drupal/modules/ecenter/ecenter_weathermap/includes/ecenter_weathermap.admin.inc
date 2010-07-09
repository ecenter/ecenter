<?php
// $Id$

function ecenter_weathermap_admin_form() {
  $form = array();
  $form['service'] = array(
    '#title' => t('Web service settings'),
    '#type' => 'fieldset',
  );
  $form['service']['ecenter_weathermap_host'] = array(
    '#title' => t('Host'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_weathermap_host', 'localhost'),
  );
  $form['service']['ecenter_weathermap_port'] = array(
    '#title' => t('Port'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_weathermap_port', 8000),
  );
  $form['service']['ecenter_weathermap_basedir'] = array(
    '#title' => t('Base directory'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_weathermap_basedir', ''),
  );
  return system_settings_form($form);
}
