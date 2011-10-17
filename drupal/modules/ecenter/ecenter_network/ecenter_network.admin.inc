<?php
// $Id$

/**
 * @file
 * Administrative configuration for E-center weathermap.
 */

function ecenter_network_admin_form() {
  $services = array(
    'drs' => t('Data Retrieval Service'),
    'drs_sitecentric' => t('Data Retrieval Service (Site-centric)'),
    'ads' => t('Anomaly Detection Service'),
  );
  $form = array(); 

  foreach ($services as $type => $name) {

    // Get each client
    ecenter_network_get_client('message', $type);

    $form[$type] = array(
      '#title' => $name,
      '#type' => 'fieldset',
      '#collapsible' => TRUE,
      '#collapsed' => FALSE,
    );
    $form[$type]['ecenter_network_'. $type .'_host'] = array(
      '#title' => t('Host'),
      '#type' => 'textfield',
      '#default_value' => variable_get('ecenter_network_'. $type .'_host', 'localhost'),
    );
    $form[$type]['ecenter_network_'. $type .'_port'] = array(
      '#title' => t('Port'),
      '#type' => 'textfield',
      '#default_value' => variable_get('ecenter_network_'. $type .'_port', 8000),
    );
    $form[$type]['ecenter_network_'. $type .'_basedir'] = array(
      '#title' => t('Base directory'),
      '#type' => 'textfield',
      '#default_value' => variable_get('ecenter_network_'. $type .'_basedir', ''),
    );
    $form[$type]['ecenter_network_'. $type .'_timeout'] = array(
      '#title' => t('Timeout'),
      '#type' => 'textfield',
      '#description' => t('Timeout for calls to the webservice, in seconds.'),
      '#default_value' => variable_get('ecenter_network_'. $type .'_timeout', 30),
    );
    $form[$type]['ecenter_network_'. $type .'_status_timeout'] = array(
      '#title' => t('Status timeout'),
      '#type' => 'textfield',
      '#description' => t('Timeout to check the webservice status, in seconds.'),
      '#default_value' => variable_get('ecenter_network_'. $type .'_status_timeout', 2),
    );
    $form[$type]['ecenter_network_'. $type .'_resolution'] = array(
      '#title' => t('Query resolution'),
      '#type' => 'textfield',
      '#description' => t('The default query resolution.'),
      '#default_value' => variable_get('ecenter_network_'. $type .'_resolution', 50),
    );

    if ($type == 'ads') {
      $form[$type]['ecenter_network_'. $type .'_resolution']['#default_value'] = 
        variable_get('ecenter_network_'. $type .'_resolution', 1000);
    }
  }

  // DRS specific settings
  $form['drs']['ecenter_network_time_increment'] = array(
    '#title' => t('Time increment'),
    '#type' => 'textfield',
    '#description' => t('Specify time granularity (in minutes), to use in weather map date selector and when setting default date.'),
    '#default_value' => variable_get('ecenter_network_time_increment', 5),
  );
  $form['drs']['ecenter_network_time_window'] = array(
    '#title' => t('Time window'),
    '#type' => 'textfield',
    '#description' => t('Specify default window of time to query over, in seconds (i.e. 1 hour is 3600 seconds).'),
    '#default_value' => variable_get('ecenter_network_time_window', 7200),
  );
  $form['drs']['performance'] = array(
    '#title' => t('Performance'),
    '#type' => 'fieldset',
    '#collapsible' => TRUE,
    '#collapsed' => TRUE,
  );
  $form['drs']['performance']['ecenter_network_data_cache_enabled'] = array(
    '#title' => t('Enable data result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache data results?'),
    '#default_value' => variable_get('ecenter_network_data_cache_enabled', 0),
  );
  $form['drs']['performance']['ecenter_network_data_cache_ttl'] = array(
    '#title' => t('Data cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_data_cache_ttl', 3600),
  );
  $form['drs']['performance']['ecenter_network_hop_cache_enabled'] = array(
    '#title' => t('Enable hop result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache source / destination hop combinations?'),
    '#default_value' => variable_get('ecenter_network_hop_cache_enabled', 0),
  );
  $form['drs']['performance']['ecenter_network_hop_cache_ttl'] = array(
    '#title' => t('Hop cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should hop results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_hop_cache_ttl', 300),
  );
  $form['drs']['performance']['ecenter_network_node_cache_enabled'] = array(
    '#title' => t('Enable node result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache node results?'),
    '#default_value' => variable_get('ecenter_network_node_cache_enabled', 0),
  );
  $form['drs']['performance']['ecenter_network_node_cache_ttl'] = array(
    '#title' => t('Hop cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should node results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_node_cache_ttl', 300),
  );
  $form['drs']['performance']['ecenter_network_site_data_cache_enabled'] = array(
    '#title' => t('Enable site data result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache site-centric data results?'),
    '#default_value' => variable_get('ecenter_network_site_data_cache_enabled', 0),
  );
  $form['drs']['performance']['ecenter_network_site_data_cache_ttl'] = array(
    '#title' => t('Site data cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_site_data_cache_ttl', 3600),
  );

  return system_settings_form($form);
}
