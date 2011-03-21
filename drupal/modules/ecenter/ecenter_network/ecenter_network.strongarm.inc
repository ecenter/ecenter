<?php

/**
 * Implementation of hook_strongarm().
 */
function ecenter_network_strongarm() {
  $export = array();
  $strongarm = new stdClass;
  $strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
  $strongarm->api_version = 1;
  $strongarm->name = 'openlayers_source';
  $strongarm->value = 'profiles/ecenter/libraries/openlayers/OpenLayers.js';

  $export['openlayers_source'] = $strongarm;
  return $export;
}
