<?php

/**
 * Implementation of hook_default_ultimate_cron_function().
 */
function ecenter_network_default_ultimate_cron_function() {
  $export = array();

  $function = new stdClass;
  $function->disabled = FALSE; /* Edit this to true to make a default function disabled initially */
  $function->api_version = 1;
  $function->function = 'ecenter_network_cron';
  $function->settings = array(
    'enabled' => 1,
    'rules' => array(
      0 => '0 * * * *',
    ),
    'catch_up' => '',
    'service_group' => '',
  );
  $export['ecenter_network_cron'] = $function;

  return $export;
}
