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
    'drs_circuit' => t('Circuit data service'),
    'ads' => t('Anomaly Detection Service'),
    'fds' => t('Forecasting Detection Service'),
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
      '#default_value' => variable_get('ecenter_network_'. $type .'_timeout', 120),
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
    if ($type == 'ads' || $type == 'fds') {
      $form[$type]['ecenter_network_'. $type .'_resolution']['#default_value'] = 
        variable_get('ecenter_network_'. $type .'_resolution', 1000);
    }
  }

  // DRS specific settings
  $form['performance'] = array(
    '#title' => t('Performance'),
    '#type' => 'fieldset',
    '#collapsible' => TRUE,
  );
  $form['performance']['data'] = array(
    '#title' => t('Data result caching'),
    '#type' => 'fieldset',
    '#collapsible' => FALSE,
    '#description' => t('Enabling all data result caching options is <strong>highly recommended</strong> in normal situations.'),
  );
  $form['performance']['data']['ecenter_network_data_cache_enabled'] = array(
    '#title' => t('Enable data result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache data results?'),
    '#default_value' => variable_get('ecenter_network_data_cache_enabled', 1),
  );
  $form['performance']['data']['ecenter_network_ads_cache_enabled'] = array(
    '#title' => t('Enable anomaly data result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache anomaly data results?'),
    '#default_value' => variable_get('ecenter_network_ads_cache_enabled', 1),
  );
  $form['performance']['data']['ecenter_network_fds_cache_enabled'] = array(
    '#title' => t('Enable forecasting data result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache forecasting data results?'),
    '#default_value' => variable_get('ecenter_network_fds_cache_enabled', 1),
  );
  $form['performance']['data']['ecenter_network_data_cache_ttl'] = array(
    '#title' => t('Data cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should data results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_data_cache_ttl', 3600),
  );
  $form['performance']['hops'] = array(
    '#title' => t('Node and hop result caching'),
    '#type' => 'fieldset',
    '#collapsible' => FALSE,
    '#description' => t('Cache the site list and traceroute interface information. This should be enabled in most situations. If you expect your network topology to change frequently, set a low ttl or disable these options.'),
  );
  $form['performance']['hops']['ecenter_network_hop_cache_enabled'] = array(
    '#title' => t('Enable hop result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache source / destination hop combinations?'),
    '#default_value' => variable_get('ecenter_network_hop_cache_enabled', 1),
  );
  $form['performance']['hops']['ecenter_network_hop_cache_ttl'] = array(
    '#title' => t('Hop cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should hop results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_hop_cache_ttl', 300),
  );
  $form['performance']['hops']['ecenter_network_node_cache_enabled'] = array(
    '#title' => t('Enable node result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache node results?'),
    '#default_value' => variable_get('ecenter_network_node_cache_enabled', 1),
  );
  $form['performance']['hops']['ecenter_network_node_cache_ttl'] = array(
    '#title' => t('Node cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should node results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_node_cache_ttl', 300),
  );
  $form['performance']['scv'] = array(
    '#title' => t('Site centric view caching'),
    '#type' => 'fieldset',
    '#collapsible' => FALSE,
    '#description' => t('Enabling caching of site centric data is <strong>highly recommended</strong> in normal situations. <strong>Do not disable except when debugging.</strong>'),
  );
  $form['performance']['scv']['ecenter_network_site_data_cache_enabled'] = array(
    '#title' => t('Enable site data result caching'),
    '#type' => 'checkbox',
    '#description' => t('Should E-center Network cache site-centric data results?'),
    '#default_value' => variable_get('ecenter_network_site_data_cache_enabled', 1),
  );
  $form['performance']['scv']['ecenter_network_site_data_cache_ttl'] = array(
    '#title' => t('Site data cache time to live'),
    '#type' => 'textfield',
    '#description' => t('How long should results be cached, in seconds?'),
    '#default_value' => variable_get('ecenter_network_site_data_cache_ttl', 86400),
  );

  return system_settings_form($form);
}
