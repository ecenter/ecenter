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
  $form['service']['ecenter_weathermap_timeout'] = array(
    '#title' => t('Timeout'),
    '#type' => 'textfield',
    '#description' => t('Timeout for calls to the webservice, in seconds.'),
    '#default_value' => variable_get('ecenter_weathermap_timeout', 30),
  );
  $form['service']['ecenter_weathermap_time_increment'] = array(
    '#title' => t('Time increment'),
    '#type' => 'textfield',
    '#description' => t('Specify time granularity (in minutes), to use in weather map date selector and when setting default date.'),
    '#default_value' => variable_get('ecenter_weathermap_time_increment', 5),
  );
  $form['service']['ecenter_weathermap_time_window'] = array(
    '#title' => t('Time window'),
    '#type' => 'textfield',
    '#description' => t('Specify default window of time to query over, in seconds (i.e. 1 hour is 3600 seconds).'),
    '#default_value' => variable_get('ecenter_weathermap_time_window', 3600),
  );

  $form['thresholds'] = array(
    '#title' => t('Threshold values'),
    '#type' => 'fieldset',
    '#description' => t('Set threshold values for data diagnostics'),
  );
  $form['thresholds']['snmp'] = array(
    '#title' => t('SNMP'),
    '#type' => 'fieldset',
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
  );
  $form['thresholds']['snmp']['critical'] = array(
    '#title' => t('Critical utilization'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_weathermap_threshold_critical_snmp_utilization', 90),
  );
  $form['thresholds']['snmp']['marginal'] = array(
    '#title' => t('Marginal utilization'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_weathermap_threshold_marginal_snmp_utilization', 70),
  );

  return system_settings_form($form);
}
