<?php

/**
 * Implementation of hook_strongarm().
 */
function ecenter_mail_strongarm() {
  $export = array();

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'mailcomment_import_filter_mode';
  $strongarm->value = '2';
  $export['mailcomment_import_filter_mode'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'mailcomment_reply_text';
  $strongarm->value = '--- Reply ABOVE this LINE to POST a COMMENT ---';
  $export['mailcomment_reply_text'] = $strongarm;

  return $export;
}
