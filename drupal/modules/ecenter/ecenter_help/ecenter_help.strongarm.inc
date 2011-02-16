<?php

/**
 * Implementation of hook_strongarm().
 */
function ecenter_help_strongarm() {
  $export = array();
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_added_selectors_array';
  $strongarm->value = array(
    0 => '',
  );

  $export['beautytips_added_selectors_array'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_added_selectors_string';
  $strongarm->value = '';

  $export['beautytips_added_selectors_string'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_advanced_help';
  $strongarm->value = 1;

  $export['beautytips_advanced_help'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_always_add';
  $strongarm->value = 1;

  $export['beautytips_always_add'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_default_style';
  $strongarm->value = 'facebook';

  $export['beautytips_default_style'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_defaults';
  $strongarm->value = array();

  $export['beautytips_defaults'] = $strongarm;
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_position';
  $strongarm->value = 'bottom';

  $export['beautytips_position'] = $strongarm;
  return $export;
}
