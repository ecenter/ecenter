<?php

/**
 * Implementation of hook_strongarm().
 */
function ecenter_user_strongarm() {
  $export = array();

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'openid_selector_block_width';
  $strongarm->value = '7';
  $export['openid_selector_block_width'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'openid_selector_skin';
  $strongarm->value = 'shadow';
  $export['openid_selector_skin'] = $strongarm;

  return $export;
}
