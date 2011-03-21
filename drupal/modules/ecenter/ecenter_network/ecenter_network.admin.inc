<?php
// $Id$

/**
 * @file
 * Administrative configuration for E-center weathermap.
 */

function ecenter_network_admin_form() {
  $client = ecenter_network_get_client('message');

  $form = array();
  $form['service'] = array(
    '#title' => t('Web service settings'),
    '#type' => 'fieldset',
  );
  $form['service']['ecenter_network_host'] = array(
    '#title' => t('Host'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_host', 'localhost'),
  );
  $form['service']['ecenter_network_port'] = array(
    '#title' => t('Port'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_port', 8000),
  );
  $form['service']['ecenter_network_basedir'] = array(
    '#title' => t('Base directory'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_basedir', ''),
  );
  $form['service']['ecenter_network_timeout'] = array(
    '#title' => t('Timeout'),
    '#type' => 'textfield',
    '#description' => t('Timeout for calls to the webservice, in seconds.'),
    '#default_value' => variable_get('ecenter_network_timeout', 30),
  );
  $form['service']['ecenter_network_status_timeout'] = array(
    '#title' => t('Status timeout'),
    '#type' => 'textfield',
    '#description' => t('Timeout to check the webservice status, in seconds.'),
    '#default_value' => variable_get('ecenter_network_status_timeout', 2),
  );
  $form['service']['ecenter_network_time_increment'] = array(
    '#title' => t('Time increment'),
    '#type' => 'textfield',
    '#description' => t('Specify time granularity (in minutes), to use in weather map date selector and when setting default date.'),
    '#default_value' => variable_get('ecenter_network_time_increment', 5),
  );
  $form['service']['ecenter_network_time_window'] = array(
    '#title' => t('Time window'),
    '#type' => 'textfield',
    '#description' => t('Specify default window of time to query over, in seconds (i.e. 1 hour is 3600 seconds).'),
    '#default_value' => variable_get('ecenter_network_time_window', 7200),
  );

  $form['performance'] = array(
    '#title' => t('Performance'),
    '#type' => 'fieldset',
  );
  $form['performance']['ecenter_network_data_cache_enabled'] = array(
    '#title' => t('Enable data result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should the Ecenter Network cache results?'),
    '#default_value' => variable_get('ecenter_network_data_cache_enabled', 0),
  );
  $form['performance']['ecenter_network_data_cache_ttl'] = array(
    '#title' => t('Data cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_data_cache_ttl', 3600),
  );
  $form['performance']['ecenter_network_hop_cache_enabled'] = array(
    '#title' => t('Enable hop result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should the Ecenter Network cache results?'),
    '#default_value' => variable_get('ecenter_network_hop_cache_enabled', 0),
  );
  $form['performance']['ecenter_network_hop_cache_ttl'] = array(
    '#title' => t('Hop cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_hop_cache_ttl', 300),
  );


  $form['thresholds_colors'] = array(
    '#title' => t('Threshold colors'),
    '#type' => 'fieldset',
    '#collapsible' => TRUE,
  );

  $form['thresholds_colors']['ecenter_network_threshold_critical_color'] = array(
    '#title' => t('Critical color'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_threshold_critical_color', '#cc0000'),
  );
  $form['threshold_colors']['ecenter_network_threshold_marginal_color'] = array(
    '#title' => t('Marginal color'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_threshold_marginal_color', '#fe890c'),
  );
  $form['threshold_colors']['ecenter_network_threshold_good_color'] = array(
    '#title' => t('Marginal color'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_threshold_good_color', '#1c8a24'),
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
  );
  $form['thresholds']['snmp']['ecenter_network_threshold_critical_snmp_utilization'] = array(
    '#title' => t('Critical utilization'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_threshold_critical_snmp_utilization', 90),
    '#description' => t('Percent utilization above this threshold is considered critical.'),
  );
  $form['thresholds']['snmp']['ecenter_network_threshold_marginal_snmp_utilization'] = array(
    '#title' => t('Marginal utilization'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_threshold_marginal_snmp_utilization', 70),
    '#description' => t('Percent utilization above this threshold is considered marginal.'),
  );

  $form['thresholds']['bwctl'] = array(
    '#title' => t('BWCTL'),
    '#type' => 'fieldset',
    '#collapsible' => TRUE,
  );
  $form['thresholds']['bwctl']['ecenter_network_threshold_critical_bwctl_throughput'] = array(
    '#title' => t('Critical throughput'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_threshold_critical_bwctl_throughput', 90),
    '#description' => t('Percent (compared to slowest link in path) throughput below this threshold is considered critical.'),
  );
  $form['thresholds']['bwctl']['ecenter_network_threshold_marginal_bwctl_throughput'] = array(
    '#title' => t('Marginal utilization'),
    '#type' => 'textfield',
    '#default_value' => variable_get('ecenter_network_threshold_marginal_bwctl_throughput', 95),
    '#description' => t('Percent (compared to slowest link in path) throughput below this threshold is considered marginal.'),
  );

  return system_settings_form($form);
}
