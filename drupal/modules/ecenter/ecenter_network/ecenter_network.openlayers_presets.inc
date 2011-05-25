<?php

/**
 * Implementation of hook_openlayers_presets().
 */
function ecenter_network_openlayers_presets() {
  $export = array();
  $openlayers_presets = new stdClass;
  $openlayers_presets->disabled = FALSE; /* Edit this to true to make a default openlayers_presets disabled initially */
  $openlayers_presets->api_version = 1;
  $openlayers_presets->name = 'ecenter_network';
  $openlayers_presets->title = 'E-Center Network';
  $openlayers_presets->description = 'E-Center network weathermap';
  $openlayers_presets->data = array(
    'width' => '660px',
    'height' => '360px',
    'image_path' => 'http://js.mapbox.com/theme/dark/',
    'css_path' => '',
    'proxy_host' => '',
    'hide_empty_map' => 0,
    'center' => array(
      'initial' => array(
        'centerpoint' => '-99.528515621067, 39.112468787821',
        'zoom' => '4',
      ),
    ),
    'behaviors' => array(
      'openlayers_behavior_navigation' => array(
        'zoomWheelEnabled' => 0,
      ),
      'openlayers_behavior_panzoombar' => array(),
      'openlayers_behavior_fullscreen' => array(
        'activated' => 0,
      ),
      'ecenter_network_behavior_select' => array(
        'layers' => array(
          'ecenter_network_sites' => 'ecenter_network_sites',
          'ecenter_network_traceroute' => 'ecenter_network_traceroute',
        ),
      ),
      'ecenter_network_behavior_dynamicload' => array(),
      'ecenter_network_behavior_curves' => array(
        'layers' => array(
          'ecenter_network_traceroute' => 'ecenter_network_traceroute',
        ),
        'style' => 'ecenter_default',
      ),
    ),
    'default_layer' => 'world_glass',
    'layers' => array(
      'world_glass' => 'world_glass',
      'ecenter_network_sites' => 'ecenter_network_sites',
      'ecenter_network_traceroute' => 'ecenter_network_traceroute',
    ),
    'layer_activated' => array(
      'ecenter_network_sites' => 'ecenter_network_sites',
      'ecenter_network_traceroute' => 'ecenter_network_traceroute',
    ),
    'projection' => '900913',
    'styles' => array(
      'default' => 'ecenter_default',
      'select' => 'ecenter_selected',
      'temporary' => 'default',
    ),
    'preset_name' => 'ecenter_network',
  );

  $export['ecenter_network'] = $openlayers_presets;
  return $export;
}
