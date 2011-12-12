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
  $strongarm->name = 'beautytips_custom_style';
  $strongarm->value = array(
    'fill' => '#ffffaa',
    'strokeWidth' => '',
    'strokeStyle' => '#666666',
    'width' => '',
    'padding' => '',
    'cornerRadius' => '',
    'spikeGirth' => '',
    'spikeLength' => '',
    'shadowBlur' => 4,
    'shadowColor' => '#444444',
    'shadow' => 'shadow',
  );
  $export['beautytips_custom_style'] = $strongarm;

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
  $strongarm->value = array(
    'cssStyles' => array(),
  );
  $export['beautytips_defaults'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_drupal_help';
  $strongarm->value = 0;
  $export['beautytips_drupal_help'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_form_id';
  $strongarm->value = '';
  $export['beautytips_form_id'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_position';
  $strongarm->value = 'bottom';
  $export['beautytips_position'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_show_form';
  $strongarm->value = 0;
  $export['beautytips_show_form'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'beautytips_text_input';
  $strongarm->value = 0;
  $export['beautytips_text_input'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-cornerRadius';
  $strongarm->value = '';
  $export['bt-options-box-cornerRadius'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-fill';
  $strongarm->value = '#ffffaa';
  $export['bt-options-box-fill'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-padding';
  $strongarm->value = '';
  $export['bt-options-box-padding'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-shadow';
  $strongarm->value = 'shadow';
  $export['bt-options-box-shadow'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-shadowBlur';
  $strongarm->value = 4;
  $export['bt-options-box-shadowBlur'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-shadowColor';
  $strongarm->value = '#444444';
  $export['bt-options-box-shadowColor'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-spikeGirth';
  $strongarm->value = '';
  $export['bt-options-box-spikeGirth'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-spikeLength';
  $strongarm->value = '';
  $export['bt-options-box-spikeLength'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-strokeStyle';
  $strongarm->value = '#666666';
  $export['bt-options-box-strokeStyle'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-strokeWidth';
  $strongarm->value = '';
  $export['bt-options-box-strokeWidth'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-box-width';
  $strongarm->value = '';
  $export['bt-options-box-width'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-css-color';
  $strongarm->value = '';
  $export['bt-options-css-color'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-css-fontFamily';
  $strongarm->value = '';
  $export['bt-options-css-fontFamily'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-css-fontSize';
  $strongarm->value = '';
  $export['bt-options-css-fontSize'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-css-fontWeight';
  $strongarm->value = '';
  $export['bt-options-css-fontWeight'] = $strongarm;

  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'bt-options-cssClass';
  $strongarm->value = '';
  $export['bt-options-cssClass'] = $strongarm;

  return $export;
}
