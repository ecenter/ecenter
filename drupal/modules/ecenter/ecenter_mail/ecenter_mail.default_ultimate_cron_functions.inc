<?php

/**
 * Implementation of hook_default_ultimate_cron_function().
 */
function ecenter_mail_default_ultimate_cron_function() {
  $export = array();

  $function = new stdClass;
  $function->disabled = FALSE; /* Edit this to true to make a default function disabled initially */
  $function->api_version = 1;
  $function->function = 'job_scheduler_cron';
  $function->settings = array(
    'enabled' => 1,
    'rules' => array(
      0 => '* * * * *',
    ),
    'catch_up' => '',
    'service_group' => '',
  );
  $export['job_scheduler_cron'] = $function;

  $function = new stdClass;
  $function->disabled = FALSE; /* Edit this to true to make a default function disabled initially */
  $function->api_version = 1;
  $function->function = 'notifications_cron';
  $function->settings = array(
    'enabled' => 1,
    'rules' => array(
      0 => '*/5 * * * *',
    ),
    'catch_up' => '',
    'service_group' => '',
  );
  $export['notifications_cron'] = $function;

  return $export;
}
